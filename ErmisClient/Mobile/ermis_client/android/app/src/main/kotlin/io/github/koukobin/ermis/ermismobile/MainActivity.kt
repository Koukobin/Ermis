package io.github.koukobin.ermis.ermismobile

import android.net.Uri
import android.os.Bundle
import androidx.activity.OnBackPressedCallback
import io.flutter.embedding.android.FlutterFragmentActivity
import android.provider.Settings
import android.content.BroadcastReceiver
import android.content.Context;
import android.content.Intent;

class MainActivity : FlutterFragmentActivity() { 
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        onBackPressedDispatcher.addCallback(this, object : OnBackPressedCallback(true) {
            override fun handleOnBackPressed() {
                finish() // Default back button behavior
            }
        })

        var REQUEST_OVERLAY_PERMISSIONS = 100
        if (!Settings.canDrawOverlays(getApplicationContext())) {
            val myIntent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION)
            val uri: Uri = Uri.fromParts("package", getPackageName(), null)
            myIntent.setData(uri)
            startActivityForResult(myIntent, REQUEST_OVERLAY_PERMISSIONS)
            return
        }
    }
}

