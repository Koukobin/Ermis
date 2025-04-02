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

import 'package:ermis_client/client/handlers/chat_sessions_service.dart';
import 'package:ermis_client/core/event_bus/app_event_bus.dart';
import 'package:ermis_client/client/common/message_types/message_delivery_status.dart';
import 'package:ermis_client/core/models/message_events.dart';
import 'package:ermis_client/features/authentication/domain/client_status.dart';
import 'package:flutter/foundation.dart';

import '../core/data_sources/api_client.dart';
import '../core/models/account.dart';
import 'common/message_types/client_command_type.dart';
import 'common/message_types/client_message_type.dart';
import 'common/message_types/content_type.dart';
import '../core/models/user_device.dart';
import '../core/event_bus/event_bus.dart';
import 'io/byte_buf.dart';
import '../core/models/chat_request.dart';
import '../core/models/chat_session.dart';
import '../core/models/message.dart';
import 'io/output_stream.dart';

class Info {
  static String? username;
  static int clientID = -1;
  static ClientStatus? accountStatus;
  static Uint8List? profilePhoto;
  static final List<UserDeviceInfo> userDevices = [];

  static final Map<int, ChatSession> chatSessionIDSToChatSessions = {};
  static List<ChatSession>? chatSessions;
  static List<ChatRequest>? chatRequests;
  static List<Account>? otherAccounts;

  static final Map<int /* temporary message id */, Message> pendingMessagesQueue = {};
  static int lastPendingMessageID = 0;
}

class MessageHandler {
  late final ByteBufOutputStream _outputStream;

  bool _isClientListeningToMessages = false;

  late final Commands _commands;
  final EventBus eventBus = AppEventBus.instance;

  MessageHandler();

  void setByteBufOutputStream(ByteBufOutputStream outputStream) {
    _outputStream = outputStream;
    _commands = Commands(_outputStream);
  }

  Message sendMessageToClient(String text, int chatSessionIndex) {
    Uint8List textBytes = utf8.encode(text);

    ByteBuf payload = ByteBuf.smallBuffer(growable: true);
    payload.writeInt32(ClientMessageType.clientContent.id);
    payload.writeInt32(++Info.lastPendingMessageID);
    payload.writeInt32(MessageContentType.text.id);
    payload.writeInt32(chatSessionIndex);
    payload.writeInt32(textBytes.length);
    payload.writeBytes(textBytes);

    _outputStream.write(payload);

    return createPendingMessage(
      text: Uint8List.fromList(utf8.encode(text)),
      contentType: MessageContentType.text,
      chatSessionID: Info.chatSessions![chatSessionIndex].chatSessionID,
      chatSessionIndex: chatSessionIndex,
      tempMessageID: Info.lastPendingMessageID,
    );
  }

  Message sendFileToClient(String fileName, Uint8List fileContentBytes, int chatSessionIndex) {
    Uint8List fileNameBytes = utf8.encode(fileName);

    // Calculate the payload size in advance for efficiency
    int payloadSize = 20 + fileNameBytes.length + fileContentBytes.length;

    ByteBuf payload = ByteBuf(payloadSize);
    payload.writeInt32(ClientMessageType.clientContent.id);
    payload.writeInt32(++Info.lastPendingMessageID);
    payload.writeInt32(MessageContentType.file.id);
    payload.writeInt32(chatSessionIndex);
    payload.writeInt32(fileNameBytes.length);
    payload.writeBytes(fileNameBytes);
    payload.writeBytes(fileContentBytes);

    _outputStream.write(payload);

    return createPendingMessage(
      fileName: Uint8List.fromList(utf8.encode(fileName)),
      contentType: MessageContentType.file,
      chatSessionID: Info.chatSessions![chatSessionIndex].chatSessionID,
      chatSessionIndex: chatSessionIndex,
      tempMessageID: Info.lastPendingMessageID,
    );
  }

  Message sendImageToClient(String fileName, Uint8List fileContentBytes, int chatSessionIndex) {
    Uint8List fileNameBytes = utf8.encode(fileName);

    // Calculate the payload size in advance for efficiency
    int payloadSize = 20 + fileNameBytes.length + fileContentBytes.length;
    
    ByteBuf payload = ByteBuf(payloadSize);
    payload.writeInt32(ClientMessageType.clientContent.id);
    payload.writeInt32(++Info.lastPendingMessageID);
    payload.writeInt32(MessageContentType.image.id);
    payload.writeInt32(chatSessionIndex);
    payload.writeInt32(fileNameBytes.length);
    payload.writeBytes(fileNameBytes);
    payload.writeBytes(fileContentBytes);

    _outputStream.write(payload);

    return createPendingMessage(
      fileName: Uint8List.fromList(utf8.encode(fileName)),
      contentType: MessageContentType.image,
      chatSessionID: Info.chatSessions![chatSessionIndex].chatSessionID,
      chatSessionIndex: chatSessionIndex,
      tempMessageID: Info.lastPendingMessageID,
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
    
    Info.pendingMessagesQueue[tempMessageID] = m;
    return m;
  }

  Future<void> fetchUserInformation() async {
    commands.fetchUsername();
    commands.fetchClientID();
    commands.fetchAccountStatus();
    commands.fetchChatSessionIndices();
    AppEventBus.instance.on<ChatSessionsIndicesReceivedEvent>().first.then((ChatSessionsIndicesReceivedEvent msg) {
      commands.fetchChatSessions();
    });
    commands.fetchChatRequests();
    commands.fetchDevices();
    commands.fetchAccountIcon();
    commands.fetchOtherAccountsAssociatedWithDevice();

    // Block until requested information has been fetched
    await Future.doWhile(() async {
      return await Future.delayed(const Duration(milliseconds: 100), () {
        return (username == null ||
            Info.profilePhoto == null ||
            chatRequests == null ||
            chatSessions == null ||
            Info.accountStatus == null);
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
  }

  bool get isListeningToMessages => _isClientListeningToMessages;
  Commands get commands => _commands;
  String? get username => Info.username;
  int get clientID => Info.clientID;
  Uint8List? get profilePhoto => Info.profilePhoto;
  List<ChatSession>? get chatSessions => Info.chatSessions;
  List<ChatRequest>? get chatRequests => Info.chatRequests;
  get usesDevices => Info.userDevices;
  List<Account>? get otherAccounts => Info.otherAccounts;
}

class Commands {
  final ByteBufOutputStream out;

  const Commands(this.out);

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

  void setAccountStatus(ClientStatus status) {
    ByteBuf payload = ByteBuf.smallBuffer();
    payload.writeInt32(ClientMessageType.command.id);
    payload.writeInt32(ClientCommandType.setAccountStatus.id);
    payload.writeInt32(status.id);

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

  void fetchAccountStatus() {
    ByteBuf payload = ByteBuf.smallBuffer();
    payload.writeInt32(ClientMessageType.command.id);
    payload.writeInt32(ClientCommandType.fetchAccountStatus.id);

    out.write(payload);
  }

  void refetchWrittenText(int chatSessionIndex) {
    ByteBuf payload = ByteBuf.smallBuffer();
    payload.writeInt32(ClientMessageType.command.id);
    payload.writeInt32(ClientCommandType.fetchWrittenText.id);
    payload.writeInt32(chatSessionIndex);
    payload.writeInt32(0);

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

  Future<void> fetchChatSessionIndices() async {
    ByteBuf payload = ByteBuf.smallBuffer();
    payload.writeInt32(ClientMessageType.command.id);
    payload.writeInt32(ClientCommandType.fetchChatSessionIndices.id);

    List<int> sessions = await ChatSessionService().fetchChatSessions(server: Client.instance().serverInfo);
    for (int sessionID in sessions) {

      List<Member> members = await ChatSessionService().fetchMembersAssociatedWithChatSession(
        server: Client.instance().serverInfo,
        chatSessionID: sessionID,
      );

      ChatSession chatSession = ChatSession(sessionID, -1);
      chatSession.setMembers(members);

      Info.chatSessionIDSToChatSessions[sessionID] = chatSession;
    }

    out.write(payload);
  }

  void fetchChatSessions() async {
    ByteBuf payload = ByteBuf.smallBuffer();
    payload.writeInt32(ClientMessageType.command.id);
    payload.writeInt32(ClientCommandType.fetchChatSessions.id);

    List<ChatSession> sessions = Info.chatSessionIDSToChatSessions.values.toList();

    for (ChatSession session in sessions) {
      payload.writeInt32(session.chatSessionIndex);

      List<Member> members = session.getMembers;

      payload.writeInt32(members.length);
      for (Member member in members) {
        payload.writeInt32(member.clientID);
        payload.writeInt32(member.icon.lastUpdatedAtEpochSecond);
      }
    }

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

  Future<SignallingServerPortEvent> fetchSignallingServerPort() {
    ByteBuf payload = ByteBuf.smallBuffer();
    payload.writeInt32(ClientMessageType.command.id);
    payload.writeInt32(ClientCommandType.fetchSignallingServerPort.id);

    out.write(payload);

    return AppEventBus.instance.on<SignallingServerPortEvent>().first;
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

  void addUsersInChatSession(int chatSessionIndex, List<int> memberIds) {
    // Lazy, but I don't give a fuck
    for (int clientID in memberIds) {
      ByteBuf payload = ByteBuf.smallBuffer();
      payload.writeInt32(ClientMessageType.command.id);
      payload.writeInt32(ClientCommandType.addUserInChatSession.id);
      payload.writeInt32(chatSessionIndex);
      payload.writeInt32(clientID);
      out.write(payload);
    }
  }

  void createGroup(List<int> memberIds) {
    ByteBuf payload = ByteBuf.smallBuffer();
    payload.writeInt32(ClientMessageType.command.id);
    payload.writeInt32(ClientCommandType.createGroup.id);
    for (int clientID in memberIds) {
      payload.writeInt32(clientID);
    }
    out.write(payload);
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
