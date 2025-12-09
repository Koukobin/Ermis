/* Copyright (C) 2025 Ilias Koukovinis <ilias.koukovinis@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 */

import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:ermis_mobile/constants/app_constants.dart';
import 'package:ermis_mobile/core/services/database/extensions/chat_messages_extension.dart';
import 'package:ermis_mobile/core/services/database/extensions/unread_messages_extension.dart';
import 'package:ermis_mobile/core/services/settings_json.dart';
import 'package:ermis_mobile/core/util/ermis_loading_messages.dart';
import 'package:ermis_mobile/features/authentication/domain/entities/client_session_setup.dart';
import 'package:ermis_mobile/features/voice_call/web_rtc/call_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:timezone/data/latest.dart' as timezones;

import '../data_sources/api_client.dart';
import '../event_bus/app_event_bus.dart';
import '../models/chat_session.dart';
import '../models/message.dart';
import '../models/message_events.dart';
import '../networking/common/message_types/client_status.dart';
import '../util/message_notification.dart';
import 'notification_service.dart';
import 'database/database_service.dart';
import 'database/models/server_info.dart';

@pragma("vm:entry-point")
void onAndroidBackground(ServiceInstance service) {
  maintainWebSocketConnection(service);
}

@pragma("vm:entry-point")
bool onIosBackground(ServiceInstance service) {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  maintainWebSocketConnection(service);

  return true;
}

void maintainWebSocketConnection(ServiceInstance service) {
  debugPrint("BACKGROUND SERVICE IS INITIALIZING...");
  debugPrint("BACKGROUND SERVICE IS INITIALIZING...");
  debugPrint("BACKGROUND SERVICE IS INITIALIZING...");
  debugPrint("BACKGROUND SERVICE IS INITIALIZING...");
  debugPrint("BACKGROUND SERVICE IS INITIALIZING...");
  debugPrint("BACKGROUND SERVICE IS INITIALIZING...");
  debugPrint("BACKGROUND SERVICE IS INITIALIZING...");
  debugPrint("BACKGROUND SERVICE IS INITIALIZING...");
  debugPrint("BACKGROUND SERVICE IS INITIALIZING...");
  debugPrint("BACKGROUND SERVICE IS INITIALIZING...");

  service.on("stop").listen((event) {
    service.stopSelf();
    debugPrint("background process is now stopped");
  });

  bool uiAlive = false;

  // Listen for UI heartbeat
  service.on('ui_alive').listen((event) {
    uiAlive = true;

    if (Client.instance().isLoggedIn()) {
      if (kDebugMode) {
        print("Destroy client and event bus");
        print("Destroy client and event bus");
        print("Destroy client and event bus");
        print("Destroy client and event bus");
        print("Destroy client and event bus");
      }
      Client.instance().disconnect();
      AppEventBus.instance.destroyInstance();
      AppEventBus.instance.restoreInstance();
    }
  });

  Timer.periodic(const Duration(seconds: 30), (_) async {
    if (uiAlive) {
      debugPrint("UI isolate is alive");
      debugPrint("UI isolate is alive");
      debugPrint("UI isolate is alive");
      debugPrint("UI isolate is alive");
      debugPrint("UI isolate is alive");

      uiAlive = false;
      return;
    }

    if (Client.instance().isLoggedIn()) return;

    debugPrint("UI isolate is dead");
    debugPrint("UI isolate is dead");
    debugPrint("UI isolate is dead");
    debugPrint("UI isolate is dead");
    debugPrint("UI isolate is dead");
  
    WidgetsFlutterBinding.ensureInitialized();

    await AppConstants.initialize();
    await NotificationService.init();
    timezones.initializeTimeZones();

    final settingsJson = SettingsJson();
    await settingsJson.loadSettingsJson();

    Future<void> setupOfflineClient() async {
      try {
        await silentClientConnect();
      } catch (e) {
        // Attempt to reinitialize client in case of failure
        await Future.delayed(const Duration(seconds: 30), silentClientConnect);
      }

      Client.instance().commands!.setAccountStatus(ClientStatus.offline);
    }

    late ServerInfo serverInfo;
    setupOfflineClient().whenComplete(() {
      serverInfo = Client.instance().serverInfo!;

      final sessions = Client.instance().chatSessions!;
      for (final session in sessions) {
        Client.instance().commands!.fetchWrittenText(session.chatSessionIndex);
      }
    });

    AppEventBus.instance.on<WrittenTextEvent>().listen((event) async {
      ChatSession chatSession = event.chatSession;
      List<Message> messages = event.chatSession.messages;

      DBConnection conn = ErmisDB.getConnection();

      for (Message msg in messages) {
        int resultUpdate = await conn.insertChatMessage(
          serverInfo: serverInfo,
          message: msg,
        );

        if (resultUpdate > 0 && msg.clientID != Client.instance().clientID) {
          handleChatMessageNotificationBackground(chatSession, msg, settingsJson, (String text) {
            Client.instance().sendMessageToClient(text, chatSession.chatSessionIndex);
          });
        }

      }
    });

    AppEventBus.instance.on<ConnectionResetEvent>().listen((event) {
      // Attempt to re-establish connection in case of a connection reset
      Future.delayed(const Duration(seconds: 30), setupOfflineClient);
    });

    AppEventBus.instance.on<MessageReceivedEvent>().listen((event) {
      ChatSession chatSession = event.chatSession;
      Message msg = event.message;

      DBConnection conn = ErmisDB.getConnection();

      conn.insertChatMessage(
        serverInfo: Client.instance().serverInfo!,
        message: msg,
      );

      conn.insertUnreadMessage(serverInfo, msg.chatSessionID, msg.messageID);

      // Display notification only if message does not originate from one's self
      if (msg.clientID == Client.instance().clientID) return;

      handleChatMessageNotificationBackground(chatSession, msg, settingsJson, (String text) {
        Client.instance().sendMessageToClient(text, chatSession.chatSessionIndex);
      });
    });

    AppEventBus.instance.on<VoiceCallIncomingEvent>().listen((event) {
      NotificationService.showVoiceCallNotification(
          icon: event.member.icon.profilePhoto,
          callerName: event.member.username,
          payload: jsonEncode(
            CallInfo(
              chatSessionID: event.chatSessionID,
              chatSessionIndex: event.chatSessionIndex,
              member: event.member,
              isInitiator: false,
            ).toJson(),
          ),
          onAccept: () {
            // Won't get called since app will be brought from background to foreground
          });
    });

    debugPrint("BACKGROUND SERVICE INITIALIZED SUCCESSFULLY!");
    debugPrint("BACKGROUND SERVICE INITIALIZED SUCCESSFULLY!");
    debugPrint("BACKGROUND SERVICE INITIALIZED SUCCESSFULLY!");
    debugPrint("BACKGROUND SERVICE INITIALIZED SUCCESSFULLY!");
    debugPrint("BACKGROUND SERVICE INITIALIZED SUCCESSFULLY!");
    debugPrint("BACKGROUND SERVICE INITIALIZED SUCCESSFULLY!");
    debugPrint("BACKGROUND SERVICE INITIALIZED SUCCESSFULLY!");
    debugPrint("BACKGROUND SERVICE INITIALIZED SUCCESSFULLY!");
    debugPrint("BACKGROUND SERVICE INITIALIZED SUCCESSFULLY!");
    debugPrint("BACKGROUND SERVICE INITIALIZED SUCCESSFULLY!");
  });

}

class ErmisBackgroudService {

  static void startBackgroundService() {
    FlutterBackgroundService().configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onAndroidBackground,
        autoStartOnBoot: true,
        autoStart: true,
        isForegroundMode: true, // Displays a silent notification when used according to Android's Policy

        //notificationChannelId: 'ermis_mobile',
        initialNotificationTitle: 'Ermis is listening for messages...',
        initialNotificationContent: ErmisLoadingMessages.randomMessage(),
        foregroundServiceNotificationId: 4,
        foregroundServiceTypes: [AndroidForegroundType.remoteMessaging],
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onBackground: onIosBackground,
      ),
    );

    final service = FlutterBackgroundService();
    service.startService();

    // Timer which periodically informs background service 
    // UI is alive
    Timer.periodic(const Duration(seconds: 15), (_) {
      FlutterBackgroundService().invoke('ui_alive');
    });
  }

  static void stopBackgroundService() {
    final service = FlutterBackgroundService();
    service.invoke("stop");
  }

  static Future<bool> isRunning() => FlutterBackgroundService().isRunning();
}

// flutter_foreground_task

// void initForegroundTask() {
// FlutterForegroundTask.init(
//     androidNotificationOptions: AndroidNotificationOptions(
//       channelId: 'foreground_service',
//       channelName: 'Foreground Service Notification',
//       channelDescription:
//           'This notification appears when the foreground service is running.',
//       onlyAlertOnce: true,
//     ),
//     iosNotificationOptions: const IOSNotificationOptions(
//       showNotification: false,
//       playSound: false,
//     ),
//     foregroundTaskOptions: ForegroundTaskOptions(
//       eventAction: ForegroundTaskEventAction.repeat(5000),
//       autoRunOnBoot: true,
//       autoRunOnMyPackageReplaced: true,
//       allowWakeLock: true,
//       allowWifiLock: true,
//     ),
//   );
// }

// Future<void> startForegroundTask() async {
//   FlutterForegroundTask.initCommunicationPort();
//   await FlutterForegroundTask.startService(
//     notificationTitle: 'My App',
//     notificationText: 'Running background task...',
//     callback: startCallback,
//   );
// }

// @pragma('vm:entry-point')
// void startCallback() {
//   FlutterForegroundTask.setTaskHandler(MyTaskHandler());
// }

// class MyTaskHandler extends TaskHandler {
//   @override
//   Future<void> onStart(DateTime timestamp, TaskStarter sendPort) async {
//     // Do any setup work here
//   }

//   @override
//   Future<void> onRepeatEvent(DateTime timestamp) async {
//     // This runs every `interval` milliseconds
//     print('Background task running...');
//   }

//   // Called when data is sent using `FlutterForegroundTask.sendDataToTask`.
//   @override
//   void onReceiveData(Object data) {
//     print('onReceiveData: $data');
//   }

//   // Called when the notification button is pressed.
//   @override
//   void onNotificationButtonPressed(String id) {
//     print('onNotificationButtonPressed: $id');
//   }

//   @override
//   void onNotificationPressed() {
//     FlutterForegroundTask.launchApp();
//   }

//   // Called when the notification itself is dismissed.
//   @override
//   void onNotificationDismissed() {
//     print('onNotificationDismissed');
//   }
  
//   @override
//   Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
//     print('onDestroy(isTimeout: $isTimeout)');
//   }

// }