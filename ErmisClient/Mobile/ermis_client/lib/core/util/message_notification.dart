import 'dart:typed_data';

import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:vibration/vibration.dart';

import '../../client/common/message_types/content_type.dart';
import '../../generated/l10n.dart';
import '../models/chat_session.dart';
import '../models/message.dart';
import '../services/settings_json.dart';
import 'notifications_util.dart';

void handleChatMessageNotificationForeground(ChatSession chatSession, Message msg, SettingsJson settingsJson, ReplyCallBack replyCallBack) {
  handleChatMessageNotification(
    chatSession,
    msg,
    settingsJson,
    replyCallBack,
    newMessage: S.current.new_message,
    fileReceived: S.current.file_received(msg.fileName),
    messagBy: S.current.message_by(msg.username),
  );
}

/// For some reason, you cannot directly use and access [S] within the background service, since it relys 
/// on flutter_localizations, which in turn, its underlying mechanisms, rely on the Flutter framework's 
/// initialized state within the main isolate. The [S] class is set up during the initialization of the 
/// localization delegates within the main isolate's [MaterialApp]. If the main isolate is gone, this 
/// initialization never happened or is no longer valid. Hence, the following method.
void handleChatMessageNotificationBackground(ChatSession chatSession, Message msg, SettingsJson settingsJson, ReplyCallBack replyCallBack) {
  handleChatMessageNotification(
    chatSession,
    msg,
    settingsJson,
    replyCallBack,
    newMessage: "New Message",
    fileReceived: "File Received",
    messagBy: "Message By",
  );
}

void handleChatMessageNotification(ChatSession chatSession, Message msg, SettingsJson settingsJson, ReplyCallBack replyCallBack, {
  required String newMessage,
  required String fileReceived,
  required String messagBy,
}) {
  if (settingsJson.vibrationEnabled) {
    Vibration.vibrate();
  }

  if (!settingsJson.notificationsEnabled) {
    return;
  }

  switch (settingsJson.notificationSound) {
    case NotificationSound.osDefault:
      FlutterRingtonePlayer().playNotification();
    case NotificationSound.ermis:
      FlutterRingtonePlayer().play(fromAsset: "assets/sounds/ermis_notification.wav");
  }

  if (!settingsJson.showMessagePreview) {
    NotificationService.showSimpleNotification(body: newMessage);
    return;
  }

  String body;
  switch (msg.contentType) {
    case MessageContentType.text:
      body = msg.text;
      break;
    case MessageContentType.file ||
          MessageContentType.image ||
          MessageContentType.voice:
      body = fileReceived;
      break;
  }

  Uint8List transmitterProfilePhoto = chatSession.getMembers
      .where((Member m) => msg.clientID == m.clientID)
      .first
      .icon
      .profilePhoto;
  NotificationService.showInstantNotification(
    icon: transmitterProfilePhoto,
    body: messagBy,
    contentText: body,
    contentTitle: msg.username,
    summaryText: chatSession.toString(),
    replyCallBack: replyCallBack,
  );
}
