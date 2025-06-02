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

import 'dart:convert';
import 'dart:math';

import 'package:ermis_client/constants/app_constants.dart';
import 'package:ermis_client/core/data_sources/api_client.dart';
import 'package:ermis_client/core/models/member.dart';
import 'package:ermis_client/core/services/database/extensions/accounts_extension.dart';
import 'package:ermis_client/core/services/database/extensions/servers_extension.dart';
import 'package:ermis_client/core/util/permissions.dart';
import 'package:ermis_client/core/util/transitions_util.dart';
import 'package:ermis_client/features/voice_call/web_rtc/voice_call_webrtc.dart';
import 'package:ermis_client/generated/l10n.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import '../networking/common/message_types/client_status.dart';
import '../services/database/database_service.dart';
import '../services/database/models/local_account_info.dart';
import '../services/database/models/server_info.dart';
import '../services/navigation_service.dart';
import 'dialogs_utils.dart';

typedef ReplyCallBack = void Function(String message);

enum NotificationAction {
  actionReply("action_reply"),
  acceptVoiceCall("accept_voice_call"),
  ignoreVoiceCall("ignore_voice_call"),
  markAsRead("mark_as_read");

  final String id;
  const NotificationAction(this.id);

  static NotificationAction fromId(String id) {
    return NotificationAction.values.firstWhere((type) => type.id == id);
  }
}

ReplyCallBack? _replyCallBack;
VoidCallback? _voiceCall;

@pragma('vm:entry-point')
void onDidReceiveNotification(NotificationResponse response) async {
  String? actionId = response.actionId;
  if (actionId == null) {
    return;
  }

  NotificationAction na = NotificationAction.fromId(actionId);
  switch (na) {
    case NotificationAction.acceptVoiceCall:
      if (response.payload == null || response.payload!.trim().isEmpty) {
        _voiceCall?.call();
        return;
      }

      dynamic data = jsonDecode(response.payload!);

      // Connect to call once flutter has initialized
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final DBConnection conn = ErmisDB.getConnection();
        ServerInfo serverInfo = await conn.getServerUrlLastUsed();

        await Client.instance().initialize(
          serverInfo.serverUrl,
          ServerCertificateVerification.ignore, // Since user connected once he has no issue connecting again
        );

        await Client.instance().readServerVersion();
        Client.instance().startMessageDispatcher();

        LocalAccountInfo? userInfo = await conn.getLastUsedAccount(serverInfo);
        if (userInfo == null) {
          return;
        }

        bool success = await Client.instance().attemptHashedLogin(userInfo);

        if (!success) {
          return;
        }

        await Client.instance().fetchUserInformation();
        Client.instance().commands?.setAccountStatus(ClientStatus.offline);

        showToastDialog(S.current.Connecting);
        showSnackBarDialog(
          context: NavigationService.currentContext,
          content: S.current.Connecting,
        );

        await Future.delayed(const Duration(seconds: 5)); // Await until first screen builds

        pushSlideTransition(
          NavigationService.currentContext,
          VoiceCallWebrtc(
            chatSessionID: data['chatSessionID'],
            chatSessionIndex: data['chatSessionIndex'],
            member: Member.fromJson(jsonDecode(data['member'])),
            isInitiator: data['isInitiator'],
          ),
        );
      });
      break;
    case NotificationAction.ignoreVoiceCall:
      // Do nothing
      break;
    case NotificationAction.actionReply:
      String? input = response.input;
      if (input == null) {
        return;
      }

      _replyCallBack?.call(input);
      break;
    case NotificationAction.markAsRead:
      // To be implemented in the future
      break;
  }
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Initialize the notification plugin
  static Future<void> init() async {
    // Defube the Abdroid initialisation settings
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings("notification_icon");

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

    NotificationAppLaunchDetails? details = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (details != null && details.notificationResponse != null) {
      onDidReceiveNotification(details.notificationResponse!);
    }

    // // Request notification permission for android
    // await flutterLocalNotificationsPlugin
    //     .resolvePlatformSpecificImplementation<
    //         AndroidFlutterLocalNotificationsPlugin>()
    //     ?.requestNotificationsPermission();
  }

  static Future<void> showIconNotification(Uint8List iconBytes, String title, String body) async {
    if (!await checkAndRequestPermission(Permission.notification)) {
      showPermissionDeniedDialog(NavigationService.currentContext, Permission.notification);
      return;
    }

    // Define Notification Details
    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        "icon_notification_id",
        "Icon notification",
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        playSound: false,
        visibility: NotificationVisibility.secret,
        largeIcon: ByteArrayAndroidBitmap(iconBytes),
      ),
    );

    int notificationID = Random().nextInt(10000);
    return flutterLocalNotificationsPlugin.show(notificationID, title, body, platformChannelSpecifics);
  }

  // static Future<void> showIconNotification1(String iconPath, String title, String body) async {
  //   // Define Notification Details
  //   NotificationDetails platformChannelSpecifics = NotificationDetails(
  //     android: AndroidNotificationDetails(
  //       "channelId",
  //       "channelName",
  //       importance: Importance.defaultImportance,
  //       priority: Priority.defaultPriority,
  //       playSound: false,
  //       visibility: NotificationVisibility.secret,
  //       largeIcon: FilePathAndroidBitmap(iconPath),
  //     ),
  //   );
  //   return flutterLocalNotificationsPlugin.show(0, title, body, platformChannelSpecifics);
  // }

  static Future<void> showSimpleNotification({required String body}) async {
    if (!await checkAndRequestPermission(Permission.notification)) {
      showPermissionDeniedDialog(NavigationService.currentContext, Permission.notification);
      return;
    }

    // Define Notification Details
    NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: AndroidNotificationDetails(
      'simple_notification_channel_id', // Channel ID
      'Simple notification', // Channel Name
      channelDescription: 'Simple notification',
      importance: Importance.high,
      priority: Priority.high,
      playSound: false,
      additionalFlags: Int32List.fromList(<int>[4]), // Optional, custom flags
      visibility: NotificationVisibility.secret,
      ticker: 'ticker',
    ));

    int notificationID = Random().nextInt(10000);
    return flutterLocalNotificationsPlugin.show(notificationID, AppConstants.applicationTitle, body, platformChannelSpecifics);
  }

  static Future<int> showVoiceCallNotification({
    required Uint8List icon,
    required String callerName,
    required VoidCallback onAccept,
    String? payload,
  }) async {
    if (!await checkAndRequestPermission(Permission.notification)) {
      showPermissionDeniedDialog(NavigationService.currentContext, Permission.notification);
      return -1;
    }

    _voiceCall = onAccept;
    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        'voice_call_channel_id',
        'Voice Call Notifications', 
        channelDescription: 'Channel for incoming calls',
        importance: Importance.high,
        priority: Priority.high,
        // largeIcon: ByteArrayAndroidBitmap(icon), For some reason causes notification not to show in release mode
        ongoing: true, // Keeps the notification persistent
        autoCancel: false, // Prevents swiping it away
        playSound: true,
        fullScreenIntent: true, // Ensures it's shown prominently
        additionalFlags: Int32List.fromList(<int>[4]), // Optional, custom flags
        actions: [
          AndroidNotificationAction(
            NotificationAction.acceptVoiceCall.id,
            'Accept',
            showsUserInterface: true, // Brings UI to the foreground
            titleColor: AppConstants.darkAppColors.primaryColor,
          ),
          AndroidNotificationAction(
            NotificationAction.ignoreVoiceCall.id,
            'Ignore',
            titleColor: AppConstants.darkAppColors.primaryColor,
          ),
        ],
        ticker: 'Incoming Voice Call',
      ),
    );

    int notificationID = Random().nextInt(10000);
    await flutterLocalNotificationsPlugin.show(notificationID, AppConstants.applicationTitle, '$callerName is calling...', platformChannelSpecifics, payload: payload);

    return notificationID;
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
    if (!await checkAndRequestPermission(Permission.notification)) {
      showPermissionDeniedDialog(NavigationService.currentContext, Permission.notification);
      return;
    }

    _replyCallBack = replyCallBack;
    NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: AndroidNotificationDetails(
      'instant_notification_id',
      'Instant Notification',
      channelDescription: 'Channel for incoming notifications',
      importance: Importance.high,
      priority: Priority.high,
      // largeIcon: ByteArrayAndroidBitmap(icon), For some reason causes notification not to show in release mode
      additionalFlags: Int32List.fromList(<int>[4]),
      playSound: false,
      visibility: NotificationVisibility.secret,
      // enableVibration: true,
      // vibrationPattern: Int64List.fromList([500, 500, 200, 500, 200, 500]),
      actions: [
        AndroidNotificationAction(
          NotificationAction.actionReply.id,
          'Reply',
          icon: DrawableResourceAndroidBitmap('notification_icon'),
          titleColor: AppConstants.darkAppColors.primaryColor,
          inputs: [
            AndroidNotificationActionInput(
              label: 'Type your reply...',
            ),
          ],
        ),
        AndroidNotificationAction(
          NotificationAction.markAsRead.id,
          'Mark as Read',
          titleColor: AppConstants.darkAppColors.primaryColor,
        ),
      ],
      styleInformation: BigTextStyleInformation(
        contentText,
        contentTitle: contentTitle,
        summaryText: summaryText,
      ),
      ticker: 'ticker',
    ));

    int notificationID = Random().nextInt(10000);
    return flutterLocalNotificationsPlugin.show(notificationID, AppConstants.applicationTitle, body, platformChannelSpecifics);
  }

  static Future<void> cancelNotification(int notificationID) {
    return flutterLocalNotificationsPlugin.cancel(notificationID);
  }
}
