import Flutter
import UIKit
import FirebaseCore

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {

  /// Deep-link method channel — matches IOSDeepLinkService channel name
  private var deepLinkChannel: FlutterMethodChannel?
  private var initialDeepLink: String?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // ── Firebase initialisation ──────────────────────────────────────────────
    FirebaseApp.configure()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    // ── Deep Link MethodChannel ─────────────────────────────────────────────
    guard let controller = window?.rootViewController as? FlutterViewController else { return }
    deepLinkChannel = FlutterMethodChannel(
      name: "mycardshare/deep_links",
      binaryMessenger: controller.binaryMessenger
    )
    deepLinkChannel?.setMethodCallHandler { [weak self] (call, result) in
      if call.method == "getInitialLink" {
        result(self?.initialDeepLink)
        self?.initialDeepLink = nil
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
  }

  // ── Universal Links (HTTPS deep links) ─────────────────────────────────────
  override func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {
    if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
       let url = userActivity.webpageURL {
      handleIncomingLink(url.absoluteString)
    }
    return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
  }

  // ── Custom URL Scheme (mycardshare://) ─────────────────────────────────────
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    // Forward to Flutter (Google Sign-In, etc.)
    if super.application(app, open: url, options: options) { return true }
    handleIncomingLink(url.absoluteString)
    return true
  }

  // ── Helper: route link to Flutter ─────────────────────────────────────────
  private func handleIncomingLink(_ link: String) {
    if deepLinkChannel != nil {
      deepLinkChannel?.invokeMethod("onLink", arguments: link)
    } else {
      // App cold-started with link — store for getInitialLink()
      initialDeepLink = link
    }
  }
}
