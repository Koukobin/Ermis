import 'dart:typed_data';

import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:vibration/vibration.dart';

import '../../client/common/message_types/content_type.dart';
import '../../languages/generated/l10n.dart';
import '../models/chat_session.dart';
import '../models/message.dart';
import '../services/settings_json.dart';
import 'notifications_util.dart';

void handleChatMessageNotification(ChatSession chatSession, Message msg, SettingsJson settingsJson, ReplyCallBack replyCallBack) {
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
      NotificationService.showSimpleNotification(body: S.current.new_message);
      return;
    }

    String body;
    switch (msg.contentType) {
      case MessageContentType.text:
        body = msg.text;
        break;
      case MessageContentType.file || MessageContentType.image:
        body = S.current.file_received(msg.fileName);
        break;
    }

  Uint8List transmitterProfilePhoto = chatSession.getMembers
      .where((Member m) => msg.clientID == m.clientID)
      .first
      .icon
      .profilePhoto;
  NotificationService.showInstantNotification(
    icon: transmitterProfilePhoto,
    body: S.current.message_by(msg.username),
    contentText: body,
    contentTitle: msg.username,
    summaryText: chatSession.toString(),
    replyCallBack: replyCallBack,
  );
}
