package com.yueying.get_instance_bridge.instances

import com.squareup.moshi.JsonAdapter
import com.yueying.get_instance_bridge.utils.FlutterRequestError
import com.yueying.get_instance_bridge.utils.errorDetails
import com.yueying.get_instance_bridge.utils.getCode
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch

interface FlutterRequester {

    val name: String
    val hashCode: Long

    ///
    fun <T> performObj(
        method: String,
        argument: T,
        adapter: JsonAdapter<T>,
        onResult: ((Any?) -> Void)? = null,
        onError: ((code: String, errorMessage: String?, errorDetails: Any?) -> Void)? = null
    ) {
        val map = runCatching { adapter.toJsonValue(argument) }.getOrElse {
            val error = it
            onError?.let {
                it(error.getCode(), error.localizedMessage, error.errorDetails())
            }
        }
        invokeMethod(method, map, onResult, onError)
    }

    ///
    fun <T> performBuiltIn(
        method: String,
        argument: T,
        onResult: ((Any?) -> Void)? = null,
        onError: ((code: String, errorMessage: String?, errorDetails: Any?) -> Void)? = null
    ) = invokeMethod(method, argument, onResult, onError)

    ///
    fun perform(
        method: String,
        arguments: String,
        onResult: ((Any?) -> Void)? = null,
        onError: ((code: String, errorMessage: String?, errorDetails: Any?) -> Void)? = null
    ) {
        invokeMethod(method, arguments, onResult, onError)
    }

    ///
    fun perform(
        method: String,
        arguments: Int,
        onResult: ((Any?) -> Void)? = null,
        onError: ((code: String, errorMessage: String?, errorDetails: Any?) -> Void)? = null
    ) {
        invokeMethod(method, arguments, onResult, onError)
    }
    ///
    fun perform(
        method: String,
        arguments: Long,
        onResult: ((Any?) -> Void)? = null,
        onError: ((code: String, errorMessage: String?, errorDetails: Any?) -> Void)? = null
    ) {
        invokeMethod(method, arguments, onResult, onError)
    }

    ///
    fun perform(
        method: String,
        arguments: Double,
        onResult: ((Any?) -> Void)? = null,
        onError: ((code: String, errorMessage: String?, errorDetails: Any?) -> Void)? = null
    ) {
        invokeMethod(method, arguments, onResult, onError)
    }

    ///
    fun perform(
        method: String,
        onResult: ((Any?) -> Void)? = null,
        onError: ((code: String, errorMessage: String?, errorDetails: Any?) -> Void)? = null
    ) {
        invokeMethod(method, 0, onResult, onError)
    }

    private fun invokeMethod(
        method: String,
        arguments: Any?,
        onResult: ((Any?) -> Void)?,
        onError: ((code: String, errorMessage: String?, errorDetails: Any?) -> Void)?
    ) {
        val channel = InstancesManager.getChannel()
        //
        if (channel == null) {
            onError?.let {
                MainScope().launch {
                    val error = FlutterRequestError.invalidObject
                    it(error.getCode(), error.localizedMessage, error.errorDetails())
                }
            }
            return
        }
        //
        channel.invokeMethod("method.$name.$hashCode.$method",
            arguments,
            object : MethodChannel.Result {
                override fun success(result: Any?) {
                    onResult?.let { it(result) }
                }

                override fun error(
                    errorCode: String, errorMessage: String?, errorDetails: Any?
                ) {
                    onError?.let { it(errorCode, errorMessage, errorDetails) }
                }

                override fun notImplemented() {
                    onError?.let {
                        val error = FlutterRequestError.notImplemented
                        it(error.getCode(), error.localizedMessage, error.errorDetails())
                    }
                }
            })
    }
}