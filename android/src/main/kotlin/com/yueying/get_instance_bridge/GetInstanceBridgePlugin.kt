package com.yueying.get_instance_bridge

import com.yueying.get_instance_bridge.instances.InstancesManager
import io.flutter.embedding.engine.plugins.FlutterPlugin

/** GetInstanceBridgePlugin */
class GetInstanceBridgePlugin : FlutterPlugin {


    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        InstancesManager.initChannel(flutterPluginBinding.binaryMessenger)
    }


    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        InstancesManager.onDetached()
    }
}
