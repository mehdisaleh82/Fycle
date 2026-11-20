"""Checks that the outside pages the app links to still answer.

Usage: python3 tool/check_links.py

Reads the lists of links of every language in lib/l10n (the entries whose
name starts with "links", one "title|source|address" per line) and asks
each address once. Fails when a page is gone, so that the daily run on
GitHub sends a notice. A site that refuses robots is only reported: it has
to be checked by hand. Standard library only.
"""
import glob
import json
import sys
import urllib.error
import urllib.request

GONE = {404, 410}
AGENT = 'Mozilla/5.0 (link check; no personal data)'


def links():
    found = {}
    for path in sorted(glob.glob('lib/l10n/app_*.arb')):
        with open(path, encoding='utf-8') as file:
            texts = json.load(file)
        for key, value in texts.items():
            if not key.startswith('links') or not isinstance(value, str):
                continue
            for line in value.split('\n'):
                parts = [part.strip() for part in line.split('|')]
                if len(parts) == 3 and parts[2].startswith('https://'):
                    found.setdefault(parts[2], '%s, %s' % (path, key))
    return found


def status(address):
    request = urllib.request.Request(address, headers={'User-Agent': AGENT})
    try:
        with urllib.request.urlopen(request, timeout=30) as answer:
            return answer.status
    except urllib.error.HTTPError as error:
        return error.code
    except Exception as error:  # noqa: BLE001 - any network failure
        return type(error).__name__


def main():
    gone, unsure = [], []
    for address, where in links().items():
        result = status(address)
        print('%s  %s' % (result, address))
        if result in GONE:
            gone.append((address, where))
        elif result != 200:
            unsure.append((address, result))
    if unsure:
        print('\nTo check by hand (refused, moved or unreachable):')
        for address, result in unsure:
            print('  %s  %s' % (result, address))
    if gone:
        print('\nGone:')
        for address, where in gone:
            print('  %s  (%s)' % (address, where))
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
