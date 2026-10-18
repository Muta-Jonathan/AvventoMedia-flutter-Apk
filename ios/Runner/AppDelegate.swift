import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    // Free / total storage for the Downloads storage card.
    FlutterMethodChannel(name: "tv.avventomedia.app/storage", binaryMessenger: engineBridge.applicationRegistrar.messenger())
      .setMethodCallHandler { call, result in
        guard call.method == "storage" else { return result(FlutterMethodNotImplemented) }
        let values = try? URL(fileURLWithPath: NSHomeDirectory()).resourceValues(
          forKeys: [.volumeAvailableCapacityForImportantUsageKey, .volumeTotalCapacityKey])
        guard let free = values?.volumeAvailableCapacityForImportantUsage,
              let total = values?.volumeTotalCapacity else { return result(nil) }
        result(["free": free, "total": total])
      }
  }
}
