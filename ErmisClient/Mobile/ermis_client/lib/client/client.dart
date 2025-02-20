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
import 'common/message.dart';
import 'common/message_types/client_message_type.dart';
import 'common/results/ResultHolder.dart';
import 'common/results/entry_result.dart';
import 'common/user_device.dart';
import 'event_bus.dart';
import 'io/input_stream.dart';
import 'message_handler.dart';
import 'io/output_stream.dart';

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

      _inputStream = ByteBufInputStream(broadcastStream: broadcastStream!);
      _outputStream = ByteBufOutputStream(socket: _sslSocket!);

      _messageHandler = MessageHandler();
      _messageHandler.setSocket(_sslSocket!);
      _messageHandler.setByteBufInputStream(_inputStream!);
      _messageHandler.setByteBufOutputStream(_outputStream!);
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

  EventBus get eventBus => _messageHandler.eventBus;
  Commands get commands => _messageHandler.commands;
  int get clientID => _messageHandler.clientID;
  String? get displayName => _messageHandler.username;
  Uint8List? get profilePhoto => _messageHandler.profilePhoto;
  List<ChatSession>? get chatSessions => _messageHandler.chatSessions;
  List<ChatRequest>? get chatRequests => _messageHandler.chatRequests;
  ServerInfo get serverInfo => ServerInfo(uri!);
  List<UserDeviceInfo> get userDevices => _messageHandler.usesDevices;
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

  Future<ResultHolder> getCredentialsExchangeResult() async {
    ByteBuf msg = await inputStream.read();

    bool isSuccessful = msg.readBoolean();
    Uint8List resultMessageBytes = msg.readBytes(msg.readableBytes);

    return ResultHolder(isSuccessful, utf8.decode(resultMessageBytes));
  }

  Future<void> sendCredentials(Map<T, String> credentials) async {
    for (final MapEntry<T,String> credential in credentials.entries) {
      bool isAction = false;
      int credentialInt = credential.key.id;
      String credentialValue = credential.value;

      ByteBuf payload = ByteBuf.smallBuffer();
      payload.writeInt32(ClientMessageType.entry.id);
      payload.writeBoolean(isAction);
      payload.writeInt32(credentialInt);
      payload.writeBytes(Uint8List.fromList(credentialValue.codeUnits));

      outputStream.write(payload);
    }
  }

  Future<ResultHolder> getBackupVerificationCodeResult() async {
    ByteBuf payload = await inputStream.read();

    isLoggedIn = payload.readBoolean();
    Client.instance()._isLoggedIn = isLoggedIn;

    Uint8List resultMessageBytes = payload.readBytes(payload.readableBytes);

    return ResultHolder(isLoggedIn, String.fromCharCodes(resultMessageBytes));
  }

  void sendEntryType() {
    outputStream.write(ByteBuf.smallBuffer()
      ..writeInt32(ClientMessageType.entry.id)
      ..writeInt32(entryType.id));
  }

  Future<void> sendVerificationCode(int verificationCode) async {
    bool isAction = false;

    ByteBuf payload = ByteBuf.smallBuffer();
    payload.writeInt32(ClientMessageType.entry.id);
    payload.writeBoolean(isAction);
    payload.writeInt32(verificationCode);

    outputStream.write(payload);
  }

  Future<EntryResult> getResult() async {
    ByteBuf msg = await inputStream.read();

    isVerificationComplete = msg.readBoolean();
    isLoggedIn = msg.readBoolean();

    Client.instance()._isLoggedIn = isLoggedIn;
    List<int> resultMessageBytes = msg.readBytes(msg.readInt32());

    Map<AddedInfo, String> map = HashMap();
    EntryResult result = EntryResult(
        ResultHolder(isLoggedIn, String.fromCharCodes(resultMessageBytes)),
        map);

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
    payload.writeInt32(ClientMessageType.entry.id);
    payload.writeBoolean(isAction);
    payload.writeInt32(VerificationAction.resendCode.id);

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
    payload.writeInt32(ClientMessageType.entry.id);
    payload.writeBoolean(isAction);
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
    payload.writeBoolean(isAction);
    payload.writeInt32(actionId);

    outputStream.write(payload);
  }

  void addDeviceInfo(DeviceType deviceType, String osName) {
    bool isAction = true;
    int actionId = LoginAction.addDeviceInfo.id;

    ByteBuf payload = ByteBuf.smallBuffer();
    payload.writeInt32(ClientMessageType.entry.id);
    payload.writeBoolean(isAction);
    payload.writeInt32(actionId);
    payload.writeInt32(deviceType.id);
    payload.writeBytes(utf8.encode(osName));

    outputStream.write(payload);
  }
}
