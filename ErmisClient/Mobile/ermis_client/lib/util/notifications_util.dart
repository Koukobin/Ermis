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

typedef ReplyCallBack = void Function(String message);

enum NotificationAction {
  actionReply("action_reply"),
  acceptVoiceCall("accept_voice_call"),
  ignoreVoiceCall("ignore_voice_call"),
  markAsRead("mark_as_read");

  final String id;
  const NotificationAction(this.id);

  // This function mimics the fromId functionality and throws an exception when no match is found.
  static NotificationAction fromId(String id) {
    return NotificationAction.values.firstWhere((type) => type.id == id);
  }
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static ReplyCallBack? replyCallBack;
  static VoidCallback? voiceCall;

  static Future<void> onDidReceiveNotification(NotificationResponse response) async {
    String? actionId = response.actionId;
    if (actionId == null) {
      return;
    }

    NotificationAction na = NotificationAction.fromId(actionId);
    switch (na) {
      case NotificationAction.acceptVoiceCall:
        voiceCall!();
        break;
      case NotificationAction.ignoreVoiceCall:
        // Do nothing
        break;
      case NotificationAction.actionReply:
        String? input = response.input;
        if (input == null) {
          return;
        }

        replyCallBack!(input);
        break;
      case NotificationAction.markAsRead:
        // To be implemented in the future
        break;
    }
  }

  // Initialize the notification plugin
  static Future<void> init() async {
    // Defube the Abdroid initialisation settings
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings("@mipmap/ic_launcher");

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      iOS: null,
    );

    // Initialize the plugin with the specified settings
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveBackgroundNotificationResponse: onDidReceiveNotification,
      onDidReceiveNotificationResponse: onDidReceiveNotification,
    );

    // // Request notification permission for android
    // await flutterLocalNotificationsPlugin
    //     .resolvePlatformSpecificImplementation<
    //         AndroidFlutterLocalNotificationsPlugin>()
    //     ?.requestNotificationsPermission();
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

    return flutterLocalNotificationsPlugin.show(0, AppConstants.applicationTitle, body, platformChannelSpecifics);
  }

  static Future<void> showVoiceCallNotification({
    required Uint8List icon,
    required String callerName,
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
            NotificationAction.acceptVoiceCall.id,
            'Accept',
            showsUserInterface: true,
          ),
          AndroidNotificationAction(
            NotificationAction.ignoreVoiceCall.id,
            'Ignore',
          ),
        ],
        ticker: 'Incoming Voice Call',
      ),
    );

    return flutterLocalNotificationsPlugin.show(0, AppConstants.applicationTitle, '$callerName is calling...', platformChannelSpecifics);
  }


  // Show an instant Notification
  static Future<void> showInstantNotification({
    required Uint8List icon,
    required String body,
    required String summaryText,
    required String contentTitle,
    required String contentText,
    required ReplyCallBack replyCallBack,
  }) async {
    NotificationService.replyCallBack = replyCallBack;
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
          NotificationAction.actionReply.id,
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
          NotificationAction.markAsRead.id,
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

    return flutterLocalNotificationsPlugin.show(0, AppConstants.applicationTitle, body, platformChannelSpecifics);
  }

}
