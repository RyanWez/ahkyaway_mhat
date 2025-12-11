package com.ahkyawaymhat.app

import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.ahkyawaymhat.app/device_info"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getSupportedAbis" -> {
                    // Return the list of supported ABIs for this device
                    val abis = Build.SUPPORTED_ABIS.toList()
                    result.success(abis)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
