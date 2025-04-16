package com.yueying.get_instance_bridge

import java.lang.ref.WeakReference

class LifecycleReference<T : LifecycleReference.Referent>(referent: T) {

    interface Referent {
        val isDestroy: Boolean
    }

    private val reference: WeakReference<T> = WeakReference(referent)

    fun get(): T? = reference.get()?.run {
        if (isDestroy) {
            reference.clear()
            null
        } else {
            return this
        }
    }
}
