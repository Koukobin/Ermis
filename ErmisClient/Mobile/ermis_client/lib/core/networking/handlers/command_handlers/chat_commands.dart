/* Copyright (C) 2026 Ilias Koukovinis <ilias.koukovinis@gmail.com>
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

import '../../../data/models/network/byte_buf.dart';
import '../../../event_bus/app_event_bus.dart';
import '../../../models/chat_request.dart';
import '../../../models/chat_session.dart';
import '../../../models/message.dart';
import '../../../models/message_events.dart';
import '../../../models/voice_call_history.dart';
import '../../common/message_types/content_type.dart';
import '../../common/message_types/message_delivery_status.dart';
import '../../common/message_types/voice_call_history_status.dart';
import '../../user_info_manager.dart';

final AppEventBus _eventBus = AppEventBus.instance;

mixin ChatCommands {
  void getWrittenText(ByteBuf msg) {
    int chatSessionIndex = msg.readInt32();
    ChatSession chatSession = UserInfoManager.chatSessions![chatSessionIndex];
    Set<Message> messagesSet = chatSession.messages.toSet();

    while (msg.readableBytes > 0) {
      MessageContentType? contentType = MessageContentType.fromId(msg.readInt32());
      int senderClientID = msg.readInt32();
      int messageID = msg.readInt32();

      String username;

      Uint8List? messageBytes;
      Uint8List? fileNameBytes;

      int epochSecond = msg.readInt64();

      bool isRead;
      if (senderClientID == UserInfoManager.clientID) {
        isRead = msg.readBoolean();
        username = UserInfoManager.username!;
      } else {
        isRead = true;
        username = chatSession.members
            .firstWhere((member) => member.clientID == senderClientID)
            .username;
      }

      switch (contentType) {
        case MessageContentType.text || MessageContentType.gif:
          messageBytes = msg.readBytes(msg.readInt32());
          break;
        case MessageContentType.file ||
              MessageContentType.image ||
              MessageContentType.voice ||
              MessageContentType.video:
          fileNameBytes = msg.readBytes(msg.readInt32());
          break;
        case null:
          msg.readBytes(msg.readInt32());
          break;
      }

      messagesSet.removeWhere((message) => message.messageID == messageID);
      messagesSet.add(Message(
        username: username,
        clientID: senderClientID,
        messageID: messageID,
        chatSessionID: chatSession.chatSessionID,
        chatSessionIndex: chatSessionIndex,
        fields: {
          MessageFields.text: messageBytes,
          MessageFields.fileName: fileNameBytes,
        },
        epochSecond: epochSecond,
        contentType: contentType,
        deliveryStatus: isRead
            ? MessageDeliveryStatus.delivered
            : MessageDeliveryStatus.serverReceived,
      ));
    }

    List<Message> messagesList = messagesSet.toList();
    messagesList.sort((a, b) => a.messageID.compareTo(b.messageID));

    chatSession.setMessages(messagesList);
    chatSession.setHasLatestMessages(true);
    _eventBus.fire(WrittenTextEvent(chatSession));
  }

  void deleteChatMessage(ByteBuf msg) {
    int chatSessionID = msg.readInt32();  
    while (msg.readableBytes > 0) {
      int messageID = msg.readInt32();
      bool success = msg.readBoolean();

      if (!success) {
        _eventBus.fire(const MessageDeletionUnsuccessfulEvent());
        continue;
      }

      UserInfoManager.chatSessionIDSToChatSessions[chatSessionID]!
        .messages.removeWhere((Message message) => message.messageID == messageID);

      _eventBus.fire(MessageDeletedEvent(UserInfoManager.chatSessionIDSToChatSessions[chatSessionID]!, messageID));
    }
  }

  void getChatRequests(ByteBuf msg) {
    UserInfoManager.chatRequests = [];

    int friendRequestsLength = msg.readInt32();
    for (int i = 0; i < friendRequestsLength; i++) {
      int clientID = msg.readInt32();
      UserInfoManager.chatRequests!.add(ChatRequest(clientID));
    }

    _eventBus.fire(ChatRequestsEvent(UserInfoManager.chatRequests!));
  }

  void fetchVoiceCallHistory(ByteBuf msg) {
    int chatSessionID = msg.readInt32();

    List<VoiceCallHistory>? callsHistory = UserInfoManager.chatSessionIDSToVoiceCallHistory[chatSessionID];
    callsHistory ??= [];
    callsHistory.clear();

    ChatSession chatSession = UserInfoManager.chatSessionIDSToChatSessions[chatSessionID]!;
    while (msg.readableBytes > 0) {
      int initiatorClientID = msg.readInt32();
      int tsDebuted = msg.readInt64();
      int tsEnded = msg.readInt64();
      VoiceCallHistoryStatus status = VoiceCallHistoryStatus.fromId(msg.readInt32());

      String callerUsername;
      if (initiatorClientID == UserInfoManager.clientID) {
        callerUsername = UserInfoManager.username!;
      } else {
        callerUsername = chatSession.members
          .firstWhere((member) => member.clientID == initiatorClientID)
          .username;
      }

      VoiceCallHistory callHistory = VoiceCallHistory(
        chatSessionID: chatSessionID,
        initiatorClientID: initiatorClientID,
        callerUsername: callerUsername,
        tsDebuted: tsDebuted,
        tsEnded: tsEnded,
        status: status,
      );

      callsHistory.add(callHistory);
    }

    callsHistory.sort((a, b) => a.tsDebuted.compareTo(b.tsDebuted));

    UserInfoManager.chatSessionIDSToVoiceCallHistory[chatSessionID] = callsHistory;

    _eventBus.fire(VoiceCallHistoryReceivedEvent(
      chatSessionID: chatSessionID,
      history: callsHistory,
    ));
  }
}