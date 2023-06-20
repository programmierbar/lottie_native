package de.lotum.lottie_native

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.platform.PlatformViewRegistry

class LottieNativePlugin : FlutterPlugin, ActivityAware {
    private var pluginBinding: FlutterPluginBinding? = null

    private fun initializePlugin(messenger: BinaryMessenger,
                                 viewRegistry: PlatformViewRegistry) {
        viewRegistry.registerViewFactory("de.lotum/lottie_native", LottieViewFactory(messenger))
    }

    override fun onAttachedToEngine(binding: FlutterPluginBinding) {
        pluginBinding = binding
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        // Do nothing
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        initializePlugin(pluginBinding!!.binaryMessenger, pluginBinding!!.platformViewRegistry)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        // Do nothing.
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        // Do nothing.
    }

    override fun onDetachedFromActivity() {
        // Do nothing.
    }
}