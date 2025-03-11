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

import 'package:ermis_client/client/app_event_bus.dart';
import 'package:ermis_client/client/common/account.dart';
import 'package:ermis_client/client/common/chat_request.dart';
import 'package:ermis_client/client/common/chat_session.dart';
import 'package:ermis_client/client/common/file_heap.dart';
import 'package:ermis_client/client/common/message.dart';
import 'package:ermis_client/client/common/message_types/content_type.dart';
import 'package:ermis_client/client/common/message_types/message_delivery_status.dart';
import 'package:ermis_client/client/common/results/client_command_result_type.dart';
import 'package:ermis_client/client/common/user_device.dart';
import 'package:ermis_client/client/event_bus.dart';
import 'package:ermis_client/client/io/byte_buf.dart';
import 'package:ermis_client/client/message_events.dart';
import 'package:ermis_client/client/message_handler.dart';

final EventBus _eventBus = AppEventBus.instance;

class MessageDeliveryStatusHandler {
  static void handle(ByteBuf msg) {
    MessageDeliveryStatus status = MessageDeliveryStatus.fromId(msg.readInt32());

    Message pendingMessage;
    
    if (status == MessageDeliveryStatus.lateDelivered) {
      int chatSessionID = msg.readInt32();
      int generatedMessageID = msg.readInt32();

      pendingMessage = Info.chatSessionIDSToChatSessions[chatSessionID]!
          .getMessages
          .firstWhere((m) => m.messageID == generatedMessageID);
    } else if (status == MessageDeliveryStatus.rejected) {
      int tempMessageID = msg.readInt32();
      pendingMessage = Info.pendingMessagesQueue.remove(tempMessageID)!;
    } else {
      int tempMessageID = msg.readInt32();
      int generatedMessageID = msg.readInt32();

      pendingMessage = Info.pendingMessagesQueue[tempMessageID]!;
      if (status == MessageDeliveryStatus.delivered) {
        Info.pendingMessagesQueue.remove(tempMessageID)!;
      }

      pendingMessage.setMessageID(generatedMessageID);
    }

    pendingMessage.setDeliveryStatus(status);

    _eventBus.fire(MessageDeliveryStatusEvent(
      deliveryStatus: status,
      message: pendingMessage,
    ));
  }
}

class VoiceCallHandler {
  static void handle(ByteBuf msg) {
    int udpServerPort = msg.readInt32();
    int chatSessionID = msg.readInt32();
    int voiceCallKey = msg.readInt32();
    int clientID = msg.readInt32();
    // Uint8List aesKey = msg.readBytes(msg.readableBytes);

    ChatSession session = Info.chatSessionIDSToChatSessions[chatSessionID]!;

    Member? member;
    for (var j = 0; j < session.getMembers.length; j++) {
      if (session.getMembers[j].clientID == clientID) {
        member = session.getMembers[j];
      }
    }

    if (member == null) throw new Exception("What the fuck is this");

    _eventBus.fire(VoiceCallIncomingEvent(
      chatSessionID: chatSessionID,
      chatSessionIndex: session.chatSessionIndex,
      voiceCallKey: voiceCallKey,
      member: member,
      udpServerPort: udpServerPort,
    ));
  }
}

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

    var usernameLength = msg.readInt32();
    var usernameBytes = msg.readBytes(usernameLength);
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

class CommandResultHandler {
  const CommandResultHandler._();

  static void handle(ClientCommandResultType commandResult, ByteBuf msg) {
    switch (commandResult) {
      case ClientCommandResultType.downloadFile:
        final fileNameLength = msg.readInt32();
        final fileNameBytes = msg.readBytes(fileNameLength);
        final fileBytes = msg.readBytes(msg.readableBytes);

        final file = LoadedInMemoryFile(utf8.decode(fileNameBytes), fileBytes);

        _eventBus.fire(FileDownloadedEvent(file));
        break;
      case ClientCommandResultType.downloadImage:
        final messageID = msg.readInt32();
        final fileNameLength = msg.readInt32();
        final fileNameBytes = msg.readBytes(fileNameLength);
        final fileBytes = msg.readBytes(msg.readableBytes);

        final file = LoadedInMemoryFile(utf8.decode(fileNameBytes), fileBytes);

        _eventBus.fire(ImageDownloadedEvent(file, messageID));
        break;
      case ClientCommandResultType.getDisplayName:
        var usernameBytes = msg.readBytes(msg.readableBytes);
        Info.username = String.fromCharCodes(usernameBytes);
        _eventBus.fire(UsernameReceivedEvent(Info.username!));
        break;

      case ClientCommandResultType.getClientId:
        Info.clientID = msg.readInt32();
        _eventBus.fire(ClientIdEvent(Info.clientID));
        break;
      case ClientCommandResultType.getChatSessions:
        Info.chatSessions = [];

        int chatSessionsSize = msg.readInt32();
        for (int i = 0; i < chatSessionsSize; i++) {
          int chatSessionIndex = i;
          int chatSessionID = msg.readInt32();

          ChatSession chatSession = ChatSession(chatSessionID, chatSessionIndex);

          int membersSize = msg.readInt32();
          List<Member> members = <Member>[];
          for (int j = 0; j < membersSize; j++) {
            int memberClientID = msg.readInt32();
            bool isActive = msg.readBoolean();
            int usernameLength = msg.readInt32();
            String username = utf8.decode(msg.readBytes(usernameLength));
            Uint8List iconBytes = msg.readBytes(msg.readInt32());

            members.add(Member(username, memberClientID, iconBytes, isActive));
          }

          chatSession.setMembers(members);
          Info.chatSessions?.insert(chatSessionIndex, chatSession);
          Info.chatSessionIDSToChatSessions[chatSessionID] = chatSession;
        }
        _eventBus.fire(ChatSessionsEvent(Info.chatSessions!));
        break;
      case ClientCommandResultType.getChatRequests:
        Info.chatRequests = [];
        int friendRequestsLength = msg.readInt32();
        for (int i = 0; i < friendRequestsLength; i++) {
          int clientID = msg.readInt32();
          Info.chatRequests?.add(ChatRequest(clientID));
        }
        _eventBus.fire(ChatRequestsEvent(Info.chatRequests!));
        break;
      case ClientCommandResultType.getOtherAccountsAssociatedWithDevice:
        Info.otherAccounts = [];

        while (msg.readableBytes > 0) {
          int clientID = msg.readInt32();
          String email = utf8.decode(msg.readBytes(msg.readInt32()));
          String displayName = utf8.decode(msg.readBytes(msg.readInt32()));
          Uint8List profilePhoto = msg.readBytes(msg.readInt32());

          Info.otherAccounts!.add(Account(
              profilePhoto: profilePhoto,
              displayName: displayName,
              email: email,
              clientID: clientID));
        }

        _eventBus.fire(OtherAccountsEvent(Info.otherAccounts!));
        break;
      case ClientCommandResultType.getWrittenText:
        int chatSessionIndex = msg.readInt32();
        ChatSession chatSession = Info.chatSessions![chatSessionIndex];
        List<Message> messages = chatSession.getMessages;

        while (msg.readableBytes > 0) {
          MessageContentType contentType = MessageContentType.fromId(msg.readInt32());
          int clientID = msg.readInt32();
          int messageID = msg.readInt32();
          String username = utf8.decode(msg.readBytes(msg.readInt32()));

          Uint8List? messageBytes;
          Uint8List? fileNameBytes;
          int epochSecond = msg.readInt64();
          bool isRead;
          if (clientID == Info.clientID) {
            isRead = msg.readBoolean();
          } else {
            isRead = true;
          }

          switch (contentType) {
            case MessageContentType.text:
              messageBytes = msg.readBytes(msg.readInt32());
              break;
            case MessageContentType.file || MessageContentType.image:
              fileNameBytes = msg.readBytes(msg.readInt32());
              break;
          }

          messages.add(Message(
              username: username,
              clientID: clientID,
              messageID: messageID,
              chatSessionID: chatSession.chatSessionID,
              chatSessionIndex: chatSessionIndex,
              text: messageBytes,
              fileName: fileNameBytes,
              epochSecond: epochSecond,
              contentType: contentType,
              deliveryStatus: isRead
                  ? MessageDeliveryStatus.delivered
                  : MessageDeliveryStatus.serverReceived));
        }

        messages.sort((a, b) => a.messageID.compareTo(b.messageID));
        chatSession.setHaveChatMessagesBeenCached(true);
        _eventBus.fire(WrittenTextEvent(chatSession));
        break;
      case ClientCommandResultType.deleteChatMessage:
        int chatSessionID = msg.readInt32();  
        while (msg.readableBytes > 0) {
          int messageID = msg.readInt32();
          bool success = msg.readBoolean();

          if (!success) {
            _eventBus.fire(MessageDeletionUnsuccessfulEvent());
            continue;
          }

          _eventBus.fire(MessageDeletedEvent(Info.chatSessionIDSToChatSessions[chatSessionID]!, messageID));
        }
        break;
      case ClientCommandResultType.fetchAccountIcon:
        Info.profilePhoto = msg.readBytes(msg.readableBytes);
        _eventBus.fire(ProfilePhotoEvent(Info.profilePhoto!));
        break;
      case ClientCommandResultType.fetchUserDevices:
        Info.userDevices.clear();
        while (msg.readableBytes > 0) {
          DeviceType deviceType = DeviceType.fromId(msg.readInt32());
          String address = utf8.decode(msg.readBytes(msg.readInt32()));
          String osName = utf8.decode(msg.readBytes(msg.readInt32()));
          Info.userDevices.add(UserDeviceInfo(address, deviceType, osName));
        }
        _eventBus.fire(UserDevicesEvent(Info.userDevices));
        break;
      case ClientCommandResultType.setAccountIcon:
        bool isSuccessful = msg.readBoolean();
        if (!isSuccessful) {
          break;
        }
        
        Info.profilePhoto = Commands.pendingAccountIcon;
        _eventBus.fire(AddProfilePhotoResultEvent(isSuccessful));
        break;
      case ClientCommandResultType.startVoiceCall:
        int udpServerPort = msg.readInt32();
        int voiceCallKey = msg.readInt32();
        // Uint8List aesKey = msg.readBytes(msg.readableBytes);
        _eventBus.fire(StartVoiceCallResultEvent(voiceCallKey, udpServerPort));
        break;
      case ClientCommandResultType.getDonationPageURL:
        Uint8List donationPageURL = msg.readBytes(msg.readableBytes);
        _eventBus.fire(DonationPageEvent(utf8.decode(donationPageURL)));
        break;
      case ClientCommandResultType.getSourceCodePageURL:
        Uint8List sourceCodePageURL = msg.readBytes(msg.readableBytes);
        _eventBus.fire(SourceCodePageEvent(utf8.decode(sourceCodePageURL)));
        break;
    }
  }
}