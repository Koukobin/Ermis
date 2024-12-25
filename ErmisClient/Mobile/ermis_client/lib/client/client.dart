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

import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:typed_data';

import 'package:ermis_client/client/common/account.dart';
import 'package:ermis_client/client/common/entry/requirements.dart';
import 'package:ermis_client/client/io/byte_buf.dart';
import 'package:flutter/foundation.dart';

import '../util/database_service.dart';
import 'common/chat_request.dart';
import 'common/chat_session.dart';
import 'common/entry/added_info.dart';
import 'common/entry/create_account_info.dart';
import 'common/entry/entry_type.dart';
import 'common/entry/login_info.dart';
import 'common/entry/verification.dart';
import 'common/file_heap.dart';
import 'common/html_page.dart';
import 'common/message_types/client_command_type.dart';
import 'common/message_types/client_message_type.dart';
import 'common/results/ResultHolder.dart';
import 'common/results/entry_result.dart';
import 'common/user_device.dart';
import 'io/input_stream.dart';
import 'common/message.dart';
import 'message_handler.dart';
import 'io/output_stream.dart';

enum ServerCertificateVerification { verify, ignore }

class Client {

  static final Client _instance = Client._();

  static Client getInstance() {
    return _instance;
  }

  ByteBufInputStream? _inputStream;
  ByteBufOutputStream? _outputStream;

  SecureSocket? _sslSocket;
  Stream<Uint8List>? broadcastStream;

  bool _isLoggedIn = false;

  final MessageHandler _messageHandler = MessageHandler();
  
  Uri? uri;

  Client._();

  Future<void> initialize(Uri uri, ServerCertificateVerification scv) async {
    if (uri.port <= 0) {
      throw ArgumentError("Port cannot be below zero");
    }

    try {
      final context = SecurityContext(withTrustedRoots: false);

      _sslSocket = await SecureSocket.connect(uri.host, uri.port,
          context: context,
          onBadCertificate: (X509Certificate cert) =>
              scv == ServerCertificateVerification.ignore);

      broadcastStream = _sslSocket!.asBroadcastStream();

      this.uri = uri;

      _inputStream = ByteBufInputStream(broadcastStream: broadcastStream!);
      _outputStream = ByteBufOutputStream(secureSocket: _sslSocket!);

      _messageHandler.setSecureSocket(_sslSocket!);
      _messageHandler.setByteBufInputStream(_inputStream!);
      _messageHandler.setByteBufOutputStream(_outputStream!);

      _outputStream!.write(ByteBuf.empty()); // Denotes connection
    } on HandshakeException {
      if (scv == ServerCertificateVerification.verify) {
        throw HandshakeException("Could not verify server certificate");
      }
      rethrow;
    }
  }

  Future<void> syncWithServer() async {
    await _inputStream!.read(); // Message denoting server is ready for MESSAGES
  }

  Future<bool> attemptShallowLogin(UserAccount userInfo) async {

    ByteBuf buffer = ByteBuf.smallBuffer();
    buffer.writeInt(ClientMessageType.entry.id);    
    buffer.writeInt(EntryType.login.id);
    
    buffer.writeInt(userInfo.email.length);
    buffer.writeBytes(utf8.encode(userInfo.email));
    buffer.writeBytes(utf8.encode(userInfo.passwordHash));

    _outputStream!.write(buffer);

    return _isLoggedIn = (await _inputStream!.read()).readBoolean();
  }

  void sendMessageToClient(String text, int chatSessionIndex) {
    _messageHandler.sendMessageToClient(text, chatSessionIndex);
  }

  void sendImageToClient(String fileName, Uint8List fileBytes, int chatSessionIndex) {
    _messageHandler.sendImageToClient(fileName, fileBytes, chatSessionIndex);
  }

  void sendFileToClient(String fileName, Uint8List fileContentBytes, int chatSessionIndex) {
    _messageHandler.sendFileToClient(fileName, fileContentBytes, chatSessionIndex);
  }

  Entry createNewVerificationEntry() {
    return Entry(EntryType.login, _outputStream!, _inputStream!);
  }

  Entry createNewBackupVerificationEntry() {
    return Entry(EntryType.login, _outputStream!, _inputStream!);
  }
	
	CreateAccountEntry createNewCreateAccountEntry() {
		return CreateAccountEntry(_outputStream!, _inputStream!);
	}
	
	LoginEntry createNewLoginEntry() {
		return LoginEntry(_outputStream!, _inputStream!);
	}

  Future<void> fetchUserInformation() async {
    if (!isLoggedIn()) {
      throw StateError(
          "User can't start writing to the server if they aren't logged in");
    }
    
    await _messageHandler.fetchUserInformation();
  }

  void startMessageHandler() {
    _messageHandler.startListeningToMessages();
  }

  void whenUsernameReceived(void Function(String username) runThis) {
    _messageHandler.callBacks.onUsernameReceived(runThis);
  }
  
  void whenMessageReceived(void Function(Message message, int chatSessionIndex) runThis) {
    _messageHandler.callBacks.onMessageReceived(runThis);
  }

  void whenSuccesfullySentMessageReceived(void Function(ChatSession session, int messageID) runThis) {
    _messageHandler.callBacks.onMessageSuccesfullySent(runThis);
  }

  void whenAlreadyWrittenTextReceived(void Function(ChatSession chatSession) runThis) {
    _messageHandler.callBacks.onWrittenTextReceived(runThis);
  }
  
  void whenServerMessageReceived(void Function(String message) runThis) {
    _messageHandler.callBacks.onServerMessageReceived(runThis);
  }
  
  void whenFileDownloaded(void Function(LoadedInMemoryFile file) runThis) {
    _messageHandler.callBacks.onFileDownloaded(runThis);
  }

  void whenImageDownloaded(void Function(LoadedInMemoryFile file, int messageID) runThis) {
    _messageHandler.callBacks.onImageDownloaded(runThis);
  }

  void whenDonationPageReceived(void Function(DonationHtmlPage donationPage) runThis) {
    _messageHandler.callBacks.onDonationPageReceived(runThis);
  }  

  void whenServerSourceCodeReceived(void Function(String serverSourceCodeURL) runThis) {
    _messageHandler.callBacks.onServerSourceCodeReceived(runThis);
  }

  void whenClientIDReceived(void Function(int clientID) runThis) {
    _messageHandler.callBacks.onClientIdReceived(runThis);
  }

  void whenChatRequestsReceived(void Function(List<ChatRequest> chatRequests) runThis) {
    _messageHandler.callBacks.onChatRequestsReceived(runThis);
  }

  void whenChatSessionsReceived(void Function(List<ChatSession> chatSessions) runThis) {
    _messageHandler.callBacks.onChatSessionsReceived(runThis);
  }

  void whenVoiceCallIncoming(bool Function(Member member) runThis) {
    _messageHandler.callBacks.onVoiceCallIncoming(runThis);
  }

  void whenMessageDeleted(void Function(ChatSession chatSession, int messageIDOfDeletedMessage) runThis) {
    _messageHandler.callBacks.onMessageDeleted(runThis);
  }

  void whenProfilePhotoReceived(void Function(Uint8List iconBytes) runThis) {
    _messageHandler.callBacks.onProfilePhotoReceived(runThis);
  }

  void whenUserDevicesReceived(void Function(List<UserDeviceInfo>) runThis) {
    _messageHandler.callBacks.onUserDevicesReceived(runThis);
  }

  EventCallbacks get callbacks => _messageHandler.callBacks;
  Commands get commands => _messageHandler.commands;
  int get clientID => _messageHandler.clientID;
  String? get displayName => _messageHandler.username;
  Uint8List? get profilePhoto => _messageHandler.profilePhoto;
  List<ChatSession>? get chatSessions => _messageHandler.chatSessions;
  List<ChatRequest>? get chatRequests => _messageHandler.chatRequests;
  ServerInfo get serverInfo => ServerInfo(uri!);
  List<UserDeviceInfo> get userDevices => _messageHandler.usesDevices;
  List<Account>? get otherAccounts => _messageHandler.otherAccounts;

  bool isLoggedIn() {
    return _isLoggedIn;
  }

}

class UDPSocket {
  RawDatagramSocket? _udpSocket;

  InternetAddress? _remoteAddress;
  int? _remotePort;

  UDPSocket();

  Future<void> initialize(InternetAddress remoteAddress, int remotePort) async {
    if (remotePort <= 0) {
      throw ArgumentError("Port cannot be below zero");
    }

    ByteBuf buffer = ByteBuf.smallBuffer();
    buffer.writeInt(ClientMessageType.command.id);
    buffer.writeInt(ClientCommandType.startVoiceCall.id);
    buffer.writeInt(0);
    buffer.writeInt(3143);
    Client.getInstance()._outputStream!.write(buffer);

    _udpSocket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      9090,
    );
    _remoteAddress = remoteAddress;
    _remotePort = remotePort;

    _udpSocket!.listen((event) {
      if (event == RawSocketEvent.read) {
        final datagram = _udpSocket!.receive();
        if (datagram != null) {
          final message = String.fromCharCodes(datagram.data);
          print("Received from server: $message");
        }
      }
    });
  }

  void send(String message) {
    if (_udpSocket != null) {
      final data = Utf8Codec().encode(message);
      _udpSocket!.send(data, _remoteAddress!, _remotePort!);
      print("Sent to server: $message");
    }
  }

}

class Entry<T extends CredentialInterface> {
  final EntryType entryType;

  final ByteBufInputStream inputStream;
  final ByteBufOutputStream outputStream;

  bool isLoggedIn = false;
  bool isVerificationComplete = false;

  Entry(this.entryType, this.outputStream, this.inputStream);

  Future<ResultHolder> getCredentialsExchangeResult() async {
    ByteBuf msg = await inputStream.read();

    bool isSuccessful = msg.readBoolean();
    Uint8List resultMessageBytes = msg.readBytes(msg.readableBytes);

    return ResultHolder(isSuccessful, utf8.decode(resultMessageBytes));
  }

  Future<void> sendCredentials(Map<T, String> credentials) async {
    for (var credential in credentials.entries) {
      bool isAction = false;
      int credentialInt = credential.key.id;
      String credentialValue = credential.value;

      ByteBuf payload = ByteBuf.smallBuffer();
      payload.writeInt(ClientMessageType.entry.id);
      payload.writeBoolean(isAction);
      payload.writeInt(credentialInt);
      payload.writeBytes(Uint8List.fromList(credentialValue.codeUnits));

      outputStream.write(payload);
    }
  }

  Future<ResultHolder> getBackupVerificationCodeResult() async {
    ByteBuf payload = await inputStream.read();

    isLoggedIn = payload.readBoolean();
    Client.getInstance()._isLoggedIn = isLoggedIn;
    
    Uint8List resultMessageBytes = payload.readBytes(payload.readableBytes);

    return ResultHolder(isLoggedIn, String.fromCharCodes(resultMessageBytes));
  }

  Future<void> sendEntryType() async {
    outputStream.write(ByteBuf.smallBuffer()..writeInt(ClientMessageType.entry.id)..writeInt(entryType.id));
  }

  Future<void> sendVerificationCode(int verificationCode) async {
    bool isAction = false;

    ByteBuf payload = ByteBuf.smallBuffer();
    payload.writeInt(ClientMessageType.entry.id);
    payload.writeBoolean(isAction);
    payload.writeInt(verificationCode);

    outputStream.write(payload);
  }

  Future<EntryResult> getResult() async {
    ByteBuf msg = await inputStream.read();

    isVerificationComplete = msg.readBoolean();
    isLoggedIn = msg.readBoolean();

    Client.getInstance()._isLoggedIn = isLoggedIn;
    List<int> resultMessageBytes = msg.readBytes(msg.readInt32());

    Map<AddedInfo, String> map = HashMap();
    EntryResult result = EntryResult(ResultHolder(isLoggedIn, String.fromCharCodes(resultMessageBytes)), map);

    while (msg.readableBytes > 0) {
      AddedInfo addedInfo = AddedInfo.fromId(msg.readInt32());
      Uint8List message = msg.readBytes(msg.readInt32());
      map[addedInfo] = utf8.decode(message.toList());
    }

    return result;
  }

  Future<void> resendVerificationCode() async {
    bool isAction = true;

    ByteBuf payload = ByteBuf.smallBuffer();
    payload.writeInt(ClientMessageType.entry.id);
    payload.writeBoolean(isAction);
    payload.writeInt(VerificationAction.resendCode.id);

    outputStream.write(payload);
  }
}

class CreateAccountEntry extends Entry<CreateAccountCredential> {

  late final Requirements usernameRequirements;
  late final Requirements passwordRequirements;

  CreateAccountEntry(
      ByteBufOutputStream outputStream, ByteBufInputStream inputStream)
      : super(EntryType.createAccount, outputStream, inputStream) {
    // void fetch() async {
    //   ByteBuf payload = await inputStream.read();

    //   {
    //     int usernameMaxLength = payload.readInt32();
    //     String invalidCharacters =
    //         utf8.decode(payload.readBytes(payload.readInt32()));
    //     usernameRequirements = Requirements(
    //         maxLength: usernameMaxLength, invalidCharacters: invalidCharacters);
    //   }

    //   {
    //     int passwordMaxLength = payload.readInt32();
    //     double minEntropy = payload.readFloat64();
    //     String invalidCharacters =
    //         utf8.decode(payload.readBytes(payload.readableBytes));
    //     passwordRequirements = Requirements(
    //         minEntropy: minEntropy,
    //         maxLength: passwordMaxLength,
    //         invalidCharacters: invalidCharacters);
    //   }
    // }

    // fetch();
  }

  Future<void> addDeviceInfo(DeviceType deviceType, String osName) async {
    bool isAction = true;
    int actionId = CreateAccountAction.addDeviceInfo.id;

    ByteBuf payload = ByteBuf.smallBuffer();
    payload.writeInt(ClientMessageType.entry.id);    
    payload.writeBoolean(isAction);
    payload.writeInt(actionId);
    payload.writeInt(deviceType.id);
    payload.writeBytes(utf8.encode(osName));

    outputStream.write(payload);
  }
}

class LoginEntry extends Entry<LoginCredential> {

  LoginEntry(ByteBufOutputStream outputStream, ByteBufInputStream inputStream) : super(EntryType.login, outputStream, inputStream);

  /// Switches between authenticating via password or backup verification code.
  /// This is useful for users who have lost their primary password and need an alternative method.
  Future<void> togglePasswordType() async {
    bool isAction = true;
    int actionId = LoginAction.togglePasswordType.id;

    ByteBuf payload = ByteBuf.smallBuffer();
    payload.writeInt(ClientMessageType.entry.id);
    payload.writeBoolean(isAction);
    payload.writeInt(actionId);

    outputStream.write(payload);
  }

  Future<void> addDeviceInfo(DeviceType deviceType, String osName) async {
    bool isAction = true;
    int actionId = LoginAction.addDeviceInfo.id;

    ByteBuf payload = ByteBuf.smallBuffer();
    payload.writeInt(ClientMessageType.entry.id);
    payload.writeBoolean(isAction);
    payload.writeInt(actionId);
    payload.writeInt(deviceType.id);
    payload.writeBytes(utf8.encode(osName));

    outputStream.write(payload);
  }
}

