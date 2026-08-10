package com.yueying.get_instance_bridge.instances

import com.yueying.get_instance_bridge.utils.FlutterRequestError
import com.yueying.get_instance_bridge.utils.onError
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel


class InstancesManager private constructor() : MethodChannel.MethodCallHandler {

    private val builderMap: MutableMap<String, ResponderConstructor> = mutableMapOf()
    private val cachesMap: MutableMap<String, FlutterResponder> = mutableMapOf()

    companion object {
        private val manager = InstancesManager()
        private var channel: MethodChannel? = null

        internal fun getChannel(): MethodChannel? = channel


        internal fun initChannel(messenger: BinaryMessenger) {
            val channel = MethodChannel(messenger, "MixInstances")
            channel.setMethodCallHandler(manager)
            Companion.channel = channel
        }

        internal fun onDetached() {
            channel?.setMethodCallHandler(null)
            channel = null
        }

        fun register(creator: FlutterResponder.Creator) {
            synchronized(manager) {
                manager.builderMap[creator.typeName] = creator.constructor
            }
        }

        fun unregister(creator: FlutterResponder.Creator) {
            val typeName = creator.typeName
            synchronized(manager) {
                manager.builderMap.remove(typeName)
                manager.removeCaches(typeName)
            }
        }

        ///
        fun destroyCaches() = manager.destroyCaches()
    }

    ///
    private fun key(typeName: String, hashCode: Number): String {
        return typeName + "_" + hashCode.toString()
    }

    ///
    private fun find(typeName: String, hash: Number): FlutterResponder? {
        return cachesMap[key(typeName, hash)]
    }

    ///
    private fun instance(arguments: Any?, result: MethodChannel.Result) {
        if (arguments !is Map<*, *>) {
            result.notImplemented()
            return
        }
        val typeName = arguments["typeName"]
        val hashCode = arguments["hash"]
        if (typeName !is String ||
            hashCode !is Number ||
            typeName.isEmpty() ||
            create(typeName, hashCode, arguments["arguments"]) == null
        ) {
            result.notImplemented()
            return
        }
        result.success(0)
    }

    ///
    private fun destroy(arguments: Any?, result: MethodChannel.Result) {
        if (arguments !is Map<*, *>) {
            result.notImplemented()
            return
        }
        val typeName = arguments["typeName"]
        val hashCode = arguments["hash"]
        if (typeName !is String || hashCode !is Number || typeName.isEmpty()) {
            result.notImplemented()
            return
        }
        val key = key(typeName, hashCode)
        synchronized(this) {
            cachesMap.remove(key)?.runCatching {
                willDestroy()
            }?.onFailure {
                assert(false) { it }
            }
        }
        result.success(0)
    }

    ///
    private fun create(typeName: String, hashCode: Number, arguments: Any?): FlutterResponder? {
        val key = key(typeName, hashCode)
        val instance = cachesMap[key]
        if (instance != null) return instance
        val constructor = builderMap[typeName] ?: return null
        val newI = constructor(hashCode.toLong(), arguments)
        // 使用 synchronized 保护 cachesMap 写操作，防止跨线程竞态
        synchronized(this) {
            // 双重检查：可能在等待锁期间已被其他线程创建
            cachesMap[key]?.let { return it }
            cachesMap[key] = newI
        }
        return newI
    }

    ///
    private fun method(method: String, arguments: Any?, result: MethodChannel.Result) {
        val components = method.split(".")
        if (components.size != 4) {
            result.notImplemented()
            return
        }
        val hashCode = components[2].toLongOrNull()
        if (hashCode == null) {
            result.notImplemented()
            return
        }
        val typeName = components[1]
        val instance = find(typeName, hashCode)
        if (instance == null) {
            result.onError(FlutterRequestError.invalidObject)
            return
        }
        instance.callMethod(components[3], arguments, result)
    }

    ///
    private fun destroyCaches() {
        synchronized(this) {
            removeCaches()
        }
    }

    ///
    private fun removeCaches(typeName: String? = null) {
        val iterator = cachesMap.iterator()
        runCatching {
            while (iterator.hasNext()) {
                val item = iterator.next()
                // 精确匹配：确保不会误删前缀相同的其他类型实例
                // 例如 unregister("A") 不会误删 "A_B" 的实例
                val need = if (typeName != null) {
                    val parts = item.key.split("_")
                    parts.size == 2 && parts[0] == typeName
                } else {
                    true
                }
                //
                if (need) {
                    iterator.runCatching {
                        remove()
                    }.onFailure {
                        assert(false) { it }
                    }
                    item.value.runCatching {
                        willDestroy()
                    }.onFailure {
                        assert(false) { it }
                    }
                }
            }
        }.onFailure {
            assert(false) { it }
        }
    }

    ///
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "instance") {
            instance(call.arguments, result)
        } else if (call.method == "destroy") {
            destroy(call.arguments, result)
        } else if (call.method.startsWith("method.")) {
            method(call.method, call.arguments, result)
        } else if (call.method == "cleanCaches") {
            destroyCaches()
            result.success(0)
        } else {
            result.notImplemented()
        }
    }
}