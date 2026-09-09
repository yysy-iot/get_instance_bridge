import Flutter
import instance_bridge_core

public final class GetInstanceBridgePlugin: NSObject, FlutterPlugin {
    
  public static func register(with registrar: FlutterPluginRegistrar) {
      InstancesManager.initChannel(registrar.messenger())
  }
}
