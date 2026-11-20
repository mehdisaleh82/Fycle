# Revokes the development certificates of the Apple developer account.
#
# Each build on a fresh machine makes Xcode ask Apple for a new development
# certificate, and nothing ever gives it back: after a few dozen builds the
# account is full and signing fails. This runs before the build and clears
# them. Builds already sent to TestFlight are not affected, and distribution
# certificates are left alone. See docs/DECISIONS.md, decision 167.
#
# Reads ASC_KEY_ID, ASC_ISSUER_ID and ASC_KEY_PATH (the .p8 file). Uses the
# standard library only. Never fails the build: a problem is printed and
# the build goes on. Prints no name and no serial number.
require 'base64'
require 'json'
require 'net/http'
require 'openssl'

HOST = 'api.appstoreconnect.apple.com'.freeze
DEVELOPMENT_TYPES = %w[DEVELOPMENT IOS_DEVELOPMENT].freeze

def encode(bytes)
  Base64.urlsafe_encode64(bytes, padding: false)
end

# A token signed with the key, as the App Store Connect API expects it.
def token
  key = OpenSSL::PKey.read(File.read(ENV.fetch('ASC_KEY_PATH')))
  now = Time.now.to_i
  header = { alg: 'ES256', kid: ENV.fetch('ASC_KEY_ID'), typ: 'JWT' }
  claims = {
    iss: ENV.fetch('ASC_ISSUER_ID'),
    iat: now,
    exp: now + 600,
    aud: 'appstoreconnect-v1'
  }
  input = "#{encode(header.to_json)}.#{encode(claims.to_json)}"
  # OpenSSL gives the signature as a DER sequence of two integers; the
  # token wants them as two 32-byte numbers side by side.
  der = key.sign(OpenSSL::Digest.new('SHA256'), input)
  raw = OpenSSL::ASN1.decode(der).value.map do |number|
    number.value.to_s(2).b.rjust(32, "\x00".b)
  end.join
  "#{input}.#{encode(raw)}"
end

def request(http, method, path, bearer)
  call = method.new(path)
  call['Authorization'] = "Bearer #{bearer}"
  http.request(call)
end

begin
  bearer = token
  Net::HTTP.start(HOST, 443, use_ssl: true, open_timeout: 20,
                             read_timeout: 60) do |http|
    listed = request(http, Net::HTTP::Get, '/v1/certificates?limit=200', bearer)
    unless listed.is_a?(Net::HTTPSuccess)
      puts "Could not list the certificates: HTTP #{listed.code}."
      exit 0
    end
    certificates = JSON.parse(listed.body).fetch('data', [])
    types = certificates.map { |one| one.dig('attributes', 'certificateType') }
    puts "Certificates on the account: #{types.tally}"

    revoked = 0
    certificates.each do |one|
      type = one.dig('attributes', 'certificateType')
      next unless DEVELOPMENT_TYPES.include?(type)

      answer = request(http, Net::HTTP::Delete,
                       "/v1/certificates/#{one.fetch('id')}", bearer)
      if answer.is_a?(Net::HTTPSuccess)
        revoked += 1
      else
        puts "Could not revoke one #{type} certificate: HTTP #{answer.code}."
      end
    end
    puts "Development certificates revoked: #{revoked}."
  end
rescue StandardError => e
  # The message of a key or network error may quote what it read.
  puts "Certificates left as they were (#{e.class})."
end
