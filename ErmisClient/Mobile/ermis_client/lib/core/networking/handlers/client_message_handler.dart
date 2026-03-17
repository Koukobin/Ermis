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

import 'dart:convert';
import 'dart:typed_data';
import 'package:ermis_mobile/core/networking/common/message_types/content_type.dart';
import 'package:ermis_mobile/core/networking/common/message_types/message_delivery_status.dart';
import 'package:ermis_mobile/core/data/models/network/byte_buf.dart';
import 'package:ermis_mobile/core/models/message_events.dart';
import 'package:ermis_mobile/core/models/chat_session.dart';
import 'package:ermis_mobile/core/models/message.dart';
import 'package:ermis_mobile/core/networking/user_info_manager.dart';
import '../../event_bus/app_event_bus.dart';

final AppEventBus _eventBus = AppEventBus.instance;

class ClientMessageHandler {
  static void handle(ByteBuf msg) {
    MessageContentType? contentType = MessageContentType.fromId(msg.readInt32());
    int epochSecond = msg.readInt64();

    Map<MessageFields, Uint8List?> fields = {};
    switch (contentType) {
      case MessageContentType.text || MessageContentType.gif:
        var textLength = msg.readInt32();
        Uint8List? text = msg.readBytes(textLength);
        fields[MessageFields.text] = text;
        break;
      case MessageContentType.file ||
            MessageContentType.image ||
            MessageContentType.voice ||
            MessageContentType.video:
        var fileNameLength = msg.readInt32();
        Uint8List? fileNameBytes = msg.readBytes(fileNameLength);
        fields[MessageFields.fileName] = fileNameBytes;
        break;
      case null:
        msg.readBytes(msg.readInt32());
        break;
    }

    int usernameLength = msg.readInt32();
    Uint8List usernameBytes = msg.readBytes(usernameLength);
    String username = utf8.decode(usernameBytes);

    int clientID = msg.readInt32();
    int messageID = msg.readInt32();
    int chatSessionID = msg.readInt32();

    Message message = Message(
      username: username,
      clientID: clientID,
      fields: fields,
      messageID: messageID,
      chatSessionID: chatSessionID,
      chatSessionIndex: UserInfoManager.chatSessionIDSToChatSessions[chatSessionID]!.chatSessionIndex,
      epochSecond: epochSecond,
      contentType: contentType,
      deliveryStatus: clientID == UserInfoManager.clientID
          ? MessageDeliveryStatus.serverReceived
          : MessageDeliveryStatus.delivered,
    );

    ChatSession chatSession = UserInfoManager.chatSessionIDSToChatSessions[chatSessionID]!;
    chatSession.messages.add(message);

    _eventBus.fire(MessageReceivedEvent(message, chatSession));
  }
}
