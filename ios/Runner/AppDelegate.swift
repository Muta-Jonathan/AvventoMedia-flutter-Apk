import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    // Free / total storage for the Downloads storage card.
    if let controller = window?.rootViewController as? FlutterViewController {
      FlutterMethodChannel(name: "tv.avventomedia.app/storage", binaryMessenger: controller.binaryMessenger)
        .setMethodCallHandler { call, result in
          guard call.method == "storage" else { return result(FlutterMethodNotImplemented) }
          let values = try? URL(fileURLWithPath: NSHomeDirectory()).resourceValues(
            forKeys: [.volumeAvailableCapacityForImportantUsageKey, .volumeTotalCapacityKey])
          guard let free = values?.volumeAvailableCapacityForImportantUsage,
                let total = values?.volumeTotalCapacity else { return result(nil) }
          result(["free": free, "total": total])
        }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
