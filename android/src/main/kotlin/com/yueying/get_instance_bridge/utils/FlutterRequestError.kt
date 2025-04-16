package com.yueying.get_instance_bridge.utils

class FlutterRequestError private constructor(code: String, message: String) :
    NativeError("YYPlatformError", code, message) {

    companion object {
        ///
        var invalidObject: FlutterRequestError = FlutterRequestError("405", "无效对象")

        ///
        var invalidArgument: FlutterRequestError = FlutterRequestError("400", "无效参数")

        ///
        var notImplemented: FlutterRequestError = FlutterRequestError("404", "未实现")

        ///
        var cancel: FlutterRequestError = FlutterRequestError("409", "cancel")
    }
}
