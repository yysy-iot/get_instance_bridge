import Flutter
import UIKit
import instance_bridge_core

@main
@objc final class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        InstancesManager.register(type: TestRepository.self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}


