package com.yueying.get_instance_bridge.instances.handler

import com.squareup.moshi.JsonAdapter
import com.squareup.moshi.adapter
import com.yueying.get_instance_bridge.moshi


class MixObjCallHandler<T> private constructor(
    adapter: JsonAdapter<T>, handler: (T, (Any?) -> Unit, (Throwable) -> Unit) -> Unit
) : MixCallHandler<T, Any>(createCastFrom {
    adapter.fromJsonValue(it)
}, { argument, success, failure ->
    handler(argument!!, success, failure)
}) {

    companion object {
        ///
        fun <T> void(
            adapter: JsonAdapter<T>,
            handler: (argument: T, success: () -> Unit, failure: (Throwable) -> Unit) -> Unit
        ): AnyMixCallHandler = MixObjCallHandler(adapter) { argument, success, failure ->
            handler(argument, toVoid(success), failure)
        }

        ///
        fun <T> standard(
            adapter: JsonAdapter<T>,
            handler: (argument: T, success: (Any?) -> Unit, failure: (Throwable) -> Unit) -> Unit
        ): AnyMixCallHandler = MixObjCallHandler(adapter, handler)

        ///
        fun <T, R> obj(
            argAdapter: JsonAdapter<T>,
            resultAdapter: JsonAdapter<R>,
            handler: (argument: T, success: (R?) -> Unit, failure: (Throwable) -> Unit) -> Unit
        ): AnyMixCallHandler = MixObjCallHandler(argAdapter, toResult(resultAdapter, handler))

        ///
        @OptIn(ExperimentalStdlibApi::class)
        inline fun <reified T> void(noinline handler: (argument: T, success: () -> Unit, failure: (Throwable) -> Unit) -> Unit) =
            void(moshi.adapter(), handler)

        ///
        @OptIn(ExperimentalStdlibApi::class)
        inline fun <reified T, reified R> obj(noinline handler: (argument: T, success: (R?) -> Unit, failure: (Throwable) -> Unit) -> Unit) =
            obj(moshi.adapter(), moshi.adapter(), handler)

        ///
        @OptIn(ExperimentalStdlibApi::class)
        inline fun <reified T> standard(noinline handler: (argument: T, success: (Any?) -> Unit, failure: (Throwable) -> Unit) -> Unit) =
            standard(moshi.adapter(), handler)
    }
}

