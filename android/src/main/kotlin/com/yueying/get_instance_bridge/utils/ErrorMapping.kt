package com.yueying.get_instance_bridge.utils

import io.flutter.plugin.common.MethodChannel

fun Throwable.getCode(): String {
    return if (this is NativeError) {
        code
    } else {
        "-1"
    }
}

fun Throwable.getDomain(): String {
    return if (this is NativeError) {
        domain
    } else {
        runCatching { javaClass.name }.getOrDefault("")
    }
}

private fun Throwable.toMap(): Map<String, Any?> {
    return mapOf("code" to getCode(), "message" to (message ?: ""), "details" to errorDetails())
}


fun Throwable.errorDetails(): Map<String, Any> {
    val mutableMap = mutableMapOf<String, Any>("domain" to getDomain())
    cause?.apply {
        mutableMap["NSUnderlyingErrorKey"] = toMap()
    }
    return mutableMap
}

///
internal fun MethodChannel.Result.onError(error: Throwable) {
    runCatching {
        error(error.getCode(), error.message, error.errorDetails())
    }
}