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
import 'dart:io';
import 'dart:typed_data';
import 'package:ermis_client/core/networking/handlers/chat_sessions_service.dart';
import 'package:ermis_client/core/data_sources/api_client.dart';
import 'package:ermis_client/core/networking/common/message_types/content_type.dart';
import 'package:ermis_client/core/networking/common/message_types/message_delivery_status.dart';
import 'package:ermis_client/core/networking/common/results/client_command_result_type.dart';
import 'package:ermis_client/core/data/models/network/byte_buf.dart';
import 'package:ermis_client/core/extensions/iterable_extensions.dart';
import 'package:ermis_client/core/models/message_events.dart';
import 'package:ermis_client/core/networking/message_transmitter.dart';
import 'package:ermis_client/core/models/account.dart';
import 'package:ermis_client/core/models/chat_request.dart';
import 'package:ermis_client/core/models/chat_session.dart';
import 'package:ermis_client/core/models/file_heap.dart';
import 'package:ermis_client/core/models/message.dart';
import 'package:ermis_client/core/models/user_device.dart';
import 'package:ermis_client/core/networking/user_info_manager.dart';
import 'package:ermis_client/core/services/database/database_service.dart';
import 'package:ermis_client/core/networking/common/message_types/client_status.dart';
import '../../event_bus/app_event_bus.dart';
import '../../event_bus/event_bus.dart';
import '../../models/member_icon.dart';

final EventBus _eventBus = AppEventBus.instance;

class CommandResultHandler {
  const CommandResultHandler._();

  static Future<void> handle(ClientCommandResultType commandResult, ByteBuf msg) async {
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
      case ClientCommandResultType.downloadVoice:
        final messageID = msg.readInt32();
        final fileNameLength = msg.readInt32();
        final fileNameBytes = msg.readBytes(fileNameLength);
        final fileBytes = msg.readBytes(msg.readableBytes);

        final file = LoadedInMemoryFile(utf8.decode(fileNameBytes), fileBytes);

        _eventBus.fire(VoiceDownloadedEvent(file, messageID));
        break;
      case ClientCommandResultType.fetchProfileInfo:
        // ClientID
        UserInfoManager.clientID = msg.readInt32();
        _eventBus.fire(ClientIdEvent(UserInfoManager.clientID));

        // Username
        final usernameBytes = msg.readBytes(msg.readInt32());
        UserInfoManager.username = utf8.decode(usernameBytes);
        _eventBus.fire(UsernameReceivedEvent(UserInfoManager.username!));

        int lastUpdatedEpochSecond = msg.readInt64();

        // Profile photo
        UserInfoManager.profilePhoto = msg.readBytes(msg.readableBytes);
        _eventBus.fire(ProfilePhotoEvent(UserInfoManager.profilePhoto!));

        IntermediaryService().addLocalUserInfo(
          server: UserInfoManager.serverInfo,
          info: LocalUserInfo(
            displayName: UserInfoManager.username!,
            clientID: UserInfoManager.clientID,
            profilePhoto: UserInfoManager.profilePhoto!,
            lastUpdatedEpochSecond: lastUpdatedEpochSecond,
          ),
        );
        break;
      case ClientCommandResultType.getDisplayName:
        final usernameBytes = msg.readBytes(msg.readableBytes);
        UserInfoManager.username = utf8.decode(usernameBytes);
        _eventBus.fire(UsernameReceivedEvent(UserInfoManager.username!));
        break;
      case ClientCommandResultType.getClientId:
        UserInfoManager.clientID = msg.readInt32();
        _eventBus.fire(ClientIdEvent(UserInfoManager.clientID));
        break;
      case ClientCommandResultType.fetchAccountStatus:
        UserInfoManager.accountStatus = ClientStatus.fromId(msg.readInt32());
        _eventBus.fire(AccountStatusEvent(UserInfoManager.accountStatus!));
        break;
      case ClientCommandResultType.getChatSessionIndices:
        UserInfoManager.chatSessions = [];

        int i = 0;
        while (msg.readableBytes > 0) {
          int chatSessionIndex = i;
          int chatSessionID = msg.readInt32();

          ChatSession? chatSession = UserInfoManager.chatSessionIDSToChatSessions[chatSessionID];
          if (chatSession == null) {
            chatSession = ChatSession(chatSessionID, chatSessionIndex);
            UserInfoManager.chatSessionIDSToChatSessions[chatSessionID] = chatSession;
          }
          chatSession.chatSessionIndex = i;

          UserInfoManager.chatSessions!.add(chatSession);

          i++;
        }

        _eventBus.fire(ChatSessionsIndicesReceivedEvent(UserInfoManager.chatSessions!));

        Client.instance().commands.fetchChatSessions(); // Proceed to fetching chat sessions
        break;
      case ClientCommandResultType.getChatSessions:
        Map<int, Member> cache = {};

        int i = 0;
        while (msg.readableBytes > 0) {
          int chatSessionIndex = msg.readInt32();
          ChatSession chatSession;

          try {
            chatSession = UserInfoManager.chatSessions![chatSessionIndex];
          } on RangeError {
            continue; // This could happen potentially if this chat session had been cached in local database and when the conditional request was it did not know what to do and it sent -1. Outdated chat sessions will be deleted  after new chat sessions have been processed
          }

          Set<Member> members = chatSession.members.toSet();

          int membersSize = msg.readInt32();
          if (membersSize == -1) {
            // Infer session has been deleted since membersSize is -1

            UserInfoManager.chatSessions!.removeAt(chatSessionIndex);
            UserInfoManager.chatSessionIDSToChatSessions.remove(chatSession.chatSessionID);

            IntermediaryService().deleteChatSession(
              server: UserInfoManager.serverInfo,
              session: chatSession,
            );

            continue;
          }

          for (int j = 0; j < membersSize; j++) {
            int memberID = msg.readInt32();

            Member member;
            if (cache.containsKey(memberID)) {
              member = cache[memberID]!;
            } else {
              int usernameLength = msg.readInt32();
              String username = utf8.decode(msg.readBytes(usernameLength));
              Uint8List iconBytes = msg.readBytes(msg.readInt32());
              int iconLastUpdatedAt = msg.readInt64();

              member = Member(
                username,
                memberID,
                MemberIcon(iconBytes, iconLastUpdatedAt),
                ClientStatus.offline
              );

              cache[memberID] = member;
            }

            members.add(member);
          }

          chatSession.setMembers(members.toList());

          IntermediaryService().insertChatSession(
            server: UserInfoManager.serverInfo,
            session: chatSession,
          );

          i++;
        }
        
        // Delete outdated chat sessions
        for (final session in UserInfoManager.chatSessionIDSToChatSessions.values) {
          if (UserInfoManager.chatSessions!.contains(session)) continue;

          IntermediaryService().deleteChatSession(server: UserInfoManager.serverInfo, session: session);
        }

        _eventBus.fire(ChatSessionsEvent(UserInfoManager.chatSessions!));

        Client.instance().commands.fetchChatSessionsStatuses(); // Proceed to fetching statuses
        break;
      case ClientCommandResultType.getChatSessionStatuses:
        while (msg.readableBytes > 0) {
          int clientID = msg.readInt32();
          ClientStatus status = ClientStatus.fromId(msg.readInt32());  
          
          for (final session in UserInfoManager.chatSessions!) {
            Member? member = session.members.firstWhereOrNull((m) => m.clientID == clientID);

            if (member == null) continue;
            member.status = status;

            break; // Since all chat sessions share identical Member objects, only need to update one
          }
        }
        
        break;
      case ClientCommandResultType.getChatRequests:
        UserInfoManager.chatRequests = [];
        int friendRequestsLength = msg.readInt32();
        for (int i = 0; i < friendRequestsLength; i++) {
          int clientID = msg.readInt32();
          UserInfoManager.chatRequests?.add(ChatRequest(clientID));
        }
        _eventBus.fire(ChatRequestsEvent(UserInfoManager.chatRequests!));
        break;
      case ClientCommandResultType.getOtherAccountsAssociatedWithDevice:
        UserInfoManager.otherAccounts = [];

        while (msg.readableBytes > 0) {
          int clientID = msg.readInt32();
          String email = utf8.decode(msg.readBytes(msg.readInt32()));
          String displayName = utf8.decode(msg.readBytes(msg.readInt32()));
          Uint8List profilePhoto = msg.readBytes(msg.readInt32());

          UserInfoManager.otherAccounts!.add(Account(
              profilePhoto: profilePhoto,
              displayName: displayName,
              email: email,
              clientID: clientID));
        }

        _eventBus.fire(OtherAccountsEvent(UserInfoManager.otherAccounts!));
        break;
      case ClientCommandResultType.getWrittenText:
        int chatSessionIndex = msg.readInt32();
        ChatSession chatSession = UserInfoManager.chatSessions![chatSessionIndex];
        Set<Message> messagesSet = chatSession.messages.toSet();

        while (msg.readableBytes > 0) {
          MessageContentType contentType = MessageContentType.fromId(msg.readInt32());
          int clientID = msg.readInt32();
          int messageID = msg.readInt32();
          String username = utf8.decode(msg.readBytes(msg.readInt32()));

          Uint8List? messageBytes;
          Uint8List? fileNameBytes;
          int epochSecond = msg.readInt64();
          bool isRead;
          if (clientID == UserInfoManager.clientID) {
            isRead = msg.readBoolean();
          } else {
            isRead = true;
          }

          switch (contentType) {
            case MessageContentType.text:
              messageBytes = msg.readBytes(msg.readInt32());
              break;
            case MessageContentType.file || MessageContentType.image || MessageContentType.voice:
              fileNameBytes = msg.readBytes(msg.readInt32());
              break;
          }

          messagesSet.removeWhere((message) => message.messageID == messageID);
          messagesSet.add(Message(
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
                : MessageDeliveryStatus.serverReceived,
          ));
        }

        List<Message> messagesList = messagesSet.toList();
        messagesList.sort((a, b) => a.messageID.compareTo(b.messageID));

        chatSession.setMessages(messagesList);
        chatSession.setHaveChatMessagesBeenCached(true);
        _eventBus.fire(WrittenTextEvent(chatSession));
        break;
      case ClientCommandResultType.deleteChatMessage:
        int chatSessionID = msg.readInt32();  
        while (msg.readableBytes > 0) {
          int messageID = msg.readInt32();
          bool success = msg.readBoolean();

          if (!success) {
            _eventBus.fire(const MessageDeletionUnsuccessfulEvent());
            continue;
          }

          _eventBus.fire(MessageDeletedEvent(UserInfoManager.chatSessionIDSToChatSessions[chatSessionID]!, messageID));
        }
        break;
      case ClientCommandResultType.fetchAccountIcon:
        UserInfoManager.profilePhoto = msg.readBytes(msg.readableBytes);
        _eventBus.fire(ProfilePhotoEvent(UserInfoManager.profilePhoto!));
        break;
      case ClientCommandResultType.fetchUserDevices:
        UserInfoManager.userDevices = [];

        while (msg.readableBytes > 0) {
          DeviceType deviceType = DeviceType.fromId(msg.readInt32());
          String address = utf8.decode(msg.readBytes(msg.readInt32()));
          String osName = utf8.decode(msg.readBytes(msg.readInt32()));
          UserInfoManager.userDevices!.add(UserDeviceInfo(address, deviceType, osName));
        }
        _eventBus.fire(UserDevicesEvent(UserInfoManager.userDevices!));
        break;
      case ClientCommandResultType.setAccountIcon:
        bool isSuccessful = msg.readBoolean();
        if (!isSuccessful) {
          break;
        }
        
        UserInfoManager.profilePhoto = Commands.pendingAccountIcon;
        _eventBus.fire(AddProfilePhotoResultEvent(isSuccessful));
        break;
      case ClientCommandResultType.startVoiceCall:
        int udpServerPort = msg.readInt32();
        int voiceCallKey = msg.readInt32();
        Uint8List aesKey = msg.readBytes(msg.readableBytes);

        RawDatagramSocket socket = await RawDatagramSocket.bind(
          UserInfoManager.serverInfo.address.type,
          0,
        );

        RawSocketEvent event = await socket.first;
        Datagram datagram = socket.receive()!;

        datagram.port;

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
      case ClientCommandResultType.fetchSignallingServerPort:
        int signallingServerPort = msg.readInt32();
        Uint8List aesKey = msg.readBytes(msg.readableBytes);
        _eventBus.fire(SignallingServerPortEvent(signallingServerPort, aesKey));
        break;
    }
  }
}