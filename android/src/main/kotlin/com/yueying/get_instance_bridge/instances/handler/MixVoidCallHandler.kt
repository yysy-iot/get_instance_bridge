package com.yueying.get_instance_bridge.instances.handler

import com.squareup.moshi.JsonAdapter
import com.squareup.moshi.adapter
import com.yueying.get_instance_bridge.moshi

class MixVoidCallHandler private constructor(handler: ((Any?) -> Unit, (Throwable) -> Unit) -> Unit) :
    MixCallHandler<Int, Any>({ 0 }, { _, success, failure ->
        handler(success, failure)
    }) {

    companion object {
        ///
        fun void(handler: (success: () -> Unit, failure: (Throwable) -> Unit) -> Unit): AnyMixCallHandler =
            MixVoidCallHandler { success, failure ->
                handler(toVoid(success), failure)
            }

        ///
        fun standard(handler: (success: (Any?) -> Unit, failure: (Throwable) -> Unit) -> Unit): AnyMixCallHandler =
            MixVoidCallHandler(handler)

        ///
        fun <R> obj(
            adapter: JsonAdapter<R>,
            handler: (success: (R?) -> Unit, failure: (Throwable) -> Unit) -> Unit
        ): AnyMixCallHandler =
            MixVoidCallHandler { success, failure ->
                handler({ result ->
                    runCatching {
                        if (result != null) {
                            adapter.toJsonValue(result)
                        } else {
                            null
                        }
                    }.onSuccess(success).onFailure(failure)
                }, failure)
            }

        ///
        @OptIn(ExperimentalStdlibApi::class)
        inline fun <reified R> obj(noinline handler: (success: (R?) -> Unit, failure: (Throwable) -> Unit) -> Unit): AnyMixCallHandler =
            obj(moshi.adapter<R>(), handler)
    }
}