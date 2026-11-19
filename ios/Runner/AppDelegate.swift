import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    excludeDataFolderFromBackup()
    // Lets the reminders plugin show a notification while the app is open.
    UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  /// Keeps the encrypted database out of iCloud and computer backups.
  ///
  /// The database lives in the Application Support folder. Its key stays in
  /// the Keychain of this phone and is never backed up, so a restored copy
  /// could not be read anyway. Excluding the whole folder also covers the
  /// temporary files SQLite writes next to the database. This runs before
  /// the database is first created, at every launch.
  private func excludeDataFolderFromBackup() {
    let fileManager = FileManager.default
    guard
      var folder = fileManager.urls(
        for: .applicationSupportDirectory, in: .userDomainMask
      ).first
    else {
      return
    }
    try? fileManager.createDirectory(at: folder, withIntermediateDirectories: true)
    var values = URLResourceValues()
    values.isExcludedFromBackup = true
    try? folder.setResourceValues(values)
  }
}
