/* Copyright (C) 2024 Ilias Koukovinis <ilias.koukovinis@gmail.com>
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

import 'package:ermis_client/constants/app_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../client/client.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static int? chatSessionIndex;
  static VoidCallback? voiceCall;

  static Future<void> onDidReceiveNotification(NotificationResponse response) async {
    if (response.actionId == 'action_reply') {

      if (chatSessionIndex == null) {
        if (kDebugMode) debugPrint("ΓΑΜΩ ΤΟ ΣΠΙΤΙ ΜΟΥ ΚΑΙ ΤΑ ΠΑΝΤΑ. ΓΙΑΤΙ ΔΕΝ ΕΧΩ ΘΕΣΕΙ ΤΟ FUCKING INDEX");
        return;
      }

      String? input = response.input;
      if (input == null) {
        return;
      }

      Client.getInstance().sendMessageToClient(input, chatSessionIndex!);
    } else if (response.actionId == 'accept_voice_call') {
      voiceCall!();
    } else if (response.actionId == 'ignore_voice_call') {
      // Do nothing
    }
  }

  // Initialize the notification plugin
  static Future<void> init() async {
    // Defube the Abdroid initialisation settings
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings("@mipmap/ic_launcher");

    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: androidInitializationSettings, iOS: null);

    // Initialize the plugin with the specified settings
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveBackgroundNotificationResponse: onDidReceiveNotification,
        onDidReceiveNotificationResponse: onDidReceiveNotification);

    // Request notification permission for android
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> showIconNotification(Uint8List iconBytes, String title, String body) async {
    // Define Notification Details
    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        "channelId",
        "channelName",
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        largeIcon: ByteArrayAndroidBitmap(iconBytes),
      ),
    );

    return flutterLocalNotificationsPlugin.show(0, title, body, platformChannelSpecifics);
  }

  static Future<void> showIconNotification1(String iconPath, String title, String body) async {
    // Define Notification Details
    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        "channelId",
        "channelName",
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        largeIcon: FilePathAndroidBitmap(iconPath),
      ),
    );

    return flutterLocalNotificationsPlugin.show(0, title, body, platformChannelSpecifics);
  }

  static Future<void> showSimpleNotification({required String body}) async {
    // Define Notification Details
    NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: AndroidNotificationDetails(
      'your_channel_id', // Channel ID
      'your_channel_name', // Channel Name
      channelDescription: 'Detailed notification example',
      importance: Importance.high,
      priority: Priority.high,
      additionalFlags: Int32List.fromList(<int>[4]), // Optional, custom flags
      ticker: 'ticker',
    ));

    NotificationService.chatSessionIndex = chatSessionIndex;
    return flutterLocalNotificationsPlugin.show(0, applicationTitle, body, platformChannelSpecifics);
  }

  static Future<void> showVoiceCallNotification({
    required Uint8List icon,
    required String callerName,
    required int chatSessionIndex,
    required VoidCallback onAccept,
  }) async {
    voiceCall = onAccept;
    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        'your_channel_id',
        'your_channel_name', 
        channelDescription: 'Detailed notification example',
        importance: Importance.high,
        priority: Priority.high,
        largeIcon: ByteArrayAndroidBitmap(icon),
        ongoing: true, // Keeps the notification persistent
        autoCancel: false, // Prevents swiping it away
        fullScreenIntent: true, // Ensures it's shown prominently
        additionalFlags: Int32List.fromList(<int>[4]), // Optional, custom flags
        actions: [
          AndroidNotificationAction(
            'accept_voice_call',
            'Accept',
            showsUserInterface: true,
          ),
          AndroidNotificationAction(
            'ignore_voice_call',
            'Ignore',
          ),
        ],
        ticker: 'Incoming Voice Call',
      ),
    );

    // Store chatSessionIndex for future handling if needed
    NotificationService.chatSessionIndex = chatSessionIndex;
    return flutterLocalNotificationsPlugin.show(0, applicationTitle, '$callerName is calling...', platformChannelSpecifics);
  }


  // Show an instant Notification
  static Future<void> showInstantNotification({
    required Uint8List icon,
    required String body,
    required String summaryText,
    required String contentTitle,
    required String contentText,
    required int chatSessionIndex,
  }) async {
    NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'Detailed notification example',
      importance: Importance.high,
      priority: Priority.high,
      largeIcon: ByteArrayAndroidBitmap(icon),
      additionalFlags: Int32List.fromList(<int>[4]),
      actions: [
        AndroidNotificationAction(
          'action_reply',
          'Reply',
          showsUserInterface: true,
          icon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          inputs: [
            AndroidNotificationActionInput(
              label: 'Type your reply...',
            ),
          ],
        ),
        AndroidNotificationAction(
          'action_mark_read',
          'Mark as Read',
        ),
      ],
      styleInformation: BigTextStyleInformation(
        contentText,
        contentTitle: contentTitle,
        summaryText: summaryText,
      ),
      ticker: 'ticker',
    ));

    NotificationService.chatSessionIndex = chatSessionIndex;
    return flutterLocalNotificationsPlugin.show(0, applicationTitle, body, platformChannelSpecifics);
  }

}
