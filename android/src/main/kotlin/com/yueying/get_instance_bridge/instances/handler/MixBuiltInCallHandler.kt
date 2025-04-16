package com.yueying.get_instance_bridge.instances.handler

import com.squareup.moshi.JsonAdapter
import com.squareup.moshi.adapter
import com.yueying.get_instance_bridge.utils.FlutterRequestError
import com.yueying.get_instance_bridge.moshi

class MixBuiltInCallHandler<T> private constructor(
    handler: (T, (Any?) -> Unit, (Throwable) -> Unit) -> Unit
) : MixCallHandler<T, Any>(createCastFrom {
    @Suppress("UNCHECKED_CAST") runCatching {
        it as T
    }.onFailure {
        throw FlutterRequestError.invalidArgument
    }.getOrThrow()
}, { argument, success, failure ->
    handler(argument!!, success, failure)
}) {

    companion object {
        ///
        fun <T> void(
            handler: (argument: T, success: () -> Unit, failure: (Throwable) -> Unit) -> Unit
        ): AnyMixCallHandler = MixBuiltInCallHandler { argument: T, success, failure ->
            handler(argument, toVoid(success), failure)
        }

        ///
        fun <T> standard(
            handler: (argument: T, success: (Any?) -> Unit, failure: (Throwable) -> Unit) -> Unit
        ): AnyMixCallHandler = MixBuiltInCallHandler(handler)

        ///
        fun <T, R> obj(
            resultAdapter: JsonAdapter<R>,
            handler: (argument: T, success: (R?) -> Unit, failure: (Throwable) -> Unit) -> Unit
        ): AnyMixCallHandler = MixBuiltInCallHandler(toResult(resultAdapter, handler))

        ///
        @OptIn(ExperimentalStdlibApi::class)
        inline fun <T, reified R> obj(noinline handler: (argument: T, success: (R?) -> Unit, failure: (Throwable) -> Unit) -> Unit) =
            obj(moshi.adapter(), handler)
    }
}