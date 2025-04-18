package com.yueying.get_instance_bridge.instances

import com.yueying.get_instance_bridge.LifecycleReference
import com.yueying.get_instance_bridge.instances.handler.AnyMixCallHandler
import com.yueying.get_instance_bridge.utils.onError
import io.flutter.plugin.common.MethodChannel

abstract class DefaultResponder : FlutterResponder, LifecycleReference.Referent {

    override var isDestroy: Boolean = false

    abstract fun getHandler(method: String): AnyMixCallHandler?

    override fun callMethod(method: String, arguments: Any?, result: MethodChannel.Result) {
        val handler = getHandler(method)
        if (handler == null) {
            result.notImplemented()
            return
        }
        handler.callHandler(arguments, { response ->
            result.runCatching {
                success(response)
            }
        }, {
            result.onError(it)
        })
    }

    override fun willDestroy() {
        isDestroy = true
    }
}