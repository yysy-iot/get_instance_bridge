package com.yueying.get_instance_bridge.utils

abstract class NativeError(
    val domain: String, val code: String, override val message: String
) : Throwable(message)
