package com.yueying.get_instance_bridge_example

import android.os.Bundle
import com.yueying.get_instance_bridge.instances.DefaultResponder
import com.yueying.get_instance_bridge.instances.FlutterResponder
import com.yueying.get_instance_bridge.instances.InstancesManager
import com.yueying.get_instance_bridge.instances.ResponderConstructor
import com.yueying.get_instance_bridge.instances.handler.AnyMixCallHandler
import com.yueying.get_instance_bridge.instances.handler.MixVoidCallHandler
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {

    class Repository(private val id: String) : DefaultResponder() {
        override fun getHandler(method: String): AnyMixCallHandler? = when (method) {
            "id" -> MixVoidCallHandler.standard { success, _ ->
                success(id)
            }

            else -> null
        }

        companion object Creator : FlutterResponder.Creator {
            ///
            override val typeName: String
                get() = "TestRepository"

            ///
            override val constructor: ResponderConstructor
                get() = { _, id ->
                    Repository(id as String)
                }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        InstancesManager.register(Repository.Creator)
    }

    override fun onDestroy() {
        super.onDestroy()
        InstancesManager.unregister(Repository.Creator)
    }
}
