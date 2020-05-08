import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    var flutter_native_splash = 1
    UIApplication.shared.isStatusBarHidden = false

    GeneratedPluginRegistrant.register(with: self)
    GMSServices.provideAPIKey("AIzaSyCzoZV03tAGRVn5dcTmGwrhiqEnvPc8uAE");
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}