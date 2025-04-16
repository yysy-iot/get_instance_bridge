package com.yueying.get_instance_bridge.utils

import io.flutter.plugin.common.MethodChannel

fun Throwable.getCode(): String {
    return if (this is NativeError) {
        this.code
    } else {
        "-1"
    }
}

fun Throwable.getDomain(): String {
    return if (this is NativeError) {
        this.domain
    } else {
        javaClass.name
    }
}

private fun Throwable.toMap(): Map<String, Any?> {
    val message: String = this.localizedMessage ?: ""
    return mapOf("code" to getCode(), "message" to message, "details" to errorDetails())
}


fun Throwable.errorDetails(): Map<String, Any> {
    val mutableMap = mutableMapOf<String, Any>("domain" to getDomain())
    if (cause != null) {
        mutableMap["NSUnderlyingErrorKey"] = cause!!.toMap()
    }
    return mutableMap
}

///
fun MethodChannel.Result.error(error: Throwable) {
    error(error.getCode(), error.message, error.errorDetails())
}