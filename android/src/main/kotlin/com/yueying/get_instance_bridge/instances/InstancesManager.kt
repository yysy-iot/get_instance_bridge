package com.yueying.get_instance_bridge.instances

import com.yueying.get_instance_bridge.utils.FlutterRequestError
import com.yueying.get_instance_bridge.utils.error
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
        cachesMap[key] = newI
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
            result.error(FlutterRequestError.invalidObject)
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
                val need = if (typeName != null) {
                    item.key.startsWith(typeName + "_")
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
        } else if (call.method.startsWith("method")) {
            method(call.method, call.arguments, result)
        } else if (call.method == "cleanCaches") {
            destroyCaches()
            result.success(0)
        } else {
            result.notImplemented()
        }
    }
}