package com.yueying.get_instance_bridge.instances

import com.yueying.get_instance_bridge.instances.handler.AnyMixCallHandler

interface MixInstance: FlutterResponder, FlutterRequester {

    val callHandler: Map<String, AnyMixCallHandler>
}


