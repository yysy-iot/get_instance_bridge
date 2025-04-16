package com.yueying.get_instance_bridge.instances.handler

import com.squareup.moshi.JsonAdapter
import com.yueying.get_instance_bridge.utils.FlutterRequestError

abstract class MixCallHandler<T, R : Any> internal constructor(
    val castFrom: ((Any?) -> T?), val handler: (T?, (R?) -> Unit, (Throwable) -> Unit) -> Unit
) : AnyMixCallHandler {

    override fun callHandler(
        arguments: Any?, success: (Any?) -> Unit, failure: (Throwable) -> Unit
    ) {
        runCatching {
            val dto = castFrom(arguments)
            handler(dto, success, failure)
        }.onFailure(failure)
    }

    internal companion object {

        fun toVoid(block: (Any?) -> Unit): () -> Unit = {
            block(0)
        }

        fun <T, R> toResult(
            resultAdapter: JsonAdapter<R>,
            handler: (argument: T, success: (R?) -> Unit, failure: (Throwable) -> Unit) -> Unit
        ): ((T, (Any?) -> Unit, (Throwable) -> Unit) -> Unit) = { argument, success, failure ->
            handler(argument, {
                if (it == null) {
                    success(null)
                } else {
                    runCatching {
                        resultAdapter.toJsonValue(it)
                    }.onFailure(failure).onSuccess(success)
                }
            }, failure)
        }

        ///
        fun <T> createCastFrom(castFrom: (Any) -> T): (Any?) -> T? = {
            if (it != null) {
                castFrom(it)
            } else {
                throw FlutterRequestError.invalidArgument
            }
        }
    }
}