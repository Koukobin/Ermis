package io.github.koukobin.ermis.ermismobile

import android.os.Bundle
import androidx.activity.OnBackPressedCallback
import io.flutter.embedding.android.FlutterFragmentActivity  // Use FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity() {  // Change this
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        onBackPressedDispatcher.addCallback(this, object : OnBackPressedCallback(true) {
            override fun handleOnBackPressed() {
                finish() // Default back button behavior
            }
        })
    }
}
