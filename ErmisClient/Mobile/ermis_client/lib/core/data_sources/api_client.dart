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

import 'package:ermis_client/core/event_bus/app_event_bus.dart';
import 'package:ermis_client/core/models/account.dart';
import 'package:ermis_client/features/authentication/domain/entities/requirements.dart';
import 'package:ermis_client/client/io/byte_buf.dart';
import 'package:ermis_client/client/message_dispatcher.dart';
import 'package:ermis_client/core/models/message_events.dart';
import 'package:ermis_client/features/authentication/domain/entities/resultable.dart';
import 'package:flutter/foundation.dart';

import '../services/database_service.dart';
import '../models/chat_request.dart';
import '../models/chat_session.dart';
import '../../features/authentication/domain/entities/added_info.dart';
import '../../features/authentication/domain/entities/create_account_info.dart';
import '../../features/authentication/domain/entities/entry_type.dart';
import '../../features/authentication/domain/entities/login_info.dart';
import '../../features/authentication/domain/entities/verification.dart';
import '../models/message.dart';
import '../../client/common/message_types/client_message_type.dart';
import '../../client/common/results/entry_result.dart';
import '../models/user_device.dart';
import '../event_bus/event_bus.dart';
import '../../client/io/input_stream.dart';
import '../../client/message_handler.dart';
import '../../client/io/output_stream.dart';

enum ServerCertificateVerification { verify, ignore }

class Client {
  static final Client _instance = Client._();

  static Client instance() {
    return _instance;
  }

  ByteBufInputStream? _inputStream;
  ByteBufOutputStream? _outputStream;

  Socket? _sslSocket;
  Stream<Uint8List>? broadcastStream;

  bool _isLoggedIn = false;

  late MessageHandler _messageHandler;

  Uri? uri;

  Client._();

  Future<void> initialize(Uri uri, ServerCertificateVerification scv) async {
    if (uri.port <= 0) {
      throw ArgumentError("Port cannot be below zero");
    }

    try {
      final sslContext = SecurityContext.defaultContext;
      _sslSocket = await SecureSocket.connect(uri.host, uri.port,
          context: sslContext,
          timeout: Duration(seconds: 5),
          onBadCertificate: (X509Certificate cert) =>
              scv == ServerCertificateVerification.ignore);

      broadcastStream = _sslSocket!.asBroadcastStream();

      this.uri = uri;

      _inputStream = ByteBufInputStream(socket: _sslSocket!, stream: broadcastStream!);
      _outputStream = ByteBufOutputStream(socket: _sslSocket!);

      _messageHandler = MessageHandler();
      _messageHandler.setByteBufOutputStream(_outputStream!);
    } on HandshakeException {
      if (scv == ServerCertificateVerification.verify) {
        throw HandshakeException("Could not verify server certificate");
      }
      rethrow;
    }
  }

  Future<String> readServerVersion() async {
    ByteBuf payload = await _inputStream!.read();
    return String.fromCharCodes(payload.readAllBytes().toList());
  }

  /// Attempts to authenticate user by sending their email and password hash
  /// over the network to the server for validation.
  ///
  /// * `userInfo` The local account information containing the user's email
  ///                 and password hash.
  /// * A Future that resolves to a boolean indicating whether the login
  ///          attempt was successful.
  Future<bool> attemptHashedLogin(LocalAccountInfo userInfo) async {
    ByteBuf buffer = ByteBuf.smallBuffer();
    buffer.writeInt32(ClientMessageType.entry.id);
    buffer.writeInt32(EntryType.login.id);

    buffer.writeInt32(userInfo.email.length);
    buffer.writeBytes(utf8.encode(userInfo.email));
    buffer.writeBytes(utf8.encode(userInfo.passwordHash));

    _outputStream!.write(buffer);

    return _isLoggedIn = (await _inputStream!.read()).readBoolean();
  }

  Message sendMessageToClient(String text, int chatSessionIndex) {
    return _messageHandler.sendMessageToClient(text, chatSessionIndex);
  }

  Message sendImageToClient(String fileName, Uint8List fileBytes, int chatSessionIndex) {
    return _messageHandler.sendImageToClient(fileName, fileBytes, chatSessionIndex);
  }

  Message sendFileToClient(String fileName, Uint8List fileContentBytes, int chatSessionIndex) {
    return _messageHandler.sendFileToClient(fileName, fileContentBytes, chatSessionIndex);
  }

  Message sendVoiceMessageToClient(String fileName, Uint8List fileContentBytes, int chatSessionIndex) {
    return _messageHandler.sendVoiceToClient(fileName, fileContentBytes, chatSessionIndex);
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

  bool isMessageDispatcherRunning = false;
  void startMessageDispatcher() {
    if (isMessageDispatcherRunning) return;

    MessageDispatcher(inputStream: _inputStream!).debute();
    isMessageDispatcherRunning = true;
  }

  void startMessageHandler() {
    _messageHandler.startListeningToMessages();
  }

  EventBus get eventBus => _messageHandler.eventBus;
  Commands get commands => _messageHandler.commands;
  int get clientID => _messageHandler.clientID;
  String? get displayName => _messageHandler.username;
  Uint8List? get profilePhoto => _messageHandler.profilePhoto;
  List<ChatSession>? get chatSessions => _messageHandler.chatSessions;
  List<ChatRequest>? get chatRequests => _messageHandler.chatRequests;
  ServerInfo get serverInfo => ServerInfo(uri!);
  List<UserDeviceInfo>? get userDevices => _messageHandler.usesDevices;
  List<Account>? get otherAccounts => _messageHandler.otherAccounts;
  MessageHandler get messageHandler => _messageHandler;

  bool isLoggedIn() {
    return _isLoggedIn;
  }

}

class Entry<T extends CredentialInterface> {
  final EntryType entryType;

  final ByteBufInputStream inputStream;
  final ByteBufOutputStream outputStream;

  bool isLoggedIn = false;
  bool isVerificationComplete = false;

  Entry(this.entryType, this.outputStream, this.inputStream);

  Future<Resultable> getCredentialsExchangeResult() async {
    ByteBuf? buffer;
    await AppEventBus.instance.on<EntryMessage>().first.then((EntryMessage msg) {
      buffer = msg.buffer;
    });

    if (buffer == null) throw Exception("Buffer is null");

    int id = buffer!.readInt32();
    return entryType == EntryType.createAccount
            ? CredentialValidationResult.fromId(id)!
            : LoginCredentialResult.fromId(id)!;
  }

  Future<void> sendCredentials(Map<T, String> credentials) async {
    for (final MapEntry<T,String> credential in credentials.entries) {
      int credentialInt = credential.key.id;
      String credentialValue = credential.value;

      ByteBuf payload = ByteBuf.smallBuffer();
      payload.writeInt32(ClientMessageType.entry.id);
      payload.writeInt32(credentialInt);
      payload.writeBytes(Uint8List.fromList(credentialValue.codeUnits));

      outputStream.write(payload);
    }
  }

  Future<bool> getBackupVerificationCodeResult() async {
    ByteBuf? payload;
    await AppEventBus.instance.on<EntryMessage>().first.then((EntryMessage msg) {
      payload = msg.buffer;
    });

    if (payload == null) throw Exception("Buffer is null");

    isLoggedIn = payload!.readBoolean();
    Client.instance()._isLoggedIn = isLoggedIn;

    Uint8List resultMessageBytes = payload!.readBytes(payload!.readableBytes);

    return isLoggedIn;
  }

  void sendEntryType() {
    outputStream.write(ByteBuf(8)
      ..writeInt32(ClientMessageType.entry.id)
      ..writeInt32(entryType.id));
  }

  Future<void> sendVerificationCode(int verificationCode) async {
    bool isAction = false;

    ByteBuf payload = ByteBuf.smallBuffer();
    payload.writeInt32(ClientMessageType.entry.id);
    payload.writeInt32(verificationCode);

    outputStream.write(payload);
  }

  Future<EntryResult> getResult() async {
    ByteBuf? buffer;
    await AppEventBus.instance.on<EntryMessage>().first.then((EntryMessage msg) {
      buffer = msg.buffer;
    });

    if (buffer == null) throw Exception("Buffer is null");
    ByteBuf payload = buffer!;

    isVerificationComplete = payload.readBoolean();
    isLoggedIn = payload.readBoolean();

    Client.instance()._isLoggedIn = isLoggedIn;
    int resultMessageBytes = payload.readInt32();

    Map<AddedInfo, String> map = HashMap();

    while (payload.readableBytes > 0) {
      AddedInfo addedInfo = AddedInfo.fromId(payload.readInt32());
      Uint8List message = payload.readBytes(payload.readInt32());
      map[addedInfo] = utf8.decode(message.toList());
    }

    EntryResult result = EntryResult(
        entryType == EntryType.createAccount
            ? CreateAccountResult.fromId(resultMessageBytes)!
            : LoginResult.fromId(resultMessageBytes)!,
        map);

    return result;
  }

  Future<void> resendVerificationCode() async {
    bool isAction = true;

    ByteBuf payload = ByteBuf.smallBuffer();
    payload.writeInt32(ClientMessageType.entry.id);
    payload.writeInt32(GeneralEntryAction.action.id);
    payload.writeInt32(VerificationAction.resendCode.id);

    outputStream.write(payload);
  }
}

class CreateAccountEntry extends Entry<CreateAccountCredential> {
  Requirements? usernameRequirements;
  Requirements? passwordRequirements;

  CreateAccountEntry(ByteBufOutputStream outputStream, ByteBufInputStream inputStream)
      : super(EntryType.createAccount, outputStream, inputStream);

  Future<void> fetchCredentialRequirements() async {
    {
      ByteBuf payload = ByteBuf.smallBuffer();
      payload.writeInt32(ClientMessageType.entry.id);
      payload.writeInt32(GeneralEntryAction.action.id);
      payload.writeInt32(CreateAccountAction.fetchRequirements.id);

      outputStream.write(payload);
    }

    ByteBuf? payload;
    await AppEventBus.instance.on<EntryMessage>().first.then((EntryMessage msg) {
      payload = msg.buffer;
    });

    {
      int usernameMaxLength = payload!.readInt32();
      String invalidCharacters = utf8.decode(payload!.readBytes(payload!.readInt32()));
      usernameRequirements = Requirements(
        maxLength: usernameMaxLength,
        invalidCharacters: invalidCharacters,
      );
      if (kDebugMode) debugPrint(invalidCharacters);
    }

    {
      int passwordMaxLength = payload!.readInt32();
      double minEntropy = payload!.readFloat32();
      String invalidCharacters = utf8.decode(payload!.readBytes(payload!.readableBytes));
      passwordRequirements = Requirements(
        minEntropy: minEntropy,
        maxLength: passwordMaxLength,
        invalidCharacters: invalidCharacters,
      );
    }
  }

  Future<void> addDeviceInfo(DeviceType deviceType, String osName) async {
    bool isAction = true;
    int actionId = CreateAccountAction.addDeviceInfo.id;

    ByteBuf payload = ByteBuf.smallBuffer();
    payload.writeInt32(ClientMessageType.entry.id);
    payload.writeInt32(GeneralEntryAction.action.id);
    payload.writeInt32(actionId);
    payload.writeInt32(deviceType.id);
    payload.writeBytes(utf8.encode(osName));

    outputStream.write(payload);
  }
}

class LoginEntry extends Entry<LoginCredential> {
  LoginEntry(ByteBufOutputStream outputStream, ByteBufInputStream inputStream)
      : super(EntryType.login, outputStream, inputStream);

  /// Switches between authenticating via password or backup verification code.
  /// This is useful for users who have lost their primary password and need an alternative method.
  void togglePasswordType() {
    bool isAction = true;
    int actionId = LoginAction.togglePasswordType.id;

    ByteBuf payload = ByteBuf.smallBuffer();
    payload.writeInt32(ClientMessageType.entry.id);
    payload.writeInt32(GeneralEntryAction.action.id);
    payload.writeInt32(actionId);

    outputStream.write(payload);
  }

  void addDeviceInfo(DeviceType deviceType, String osName) {
    bool isAction = true;
    int actionId = LoginAction.addDeviceInfo.id;

    ByteBuf payload = ByteBuf.smallBuffer();
    payload.writeInt32(ClientMessageType.entry.id);
    payload.writeInt32(GeneralEntryAction.action.id);
    payload.writeInt32(actionId);
    payload.writeInt32(deviceType.id);
    payload.writeBytes(utf8.encode(osName));

    outputStream.write(payload);
  }
}
