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

import 'package:ermis_mobile/core/data_sources/managed_socket.dart';
import 'package:ermis_mobile/core/event_bus/app_event_bus.dart';
import 'package:ermis_mobile/core/models/account.dart';
import 'package:ermis_mobile/core/networking/user_info_manager.dart';
import 'package:ermis_mobile/core/services/database/models/local_account_info.dart';
import 'package:ermis_mobile/core/services/database/models/server_info.dart';
import 'package:ermis_mobile/features/authentication/domain/entities/requirements.dart';
import 'package:ermis_mobile/core/data/models/network/byte_buf.dart';
import 'package:ermis_mobile/core/networking/message_dispatcher.dart';
import 'package:ermis_mobile/core/models/message_events.dart';
import 'package:ermis_mobile/features/authentication/domain/entities/resultable.dart';
import 'package:flutter/foundation.dart';

import '../networking/common/results/change_password_result.dart';
import '../models/chat_request.dart';
import '../models/chat_session.dart';
import '../../features/authentication/domain/entities/added_info.dart';
import '../../features/authentication/domain/entities/create_account_info.dart';
import '../../features/authentication/domain/entities/entry_type.dart';
import '../../features/authentication/domain/entities/login_info.dart';
import '../../features/authentication/domain/entities/verification.dart';
import '../models/message.dart';
import '../networking/common/message_types/client_message_type.dart';
import '../networking/common/results/entry_result.dart';
import '../models/user_device.dart';
import '../data/models/network/input_stream.dart';
import '../networking/message_transmitter.dart';
import '../data/models/network/output_stream.dart';

enum ServerCertificateVerification { verify, ignore }

class ServerVerificationFailedException implements Exception {
  const ServerVerificationFailedException();
}

class Client {
  static final Client _instance = Client._();

  static Client instance() {
    return _instance;
  }

  bool _isConnectionRefused = false;
  bool _isConnectionReset = false;

  ByteBufInputStream? _inputStream;
  ByteBufOutputStream? _outputStream;

  ManagedSocket? _socket;
  Stream<Uint8List>? broadcastStream;

  bool _isLoggedIn = false;

  MessageTransmitter? _messageTransmitter;
  bool _isMessageDispatcherRunning = false;

  Client._();

  Future<void> initialize(Uri uri, ServerCertificateVerification scv) async {
    if (uri.port <= 0) {
      throw ArgumentError("Port cannot be below zero");
    }

    try {
      final sslContext = SecurityContext.defaultContext;
      final sslSocket = await SecureSocket.connect(
        uri.host,
        uri.port,
        context: sslContext,
        timeout: const Duration(seconds: 5),
        onBadCertificate: (X509Certificate cert) =>
            scv == ServerCertificateVerification.ignore,
      );

      broadcastStream = sslSocket.asBroadcastStream();

      UserInfoManager.serverInfo = ServerInfo(uri);

      _inputStream = ByteBufInputStream(socket: sslSocket, stream: broadcastStream!);
      _outputStream = ByteBufOutputStream(socket: sslSocket);

      _messageTransmitter = MessageTransmitter();
      _messageTransmitter!.setByteBufOutputStream(_outputStream!);

      _socket = ManagedSocket(sslSocket);
    } on HandshakeException {
      if (scv == ServerCertificateVerification.verify) {
        throw const ServerVerificationFailedException();
      }
      rethrow;
    } on SocketException {
      _isConnectionRefused = true;
      rethrow;
    }
  }

  Future<String> readServerVersion() async {
    ByteBuf payload = await _inputStream!.read();
    return String.fromCharCodes(payload.readRemainingBytes().toList());
  }

  /// Attempts to authenticate user by sending their email and password hash
  /// over the network to the server for validation.
  ///
  /// * `userInfo` The local account information containing the user's email
  ///                 and password hash.
  /// * A Future that resolves to a boolean indicating whether the login
  ///          attempt was successful.
  Future<bool> attemptHashedLogin(LocalAccountInfo accountInfo) async {
    ByteBuf buffer = ByteBuf.smallBuffer();
    buffer.writeInt32(ClientMessageType.entry.id);
    buffer.writeInt32(EntryType.login.id);

    // Email
    buffer.writeInt32(accountInfo.email.length);
    buffer.writeBytes(utf8.encode(accountInfo.email));

    // Password
    buffer.writeInt32(accountInfo.passwordHash.length);
    buffer.writeBytes(utf8.encode(accountInfo.passwordHash));

    // Device UUID
    buffer.writeBytes(utf8.encode(accountInfo.deviceUUID));

    _outputStream!.write(buffer);

    _isLoggedIn = (await _inputStream!.read()).readBoolean();
    if (_isLoggedIn) UserInfoManager.accountInfo = accountInfo;
    return _isLoggedIn;
  }

  Message sendMessageToClient(String text, int chatSessionIndex) {
    return _messageTransmitter!.sendMessageToClient(text, chatSessionIndex);
  }

  Message sendImageToClient(String fileName, Uint8List fileBytes, int chatSessionIndex) {
    return _messageTransmitter!.sendImageToClient(fileName, fileBytes, chatSessionIndex);
  }

  Message sendFileToClient(String fileName, Uint8List fileContentBytes, int chatSessionIndex) {
    return _messageTransmitter!.sendFileToClient(fileName, fileContentBytes, chatSessionIndex);
  }

  Message sendVoiceMessageToClient(String fileName, Uint8List fileContentBytes, int chatSessionIndex) {
    return _messageTransmitter!.sendVoiceToClient(fileName, fileContentBytes, chatSessionIndex);
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
      throw StateError("User can't start writing to the server if they aren't logged in");
    }

    await _messageTransmitter?.fetchUserInformation();
  }

  void startMessageDispatcher() {
    if (_isMessageDispatcherRunning) return;

    MessageDispatcher(inputStream: _inputStream!).debute();
    _isMessageDispatcherRunning = true;

    AppEventBus.instance.on<ConnectionResetEvent>().listen((e) {
      _isConnectionReset = true;
      _inputStream?.socket.destroy();
    });
  }

  Future<void> disconnect() async {
    await _socket?.ifActive((socket) async => await socket.close());
    _socket = null;
    _outputStream = null;
    _inputStream = null;
    broadcastStream = null;
    _messageTransmitter = null;
    _isMessageDispatcherRunning = false;
    _isConnectionRefused = false;
    _isConnectionReset = false;

    UserInfoManager.resetUserInformation();
    UserInfoManager.resetServerInformation();
  }

  Commands? get commands => _messageTransmitter?.commands;
  int get clientID => UserInfoManager.clientID;
  String? get displayName => UserInfoManager.username;
  Uint8List? get profilePhoto => UserInfoManager.profilePhoto;
  List<ChatSession>? get chatSessions => UserInfoManager.chatSessions;
  List<ChatRequest>? get chatRequests => UserInfoManager.chatRequests;
  ServerInfo? get serverInfo => UserInfoManager.serverInfo;
  List<UserDeviceInfo>? get userDevices => UserInfoManager.userDevices;
  List<Account>? get otherAccounts => UserInfoManager.otherAccounts;

  bool isLoggedIn() => _isLoggedIn;

  bool isConnectionRefused() => _isConnectionRefused;
  bool isConnectionReset() => _isConnectionReset;

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

    int id = buffer!.readInt32();
    return entryType == EntryType.createAccount
        ? CredentialValidationResult.fromId(id)!
        : LoginCredentialResult.fromId(id)!;
  }

  void sendCredentials(Map<T, String> credentials) {
    for (final MapEntry<T, String> credential in credentials.entries) {
      int credentialInt = credential.key.id;
      String credentialValue = credential.value;

      ByteBuf payload = ByteBuf.smallBuffer();
      payload.writeInt32(ClientMessageType.entry.id);
      payload.writeInt32(credentialInt);
      payload.writeBytes(utf8.encode(credentialValue));

      outputStream.write(payload);
    }
  }

  Future<EntryResult<Resultable>> getBackupVerificationCodeResult() async {
    ByteBuf payload = (await AppEventBus.instance.on<EntryMessage>().first).buffer;

    int entryId = payload.readInt32();
    Map<AddedInfo, String> addedInfo = HashMap();
    while (payload.readableBytes > 0) {
      AddedInfo key = AddedInfo.fromId(payload.readInt32());
      Uint8List message = payload.readBytes(payload.readInt32());
      addedInfo[key] = utf8.decode(message.toList());
    }

    EntryResult result = EntryResult(LoginResult.fromId(entryId)!, addedInfo);
    isLoggedIn = result.success;
    Client.instance()._isLoggedIn = isLoggedIn;
    return result;
  }

  void sendEntryType() {
    outputStream.write(ByteBuf(8)
      ..writeInt32(ClientMessageType.entry.id)
      ..writeInt32(entryType.id));
  }

  void sendVerificationCode(int verificationCode) {
    ByteBuf payload = ByteBuf.smallBuffer();
    payload.writeInt32(ClientMessageType.entry.id);
    payload.writeInt32(verificationCode);

    outputStream.write(payload);
  }

  Future<EntryResult> getChangePasswordResult() async {
    ByteBuf? buffer;
    await AppEventBus.instance.on<EntryMessage>().first.then((EntryMessage msg) {
      buffer = msg.buffer;
    });

    if (buffer == null) throw Exception("Buffer is null");
    ByteBuf payload = buffer!;

    int verifyId = payload.readInt32();
    final verificationStatus = VerificationResult.fromId(verifyId)!;
    if (!verificationStatus.isSuccessful) {
      return EntryResult.noInfo(verificationStatus);
    }

    int entryId = payload.readInt32();
    Map<AddedInfo, String> addedInfo = HashMap();
    while (payload.readableBytes > 0) {
      AddedInfo key = AddedInfo.fromId(payload.readInt32());
      Uint8List message = payload.readBytes(payload.readInt32());
      addedInfo[key] = utf8.decode(message.toList());
    }

    EntryResult result = EntryResult(ChangePasswordResult.fromId(entryId), addedInfo);
    return result;
  }  

  Future<EntryResult> getResult() async {
    ByteBuf? buffer;
    await AppEventBus.instance.on<EntryMessage>().first.then((EntryMessage msg) {
      buffer = msg.buffer;
    });

    if (buffer == null) throw Exception("Buffer is null");
    ByteBuf payload = buffer!;

    int verifyId = payload.readInt32();
    final verificationStatus = VerificationResult.fromId(verifyId)!;
    if (!verificationStatus.isSuccessful) {
      return EntryResult.noInfo(verificationStatus);
    }

    int entryId = payload.readInt32();
    Map<AddedInfo, String> addedInfo = HashMap();
    while (payload.readableBytes > 0) {
      AddedInfo key = AddedInfo.fromId(payload.readInt32());
      Uint8List message = payload.readBytes(payload.readInt32());
      addedInfo[key] = utf8.decode(message.toList());
    }

    EntryResult entryResult = EntryResult(
        entryType == EntryType.createAccount
            ? CreateAccountResult.fromId(entryId)!
            : LoginResult.fromId(entryId)!,
        addedInfo);

    isLoggedIn = entryResult.success;
    Client.instance()._isLoggedIn = isLoggedIn;
    return entryResult;
  }

  void resendVerificationCodeToEmail() {
    ByteBuf payload = ByteBuf.smallBuffer();
    payload.writeInt32(ClientMessageType.entry.id);
    payload.writeInt32(GeneralEntryAction.action.id);
    payload.writeInt32(VerificationAction.resendCode.id);

    outputStream.write(payload);
  }

  void setDeviceUUID(String uuid) {
    int actionId = LoginAction.setDeviceUUID.id;

    ByteBuf payload = ByteBuf.smallBuffer();
    payload.writeInt32(ClientMessageType.entry.id);
    payload.writeInt32(GeneralEntryAction.action.id);
    payload.writeInt32(actionId);
    payload.writeBytes(utf8.encode(uuid));

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

  void addDeviceInfo(DeviceType deviceType, String osName) {
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
  void setPasswordType(PasswordType type) {
    int actionId = LoginAction.togglePasswordType.id;

    ByteBuf payload = ByteBuf.smallBuffer();
    payload.writeInt32(ClientMessageType.entry.id);
    payload.writeInt32(GeneralEntryAction.action.id);
    payload.writeInt32(actionId);
    payload.writeInt32(type.id);

    outputStream.write(payload);
  }

  void addDeviceInfo(DeviceType deviceType, String osName) {
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
