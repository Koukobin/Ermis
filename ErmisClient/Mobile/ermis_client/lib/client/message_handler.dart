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
import 'dart:io';

import 'package:ermis_client/client/app_event_bus.dart';
import 'package:ermis_client/client/common/message_types/message_delivery_status.dart';
import 'package:ermis_client/client/message_events.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'client.dart';
import 'common/account.dart';
import 'common/message_types/client_command_type.dart';
import 'common/message_types/client_message_type.dart';
import 'common/message_types/server_message_type.dart';
import 'common/message_types/content_type.dart';
import 'common/results/client_command_result_type.dart';
import 'common/user_device.dart';
import 'event_bus.dart';
import 'io/byte_buf.dart';
import 'common/chat_request.dart';
import 'common/chat_session.dart';
import 'common/file_heap.dart';
import 'io/input_stream.dart';
import 'common/message.dart';
import 'io/output_stream.dart';

class MessageHandler {
  late final ByteBufInputStream _inputStream;
  late final ByteBufOutputStream _outputStream;
  late final Socket _socket;

  final Map<int /* temporary message id */, Message> pendingMessagesQueue = {};
  int lastPendingMessageID = 0;

  String? _username;
  int clientID = -1;
  Uint8List? _profilePhoto;
  final List<UserDeviceInfo> _userDevices = [];

  final Map<int, ChatSession> _chatSessionIDSToChatSessions = {};
  List<ChatSession>? _chatSessions;
  List<ChatRequest>? _chatRequests;
  List<Account>? _otherAccounts;

  bool _isClientListeningToMessages = false;

  late final Commands _commands;
  final EventBus eventBus = AppEventBus.instance;

  MessageHandler();

  void setByteBufInputStream(ByteBufInputStream inputStream) {
    _inputStream = inputStream;
  }

  void setByteBufOutputStream(ByteBufOutputStream outputStream) {
    _outputStream = outputStream;
    _commands = Commands(_outputStream);
  }

  void setSocket(Socket secureSocket) {
    _socket = secureSocket;
  }

  Message sendMessageToClient(String text, int chatSessionIndex) {
    Uint8List textBytes = utf8.encode(text);

    ByteBuf payload = ByteBuf.smallBuffer(growable: true);
    payload.writeInt32(ClientMessageType.clientContent.id);
    payload.writeInt32(++lastPendingMessageID);
    payload.writeInt32(MessageContentType.text.id);
    payload.writeInt32(chatSessionIndex);
    payload.writeInt32(textBytes.length);
    payload.writeBytes(textBytes);

    _outputStream.write(payload);

    return createPendingMessage(
      text: Uint8List.fromList(utf8.encode(text)),
      contentType: MessageContentType.text,
      chatSessionID: _chatSessions![chatSessionIndex].chatSessionID,
      chatSessionIndex: chatSessionIndex,
      tempMessageID: lastPendingMessageID,
    );
  }

  Message sendFileToClient(String fileName, Uint8List fileContentBytes, int chatSessionIndex) {
    Uint8List fileNameBytes = utf8.encode(fileName);

    // Calculate the payload size in advance for efficiency
    int payloadSize = 20 + fileNameBytes.length + fileContentBytes.length;

    ByteBuf payload = ByteBuf(payloadSize);
    payload.writeInt32(ClientMessageType.clientContent.id);
    payload.writeInt32(++lastPendingMessageID);
    payload.writeInt32(MessageContentType.file.id);
    payload.writeInt32(chatSessionIndex);
    payload.writeInt32(fileNameBytes.length);
    payload.writeBytes(fileNameBytes);
    payload.writeBytes(fileContentBytes);

    _outputStream.write(payload);

    return createPendingMessage(
      fileName: Uint8List.fromList(utf8.encode(fileName)),
      contentType: MessageContentType.file,
      chatSessionID: _chatSessions![chatSessionIndex].chatSessionID,
      chatSessionIndex: chatSessionIndex,
      tempMessageID: lastPendingMessageID,
    );
  }

  Message sendImageToClient(String fileName, Uint8List fileContentBytes, int chatSessionIndex) {
    Uint8List fileNameBytes = utf8.encode(fileName);

    // Calculate the payload size in advance for efficiency
    int payloadSize = 20 + fileNameBytes.length + fileContentBytes.length;
    
    ByteBuf payload = ByteBuf(payloadSize);
    payload.writeInt32(ClientMessageType.clientContent.id);
    payload.writeInt32(++lastPendingMessageID);
    payload.writeInt32(MessageContentType.image.id);
    payload.writeInt32(chatSessionIndex);
    payload.writeInt32(fileNameBytes.length);
    payload.writeBytes(fileNameBytes);
    payload.writeBytes(fileContentBytes);

    _outputStream.write(payload);

    return createPendingMessage(
      fileName: Uint8List.fromList(utf8.encode(fileName)),
      contentType: MessageContentType.image,
      chatSessionID: _chatSessions![chatSessionIndex].chatSessionID,
      chatSessionIndex: chatSessionIndex,
      tempMessageID: lastPendingMessageID,
    );
  }

    Message createPendingMessage({
    Uint8List? text,
    Uint8List? fileName,
    required MessageContentType contentType,
    required int chatSessionID,
    required int chatSessionIndex,
    required int tempMessageID,
  }) {
    final m = Message(
        text: text,
        fileName: fileName,
        username: Client.instance().displayName!,
        clientID: Client.instance().clientID,
        messageID: -1,
        chatSessionID: chatSessionID,
        chatSessionIndex: chatSessionIndex,
        epochSecond: (DateTime.now().millisecondsSinceEpoch / 1000).toInt(),
        contentType: contentType,
        deliveryStatus: MessageDeliveryStatus.sending);
    
    pendingMessagesQueue[lastPendingMessageID] = m;
    return m;
  }

  Future<void> fetchUserInformation() async {
    commands.fetchUsername();
    commands.fetchClientID();
    commands.fetchChatSessions();
    commands.fetchChatRequests();
    commands.fetchDevices();
    commands.fetchAccountIcon();
    commands.fetchOtherAccountsAssociatedWithDevice();

    // Block until requested information has been fetched
    await Future.doWhile(() async {
      return await Future.delayed(Duration(milliseconds: 100), () {
        return (username == null ||
            _profilePhoto == null ||
            chatRequests == null ||
            chatSessions == null);
      });
    });
  }

  Future<void> startListeningToMessages() async {
    if (isListeningToMessages) {
      if (kDebugMode) {
        debugPrint("Already listening to messages");
      }
      return; // Do nothing
    }

    _isClientListeningToMessages = true;

    _inputStream.stream.listen(
      (Uint8List data) async {
        ByteBuf message = await ByteBufInputStream.decodeSimple(data);
        if (message.capacity > 0) {
          handleMessage(message);
        }
      },
      onDone: () {
        _socket.destroy();
        SystemNavigator.pop();
      },
      onError: (e) {
        if (kDebugMode) {
          debugPrint(e.toString());
        }
      },
    );
  }

  void handleMessage(ByteBuf msg) {
    void handleCommandResult(ClientCommandResultType commandResult) {
      switch (commandResult) {
        case ClientCommandResultType.downloadFile:
          var fileNameLength = msg.readInt32();
          var fileNameBytes = msg.readBytes(fileNameLength);
          var fileBytes = msg.readBytes(msg.readableBytes);

          final file = LoadedInMemoryFile(String.fromCharCodes(fileNameBytes), fileBytes);

          eventBus.fire(FileDownloadedEvent(file));
          break;
        case ClientCommandResultType.downloadImage:
          var messageID = msg.readInt32();
          var fileNameLength = msg.readInt32();
          var fileNameBytes = msg.readBytes(fileNameLength);
          var fileBytes = msg.readBytes(msg.readableBytes);

          var file = LoadedInMemoryFile(
              String.fromCharCodes(fileNameBytes), fileBytes);

          eventBus.fire(ImageDownloadedEvent(file, messageID));
          break;
        case ClientCommandResultType.getDisplayName:
          var usernameBytes = msg.readBytes(msg.readableBytes);
          _username = String.fromCharCodes(usernameBytes);
          eventBus.fire(UsernameReceivedEvent(_username!));
          break;

        case ClientCommandResultType.getClientId:
          clientID = msg.readInt32();
          eventBus.fire(ClientIdEvent(clientID));
          break;
        case ClientCommandResultType.getChatSessions:
          _chatSessions = [];
          int chatSessionsSize = msg.readInt32();
          for (int i = 0; i < chatSessionsSize; i++) {
            int chatSessionIndex = i;
            int chatSessionID = msg.readInt32();

            ChatSession chatSession =
                ChatSession(chatSessionID, chatSessionIndex);

            int membersSize = msg.readInt32();
            List<Member> members = <Member>[];
            for (int j = 0; j < membersSize; j++) {
              int memberClientID = msg.readInt32();
              bool isActive = msg.readBoolean();
              int usernameLength = msg.readInt32();
              String username =
                  String.fromCharCodes(msg.readBytes(usernameLength));
              Uint8List iconBytes = msg.readBytes(msg.readInt32());

              members
                  .add(Member(username, memberClientID, iconBytes, isActive));
            }

            chatSession.setMembers(members);
            _chatSessions?.insert(chatSessionIndex, chatSession);
            _chatSessionIDSToChatSessions[chatSessionID] = chatSession;
          }
          eventBus.fire(ChatSessionsEvent(chatSessions!));
          break;
        case ClientCommandResultType.getChatRequests:
          _chatRequests = [];
          int friendRequestsLength = msg.readInt32();
          for (int i = 0; i < friendRequestsLength; i++) {
            int clientID = msg.readInt32();
            _chatRequests?.add(ChatRequest(clientID));
          }
          eventBus.fire(ChatRequestsEvent(_chatRequests!));
          break;
        case ClientCommandResultType.getOtherAccountsAssociatedWithDevice:
          _otherAccounts = [];

          while (msg.readableBytes > 0) {
            int clientID = msg.readInt32();
            String email = utf8.decode(msg.readBytes(msg.readInt32()));
            String displayName = utf8.decode(msg.readBytes(msg.readInt32()));
            Uint8List profilePhoto = msg.readBytes(msg.readInt32());

            _otherAccounts!.add(Account(
                profilePhoto: profilePhoto,
                displayName: displayName,
                email: email,
                clientID: clientID));
          }

          eventBus.fire(OtherAccountsEvent(otherAccounts!));
          break;
        case ClientCommandResultType.getWrittenText:
          int chatSessionIndex = msg.readInt32();
          ChatSession chatSession = _chatSessions![chatSessionIndex];
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
            if (clientID == this.clientID) {
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
          eventBus.fire(WrittenTextEvent(chatSession));
          break;
        case ClientCommandResultType.deleteChatMessage:
          int chatSessionID = msg.readInt32();
          while (msg.readableBytes > 0) {
            int messageID = msg.readInt32();
            bool success = msg.readBoolean();

            if (!success) {
              eventBus.fire(MessageDeletionUnsuccessfulEvent());
              continue;
            }

            eventBus.fire(MessageDeletedEvent(_chatSessionIDSToChatSessions[chatSessionID]!, messageID));
          }
          break;
        case ClientCommandResultType.fetchAccountIcon:
          _profilePhoto = msg.readBytes(msg.readableBytes);
          eventBus.fire(ProfilePhotoEvent(_profilePhoto!));
          break;
        case ClientCommandResultType.fetchUserDevices:
          _userDevices.clear();
          while (msg.readableBytes > 0) {
            DeviceType deviceType = DeviceType.fromId(msg.readInt32());
            String address = utf8.decode(msg.readBytes(msg.readInt32()));
            String osName = utf8.decode(msg.readBytes(msg.readInt32()));
            _userDevices.add(UserDeviceInfo(address, deviceType, osName));
          }
          eventBus.fire(UserDevicesEvent(_userDevices));
          break;
        case ClientCommandResultType.setAccountIcon:
          bool isSuccessful = msg.readBoolean();
          if (!isSuccessful) {
            break;
          }
          
          _profilePhoto = Commands.pendingAccountIcon;
          eventBus.fire(AddProfilePhotoResultEvent(isSuccessful));
          break;
        case ClientCommandResultType.startVoiceCall:
          int udpServerPort = msg.readInt32();
          int voiceCallKey = msg.readInt32();
          // Uint8List aesKey = msg.readBytes(msg.readableBytes);
          eventBus.fire(StartVoiceCallResultEvent(voiceCallKey, udpServerPort));
          break;
        case ClientCommandResultType.getDonationPageURL:
          Uint8List donationPageURL = msg.readBytes(msg.readableBytes);
          eventBus.fire(DonationPageEvent(utf8.decode(donationPageURL)));
          break;
        case ClientCommandResultType.getSourceCodePageURL:
          Uint8List sourceCodePageURL = msg.readBytes(msg.readableBytes);
          eventBus.fire(SourceCodePageEvent(utf8.decode(sourceCodePageURL)));
          break;
      }
    }

    try {
      ServerMessageType msgType = ServerMessageType.fromId(msg.readInt32());

      switch (msgType) {
        case ServerMessageType.serverMessageInfo:
          Uint8List content = msg.readBytes(msg.readableBytes);
          eventBus.fire(ServerMessageInfoEvent(utf8.decode(content)));
          break;
        case ServerMessageType.voiceCallIncoming:
          int udpServerPort = msg.readInt32();
          int chatSessionID = msg.readInt32();
          int voiceCallKey = msg.readInt32();
          int clientID = msg.readInt32();
          // Uint8List aesKey = msg.readBytes(msg.readableBytes);
          
          ChatSession session = _chatSessionIDSToChatSessions[chatSessionID]!;

          Member? member;
          for (var j = 0; j < session.getMembers.length; j++) {
            if (session.getMembers[j].clientID == clientID) {
              member = session.getMembers[j];
            }
          }

          if (member == null) throw new Exception("What the fuck is this");

          eventBus.fire(VoiceCallIncomingEvent(
            chatSessionID: chatSessionID,
            chatSessionIndex: session.chatSessionIndex,
            voiceCallKey: voiceCallKey,
            member: member,
            udpServerPort: udpServerPort,
          ));
          break;
        case ServerMessageType.messageDeliveryStatus:
          MessageDeliveryStatus status = MessageDeliveryStatus.fromId(msg.readInt32());

          Message pendingMessage;
          
          if (status == MessageDeliveryStatus.lateDelivered) {
            int chatSessionID = msg.readInt32();
            int generatedMessageID = msg.readInt32();

            pendingMessage = _chatSessionIDSToChatSessions[chatSessionID]!
                .getMessages
                .firstWhere((m) => m.messageID == generatedMessageID);
          } else if (status == MessageDeliveryStatus.rejected) {
            int tempMessageID = msg.readInt32();
            pendingMessage = pendingMessagesQueue.remove(tempMessageID)!;
          } else {
            int tempMessageID = msg.readInt32();
            int generatedMessageID = msg.readInt32();

            pendingMessage = pendingMessagesQueue[tempMessageID]!;
            if (status == MessageDeliveryStatus.delivered) {
              pendingMessagesQueue.remove(tempMessageID)!;
            }

            pendingMessage.setMessageID(generatedMessageID);
          }

          pendingMessage.setDeliveryStatus(status);

          eventBus.fire(MessageDeliveryStatusEvent(
            deliveryStatus: status,
            message: pendingMessage,
          ));
          break;
        case ServerMessageType.clientMessage:
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
              _chatSessionIDSToChatSessions[chatSessionID]!.chatSessionIndex);
          message.setText(text);
          message.setFileName(fileNameBytes);
          message.setEpochSecond(epochSecond);
          message.setDeliveryStatus(MessageDeliveryStatus.delivered);

          ChatSession chatSession =
              _chatSessionIDSToChatSessions[chatSessionID]!;
          if (chatSession.haveChatMessagesBeenCached) {
            chatSession.getMessages.add(message);
          }

          eventBus.fire(MessageReceivedEvent(message, chatSession));
          break;
        case ServerMessageType.commandResult:
          final commandResult = ClientCommandResultType.fromId(msg.readInt32());
          handleCommandResult(commandResult);
          break;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(e.toString());
      }
    }
  }

  bool get isListeningToMessages => _isClientListeningToMessages;
  Commands get commands => _commands;
  String? get username => _username;
  Uint8List? get profilePhoto => _profilePhoto;
  List<ChatSession>? get chatSessions => _chatSessions;
  List<ChatRequest>? get chatRequests => _chatRequests;
  get usesDevices => _userDevices;
  List<Account>? get otherAccounts => _otherAccounts;
}

class Commands {
  final ByteBufOutputStream out;

  Commands(this.out);

  /// This method is unused for the time being since I am too lazy to refactor.
  /// In addition, while it could reduce boilerplate code, it may also potentially
  /// introduce subtle bugs which are very challenging to troubleshoot and debug.
  /// Use with caution.
  // ignore: unused_element
  void _sendCommand(ClientCommandType commandType, ByteBuf payload) {
    ByteBuf payload = ByteBuf.smallBuffer();
    payload.writeInt32(ClientMessageType.command.id);
    payload.writeInt32(commandType.id);
    payload.writeByteBuf(payload);

    out.write(payload);
  }

  void changeDisplayName(String newDisplayName) {
    var newUsernameBytes = utf8.encode(newDisplayName);

    ByteBuf payload = ByteBuf.smallBuffer();
    payload.writeInt32(ClientMessageType.command.id);
    payload.writeInt32(ClientCommandType.changeUsername.id);
    payload.writeBytes(newUsernameBytes);

    out.write(payload);
  }

  void changePassword(String newPassword) {
    var newPasswordBytes = utf8.encode(newPassword);

    ByteBuf payload = ByteBuf.smallBuffer();
    payload.writeInt32(ClientMessageType.command.id);
    payload.writeInt32(ClientCommandType.changePassword.id);
    payload.writeBytes(newPasswordBytes);

    out.write(payload);
  }

  void fetchUsername() {
    ByteBuf payload = ByteBuf.smallBuffer();
    payload.writeInt32(ClientMessageType.command.id);
    payload.writeInt32(ClientCommandType.fetchUsername.id);

    out.write(payload);
  }

  void fetchClientID() {
    ByteBuf payload = ByteBuf.smallBuffer();
    payload.writeInt32(ClientMessageType.command.id);
    payload.writeInt32(ClientCommandType.fetchClientId.id);

    out.write(payload);
  }

  void fetchWrittenText(int chatSessionIndex) {
    ByteBuf payload = ByteBuf.smallBuffer();
    payload.writeInt32(ClientMessageType.command.id);
    payload.writeInt32(ClientCommandType.fetchWrittenText.id);
    payload.writeInt32(chatSessionIndex);
    payload.writeInt32(Client.instance()
        .chatSessions![chatSessionIndex]
        .getMessages
        .length /* Number of messages client already has */);

    out.write(payload);
  }

  void fetchChatRequests() {
    ByteBuf payload = ByteBuf.smallBuffer();
    payload.writeInt32(ClientMessageType.command.id);
    payload.writeInt32(ClientCommandType.fetchChatRequests.id);

    out.write(payload);
  }

  void fetchChatSessions() {
    ByteBuf payload = ByteBuf.smallBuffer();
    payload.writeInt32(ClientMessageType.command.id);
    payload.writeInt32(ClientCommandType.fetchChatSessions.id);

    out.write(payload);
  }

  void requestDonationHTMLPage() {
    ByteBuf payload = ByteBuf.smallBuffer();
    payload.writeInt32(ClientMessageType.command.id);
    payload.writeInt32(ClientCommandType.requestDonationPage.id);

    out.write(payload);
  }

  void requestServerSourceCodeHTMLPage() {
    ByteBuf payload = ByteBuf.smallBuffer();
    payload.writeInt32(ClientMessageType.command.id);
    payload.writeInt32(ClientCommandType.requestSourceCodePage.id);

    out.write(payload);
  }

  void sendChatRequest(int userClientID) {
    ByteBuf payload = ByteBuf.smallBuffer();
    payload.writeInt32(ClientMessageType.command.id);
    payload.writeInt32(ClientCommandType.sendChatRequest.id);
    payload.writeInt32(userClientID);

    out.write(payload);
  }

  void acceptChatRequest(int userClientID) {
    ByteBuf payload = ByteBuf.smallBuffer();
    payload.writeInt32(ClientMessageType.command.id);
    payload.writeInt32(ClientCommandType.acceptChatRequest.id);
    payload.writeInt32(userClientID);

    out.write(payload);

    fetchChatRequests();
    fetchChatSessions();
  }

  void declineChatRequest(int userClientID) {
    ByteBuf payload = ByteBuf.smallBuffer();
    payload.writeInt32(ClientMessageType.command.id);
    payload.writeInt32(ClientCommandType.declineChatRequest.id);
    payload.writeInt32(userClientID);

    out.write(payload);

    fetchChatRequests();
  }

  void deleteChatSession(int chatSessionIndex) {
    ByteBuf payload = ByteBuf.smallBuffer();
    payload.writeInt32(ClientMessageType.command.id);
    payload.writeInt32(ClientCommandType.deleteChatSession.id);
    payload.writeInt32(chatSessionIndex);

    out.write(payload);

    fetchChatSessions();
  }

  void deleteMessage(int chatSessionIndex, int messageID) {
    ByteBuf payload = ByteBuf.smallBuffer();
    payload.writeInt32(ClientMessageType.command.id);
    payload.writeInt32(ClientCommandType.deleteChatMessage.id);
    payload.writeInt32(chatSessionIndex);
    payload.writeInt32(messageID);

    out.write(payload);
  }
  void deleteMessages(int chatSessionIndex, [List<int> otherMessageIDs = const []]) {
    ByteBuf payload = ByteBuf.smallBuffer();
    payload.writeInt32(ClientMessageType.command.id);
    payload.writeInt32(ClientCommandType.deleteChatMessage.id);
    payload.writeInt32(chatSessionIndex);
    for (int i = 0; i < otherMessageIDs.length; i++) {
      payload.writeInt32(otherMessageIDs[i]);
    }

    out.write(payload);
  }

  void downloadFile(int messageID, int chatSessionIndex) {
    ByteBuf payload = ByteBuf.smallBuffer();
    payload.writeInt32(ClientMessageType.command.id);
    payload.writeInt32(ClientCommandType.downloadFile.id);
    payload.writeInt32(chatSessionIndex);
    payload.writeInt32(messageID);

    out.write(payload);
  }

  void downloadImage(int messageID, int chatSessionIndex) {
    ByteBuf payload = ByteBuf.smallBuffer();
    payload.writeInt32(ClientMessageType.command.id);
    payload.writeInt32(ClientCommandType.downloadImage.id);
    payload.writeInt32(chatSessionIndex);
    payload.writeInt32(messageID);

    out.write(payload);
  }

  void logoutThisDevice() {
    ByteBuf payload = ByteBuf.smallBuffer();
    payload.writeInt32(ClientMessageType.command.id);
    payload.writeInt32(ClientCommandType.logoutThisDevice.id);

    out.write(payload);
  }

  void logoutOtherDevice(String ipAddress) {
    ByteBuf payload = ByteBuf.smallBuffer();
    payload.writeInt32(ClientMessageType.command.id);
    payload.writeInt32(ClientCommandType.logoutOtherDevice.id);
    payload.writeBytes(Uint8List.fromList(ipAddress.codeUnits));

    out.write(payload);
  }

  void logoutAllDevices() {
    ByteBuf payload = ByteBuf.smallBuffer();
    payload.writeInt32(ClientMessageType.command.id);
    payload.writeInt32(ClientCommandType.logoutAllDevices.id);

    out.write(payload);
  }

  static Uint8List? pendingAccountIcon;

  Future<void> setAccountIcon(Uint8List accountIconBytes) async {
    ByteBuf payload = ByteBuf.smallBuffer(growable: true);
    payload.writeInt32(ClientMessageType.command.id);
    payload.writeInt32(ClientCommandType.addAccountIcon.id);
    payload.writeBytes(accountIconBytes);
    pendingAccountIcon = accountIconBytes;

    out.write(payload);
  }

  void fetchDevices() {
    ByteBuf payload = ByteBuf.smallBuffer();
    payload.writeInt32(ClientMessageType.command.id);
    payload.writeInt32(ClientCommandType.fetchUserDevices.id);
    out.write(payload);
  }

  void fetchOtherAccountsAssociatedWithDevice() {
    ByteBuf payload = ByteBuf.smallBuffer();
    payload.writeInt32(ClientMessageType.command.id);
    payload.writeInt32(ClientCommandType.fetchOtherAccountsAssociatedWithDevice.id);
    out.write(payload);
  }

  void fetchAccountIcon() {
    ByteBuf payload = ByteBuf.smallBuffer();
    payload.writeInt32(ClientMessageType.command.id);
    payload.writeInt32(ClientCommandType.fetchAccountIcon.id);
    out.write(payload);
  }

  void deleteAccount(String emailAddress, String password) {
    ByteBuf payload = ByteBuf.smallBuffer();
    payload.writeInt32(ClientMessageType.command.id);
    payload.writeInt32(ClientCommandType.deleteAccount.id);

    // Write email
    payload.writeInt32(emailAddress.length);
    payload.writeBytes(utf8.encode(emailAddress));

    // Write password
    payload.writeInt32(password.length);
    payload.writeBytes(utf8.encode(password));

    out.write(payload);
  }

  void addNewAccount() {
    ByteBuf payload = ByteBuf.smallBuffer();
    payload.writeInt32(ClientMessageType.command.id);
    payload.writeInt32(ClientCommandType.addNewAccount.id);
    out.write(payload);
  }

  void switchAccount() {
    ByteBuf payload = ByteBuf.smallBuffer();
    payload.writeInt32(ClientMessageType.command.id);
    payload.writeInt32(ClientCommandType.switchAccount.id);
    out.write(payload);
  }

  // void acceptVoiceCall(int chatSessionID) {
  //   ByteBuf payload = ByteBuf.smallBuffer();
  //   payload.writeInt(ClientMessageType.command.id);
  //   payload.writeInt(ClientCommandType.acceptVoiceCall.id);
  //   payload.writeInt(chatSessionID);
  //   out.write(payload);
  // }

  void startVoiceCall(int chatSessionIndex) {
    ByteBuf payload = ByteBuf.smallBuffer();
    payload.writeInt32(ClientMessageType.command.id);
    payload.writeInt32(ClientCommandType.startVoiceCall.id);
    payload.writeInt32(chatSessionIndex);
    out.write(payload);
  }
}
