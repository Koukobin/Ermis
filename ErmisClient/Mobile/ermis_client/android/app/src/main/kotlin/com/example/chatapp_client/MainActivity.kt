package com.example.ermis_client

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant;

class MainActivity : FlutterActivity() {
private val CHANNEL = "android_app_retain"

override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    GeneratedPluginRegistrant.registerWith(flutterEngine)

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
        if (call.method == "sendToBackground") {
            moveTaskToBack(true) 
            result.success(null)
        } else {
            result.notImplemented()
        }
    }
}

 override fun onBackPressed() {
    moveTaskToBack(true)
 }
}
