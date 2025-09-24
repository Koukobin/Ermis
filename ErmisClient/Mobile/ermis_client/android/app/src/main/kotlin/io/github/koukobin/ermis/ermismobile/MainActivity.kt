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

    }
}

