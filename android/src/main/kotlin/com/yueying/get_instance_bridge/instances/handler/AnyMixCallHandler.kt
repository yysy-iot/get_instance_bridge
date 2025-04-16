package com.yueying.get_instance_bridge.instances.handler

interface AnyMixCallHandler {

    fun callHandler(arguments: Any?, success: (Any?) -> Unit, failure: (Throwable) -> Unit)
}

