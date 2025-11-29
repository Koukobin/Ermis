package io.github.koukobin.ermis.ermismobile;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

public class BootBroadcastReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        if (Intent.ACTION_BOOT_COMPLETED.equals(intent.getAction())) {
            Intent serviceIntent = new Intent();
            serviceIntent.setClassName(
                context.getPackageName(),
                "id.flutter.background_service.BackgroundService"
            );
            context.startForegroundService(serviceIntent);
        }
    }
}
