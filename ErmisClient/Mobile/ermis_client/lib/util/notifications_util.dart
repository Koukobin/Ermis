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

import 'dart:typed_data';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> onDidReceiveNotification(NotificationResponse response) async {
    // Not need for now
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

  // Show an instant Notification
  static Future<void> showInstantNotification(String title, String body) async {
    // Define Notification Details
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        "channelId",
        "channelName",
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
    );

    return flutterLocalNotificationsPlugin.show(0, title, body, platformChannelSpecifics);
  }

}
