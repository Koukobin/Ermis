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
import 'package:ermis_client/client/common/message_types/content_type.dart';
import 'package:ermis_client/client/common/message_types/message_delivery_status.dart';
import 'package:ermis_client/client/io/byte_buf.dart';
import 'package:ermis_client/core/models/message_events.dart';
import 'package:ermis_client/client/message_handler.dart';
import 'package:ermis_client/core/models/chat_session.dart';
import 'package:ermis_client/core/models/message.dart';
import '../../core/event_bus/app_event_bus.dart';
import '../../core/event_bus/event_bus.dart';

final EventBus _eventBus = AppEventBus.instance;

class ClientMessageHandler {
  static void handle(ByteBuf msg) {
    Message message = Message.empty();

    MessageContentType contentType = MessageContentType.fromId(msg.readInt32());
    int epochSecond = msg.readInt64();

    Uint8List? text;
    Uint8List? fileNameBytes;
    switch (contentType) {
      case MessageContentType.text:
        var textLength = msg.readInt32();
        text = msg.readBytes(textLength);
        break;
      case MessageContentType.file || MessageContentType.image:
        var fileNameLength = msg.readInt32();
        fileNameBytes = msg.readBytes(fileNameLength);
        break;
    }

    int usernameLength = msg.readInt32();
    Uint8List usernameBytes = msg.readBytes(usernameLength);
    String username = utf8.decode(usernameBytes);

    int clientID = msg.readInt32();
    int messageID = msg.readInt32();
    int chatSessionID = msg.readInt32();

    message.setContentType(contentType);
    message.setUsername(username);
    message.setClientID(clientID);
    message.setMessageID(messageID);
    message.setChatSessionID(chatSessionID);
    message.setChatSessionIndex(
        Info.chatSessionIDSToChatSessions[chatSessionID]!.chatSessionIndex);
    message.setText(text);
    message.setFileName(fileNameBytes);
    message.setEpochSecond(epochSecond);
    message.setDeliveryStatus(MessageDeliveryStatus.delivered);

    ChatSession chatSession = Info.chatSessionIDSToChatSessions[chatSessionID]!;
    if (chatSession.haveChatMessagesBeenCached) {
      chatSession.getMessages.add(message);
    }

    _eventBus.fire(MessageReceivedEvent(message, chatSession));
  }
}
