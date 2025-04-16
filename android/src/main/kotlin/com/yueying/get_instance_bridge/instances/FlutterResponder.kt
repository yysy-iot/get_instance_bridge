package com.yueying.get_instance_bridge.instances
import io.flutter.plugin.common.MethodChannel

typealias ResponderConstructor = (Long, Any?) -> FlutterResponder

interface FlutterResponder {

    fun callMethod(method: String, arguments: Any?, result: MethodChannel.Result)

    fun willDestroy()

    interface Creator {
        val typeName: String
        val constructor: ResponderConstructor
    }
}