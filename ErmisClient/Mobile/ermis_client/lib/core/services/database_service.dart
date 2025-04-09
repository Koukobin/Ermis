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

import 'dart:io';
import 'dart:typed_data';

import 'package:ermis_client/core/models/chat_session.dart';
import 'package:ermis_client/core/models/member_icon.dart';
import 'package:ermis_client/core/models/message.dart';
import 'package:ermis_client/client/common/message_types/content_type.dart';
import 'package:ermis_client/features/authentication/domain/client_status.dart';
import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../client/common/message_types/message_delivery_status.dart';

class ErmisDB {
  static DBConnection? _conn;

  ErmisDB._() {
    throw Exception(
        "Database cannot be constructed since it is statically initialized!");
  }

  static DBConnection getConnection() {
    _conn ??= DBConnection._create();
    return _conn!;
  }
}

class DBConnection {

  final Future<Database> _database;

  DBConnection._(this._database);

  factory DBConnection._create() {
    final database = _initializeDB();
    return DBConnection._(database);
  }

  static Future<Database> _initializeDB() async {
    // "Avoid errors caused by flutter upgrade.
    // Importing 'package:flutter/widgets.dart' is required." by flutter documentation
    // P.S. I don't know exactly why this is necessary, but the documentation said so
    WidgetsFlutterBinding.ensureInitialized();

    final String databaseFolderPath = await getDatabasesPath();
    final String path = join(databaseFolderPath, 'ermis_sqlite_database_6.db');

    Database db = await openDatabase(
      path,
      onCreate: (Database db, int version) async {},
      onDowngrade: (Database db, int oldVersion, int newVersion) async {},
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (oldVersion < 2) {
          await db.execute('DROP TABLE members;');
          await db.execute('DROP TABLE chat_session_members;');
          await db.execute('DROP TABLE chat_sessions;');
          await db.execute('DROP TABLE chat_messages;');
        }
      },
      version: 2,
    );

    // Create the 'servers' table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS servers (
        server_url TEXT NOT NULL,
        last_used DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (server_url)
      );
    ''');

    // Create 'server_accounts' table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS server_accounts (
        server_url TEXT NOT NULL REFERENCES servers(server_url) ON DELETE CASCADE,
        email TEXT NOT NULL,
        password_hash TEXT NOT NULL,
        last_used DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (server_url, email)
      );
    ''');

    // Create 'server_profiles' table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS server_profiles (
        server_url TEXT NOT NULL REFERENCES servers(server_url) ON DELETE CASCADE,
        email TEXT NOT NULL REFERENCES server_accounts(email) ON DELETE CASCADE,
        display_name TEXT NOT NULL,
        client_id INTEGER NOT NULL,
        profile_photo BLOB NOT NULL,
        last_updated_at TIMESTAMP NOT NULL,
        PRIMARY KEY (server_url, email, client_id)
      );
    ''');

    // await db.execute('''
    //   DROP TABLE members;
    // ''');
    // await db.execute('''
    //   DROP TABLE chat_session_members;
    // ''');
    // await db.execute('''
    //   DROP TABLE chat_sessions;
    // ''');

    // 'chat_sessions' table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS chat_sessions (
        server_url TEXT NOT NULL REFERENCES servers(server_url) ON DELETE CASCADE,
        chat_session_id INTEGER NOT NULL,
        PRIMARY KEY (server_url, chat_session_id)
      );
    ''');

    // 'members' table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS members (
        server_url TEXT NOT NULL REFERENCES servers(server_url) ON DELETE CASCADE,
        display_name TEXT NOT NULL,
        client_id INTEGER NOT NULL,
        profile_photo BLOB NOT NULL,
        last_updated_at TIMESTAMP NOT NULL,
        PRIMARY KEY (server_url, client_id)
      );
    ''');

    // 'chat_session_members' table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS chat_session_members (
        server_url TEXT NOT NULL REFERENCES members(server_url) ON DELETE CASCADE,
        chat_session_id INTEGER NOT NULL REFERENCES chat_sessions (chat_session_id) ON DELETE CASCADE,
        client_id INTEGER NOT NULL REFERENCES members (client_id),
        PRIMARY KEY (server_url, chat_session_id, client_id)
      );
    ''');

    // 'chat_messages' table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS chat_messages (
        server_url TEXT NOT NULL,
        chat_session_id INTEGER NOT NULL,
        message_id INTEGER NOT NULL,
        client_id INTEGER NOT NULL,
        text TEXT,
        file_name TEXT,
        file_content_id TEXT,
        content_type INTEGER NOT NULL,
        ts_entered TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (server_url, chat_session_id, message_id),
        CHECK (text IS NOT NULL OR file_content_id IS NOT NULL),
        FOREIGN KEY (server_url, chat_session_id)
            REFERENCES chat_sessions (server_url, chat_session_id) ON DELETE CASCADE
      );
    ''');

    return db;
  }

  Future<void> addUserAccount(LocalAccountInfo userAccount, ServerInfo serverInfo) async {
    final db = await _database;

    await db.insert(
        'server_accounts',
        {
          'server_url': serverInfo.toString(),
          'email': userAccount.email,
          'password_hash': userAccount.passwordHash,
          'last_used': userAccount.lastUsed.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<LocalAccountInfo?> getLastUsedAccount(ServerInfo serverInfo) async {
    final db = await _database;

    final List<Map<String, dynamic>> userAccounts = await db.query(
      'server_accounts',
      columns: ['email', 'password_hash', 'last_used'],
      where: 'server_url = ?',
      whereArgs: [serverInfo.toString()],
      orderBy: 'last_used DESC',
      limit: 1,
    );

    // If the query returns a result, return the first row; otherwise, return null.
    final firstRow = userAccounts.firstOrNull;
    if (firstRow == null) {
      return null;
    }

    final String email = firstRow['email'] as String;
    final String passwordHash = firstRow['password_hash'] as String;
    final String lastUsed = firstRow['last_used'] as String;

    return LocalAccountInfo(
        email: email,
        passwordHash: passwordHash,
        lastUsed: DateTime.parse(lastUsed));
  }

  /// Retrieves the list of user accounts associated with a specified server.
  /// Each account includes the email, password hash, and the timestamp of last use.
  /// The accounts are sorted by the last used timestamp in descending order.
  Future<List<LocalAccountInfo>> getUserAccounts(ServerInfo serverInfo) async {
    final db = await _database;

    final List<Map<String, Object?>> userAccountMap = await db.query(
      "server_accounts",
      columns: ["email", "password_hash", "last_used"],
      where: 'server_url = ?',
      whereArgs: [serverInfo.toString()],
    );

    List<LocalAccountInfo> userAccounts = userAccountMap.map((record) {
      final String email = record['email'] as String;
      final String passwordHash = record['password_hash'] as String;
      final String lastUsed = record['last_used'] as String;
      return LocalAccountInfo(
          email: email,
          passwordHash: passwordHash,
          lastUsed: DateTime.parse(lastUsed));
    }).toList();

    userAccounts.sort((a, b) {
      final DateTime lastUsedA = a.lastUsed;
      final DateTime lastUsedB = b.lastUsed;

      return lastUsedB.compareTo(lastUsedA); // Most recent first
    });

    return userAccounts;
  }

  Future<LocalUserInfo?> getLocalUserInfo(ServerInfo serverInfo, String email) async {
    final db = await _database;

    final List<Map<String, Object?>> profilesMap = await db.query(
      "server_profiles",
      columns: ["display_name", "client_id", "profile_photo", "last_updated_at"],
      where: 'server_url = ? AND email = ?',
      whereArgs: [serverInfo.toString(), email],
    );

    Map<String, Object?>? record = profilesMap.firstOrNull;

    if (record == null) return null;

    final String displayName = record['display_name'] as String;
    final int clientID = record['client_id'] as int;
    final Uint8List profilePhoto = record['profile_photo'] as Uint8List;
    final int lastUsed = record['last_updated_at'] as int;

    return LocalUserInfo(
        displayName: displayName,
        clientID: clientID,
        profilePhoto: profilePhoto,
        lastUpdatedEpochSecond: lastUsed);
  }

  Future<void> updateServerUrlLastUsed(ServerInfo serverInfo) async {
    final db = await _database;

    await db.update(
      'servers',
      {'last_used': serverInfo.lastUsed.toIso8601String()}, // Set current timestamp
      where: 'server_url = ?',
      whereArgs: [
        serverInfo.toString() // Identifier
      ],
    );
  }

  Future<void> insertServerInfo(ServerInfo info) async {
    final db = await _database;

    info.lastUsed = DateTime.now();
    await db.insert(
      'servers',
      info.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeServerInfo(ServerInfo info) async {

    final db = await _database;

    await db.delete(
      'servers',
      where: 'server_url = ?',
      whereArgs: [info.serverUrl.toString()]
    );
  }

  Future<ServerInfo> getServerUrlLastUsed() async {
    return (await getServerUrls())[0];
  }

  /// Fetches all server urls created by user sorted by most recently used
  Future<List<ServerInfo>> getServerUrls() async {
    final db = await _database;

    final List<Map<String, Object?>> serverInfoMap = await db.query('servers');

    List<ServerInfo> servers = serverInfoMap.map((record) {
      final String serverUrl = record['server_url'] as String;
      final String lastUsed = record['last_used'] as String;

      return ServerInfo(
        Uri.parse(serverUrl),
        DateTime.parse(lastUsed),
      );
    }).toList();

    servers.sort((a, b) {
      final DateTime lastUsedA = a.lastUsed;
      final DateTime lastUsedB = b.lastUsed;

      return lastUsedB.compareTo(lastUsedA); // Most recent first
    });

    return servers;
  }

  Future<void> storeFriendInfo({
    required ServerInfo serverInfo,
    required Member member,
  }) async {
    final db = await _database;

    await db.insert(
      'members',
      {
        'server_url': serverInfo.toString(),
        'display_name': member.username,
        'client_id': member.clientID,
        'profile_photo': member.icon.profilePhoto,
        'last_updated_at': member.icon.lastUpdatedAtEpochSecond,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Member>> fetchFriendInfo({
    required ServerInfo server,
  }) async {
    final db = await _database;

    final List<Map<String, Object?>> membersMap = await db.query(
      'members',
      where: 'server_url = ?',
      whereArgs: [server.toString()],
    );

    List<Member> members = membersMap.map((record) {
      final String displayName = record['display_name'] as String;
      final int clientID = record['client_id'] as int;
      final Uint8List profilePhoto = record['profile_photo'] as Uint8List;
      final int lastUpdatedAtEpochSecond = record['last_updated_at'] as int;

      return Member(
        displayName,
        clientID,
        MemberIcon(profilePhoto, lastUpdatedAtEpochSecond),
        ClientStatus.offline,
      );
    }).toList();

    return members;
  }

  Future<List<int>> fetchChatSessions({
    required ServerInfo server,
  }) async {
    final db = await _database;

    final List<Map<String, dynamic>> results = await db.rawQuery(
      '''
    SELECT *
    FROM chat_sessions
    WHERE server_url = ?
  ''',
      [server.toString()],
    );

    List<int> members = results.map((Map<String, dynamic> record) {
      final int sessionID = record['chat_session_id'] as int;
      return sessionID;
    }).toList();

    return members;
  }

  Future<List<Member>> fetchMembersAssociatedWithChatSession({
    required ServerInfo server,
    required int chatSessionID,
  }) async {
    final db = await _database;

    final List<Map<String, dynamic>> results = await db.rawQuery(
      '''
        SELECT m.*
        FROM members m
        JOIN chat_session_members csm 
            ON m.server_url = csm.server_url 
            AND m.client_id = csm.client_id
        WHERE csm.chat_session_id = ? AND csm.server_url = ?;
      ''',
      [chatSessionID, server.toString()],
    );

    List<Member> members = results.map((Map<String, dynamic> record) {
      final String displayName = record['display_name'] as String;
      final int clientID = record['client_id'] as int;
      final Uint8List profilePhoto = record['profile_photo'] as Uint8List;
      final int lastUpdatedAtEpochSecond = record['last_updated_at'] as int;

      return Member(
        displayName,
        clientID,
        MemberIcon(profilePhoto, lastUpdatedAtEpochSecond),
        ClientStatus.offline,
      );
    }).toList();

    return members;
  }

  Future<void> insertChatSessionMember({
    required String serverUrl,
    required int chatSessionId,
    required int clientId,
  }) async {
    final db = await _database;

    await db.insert(
      'chat_session_members',
      {
        'server_url': serverUrl,
        'chat_session_id': chatSessionId,
        'client_id': clientId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertChatSessionMembers({
    required String serverUrl,
    required int chatSessionId,
    required List<int> memberIDs,
  }) async {
    for (int clientID in memberIDs) {
      await insertChatSessionMember(serverUrl: serverUrl, chatSessionId: chatSessionId, clientId: clientID);
    }
  }

  Future<void> insertMembers({
    required String serverUrl,
    required List<Member> members,
  }) async {
    for (Member member in members) {
      await insertMember(serverUrl: serverUrl, member: member);
    }
  }

  Future<void> insertMember({
    required String serverUrl,
    required Member member,
  }) async {
    final db = await _database;

    await db.insert(
      'members',
      {
        'server_url': serverUrl,
        'display_name': member.username,
        'client_id': member.clientID,
        'profile_photo': member.icon.profilePhoto,
        'last_updated_at': member.icon.lastUpdatedAtEpochSecond,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertChatSession(String serverUrl, int chatSessionId) async {
    final db = await _database;

    await db.insert(
      'chat_sessions',
      {
        'server_url': serverUrl,
        'chat_session_id': chatSessionId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteChatSession(String serverUrl, int chatSessionId) async {
    final db = await _database;

    await db.delete(
      'chat_sessions',
      where: 'server_url = ? AND chat_session_id = ?',
      whereArgs: [serverUrl, chatSessionId],
    );
  }

  Future<void> insertChatMessages({required ServerInfo serverInfo, required List<Message> messages}) async {
    // Create copy of messages to avoid "Unhandled Exception: Concurrent modification during iteration."
    // I have no idea from where this error originates.
    final messagesCopy = List<Message>.from(messages);

    for (Message message in messagesCopy) {
      await insertChatMessage(serverInfo: serverInfo, message: message);
    }
  }

  Future<void> insertChatMessage({required ServerInfo serverInfo, required Message message}) async {
    final db = await _database;

    await db.insert(
      'chat_messages',
      {
        'server_url': serverInfo.toString(),
        'chat_session_id': message.chatSessionID,
        'message_id': message.messageID,
        'client_id': message.clientID,
        'text': message.text,
        'file_name': message.fileName,
        'content_type': message.contentType.id,
        'ts_entered': DateTime.fromMicrosecondsSinceEpoch(message.epochSecond).toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteChatMessage(
    String serverUrl,
    int chatSessionId,
    int messageId,
  ) async {
    final db = await _database;

    await db.delete(
      'chat_messages',
      where: 'server_url = ? AND chat_session_id = ? AND message_id = ?',
      whereArgs: [serverUrl, chatSessionId, messageId],
    );
  }

  Future<List<Message>> retieveChatMessages(ServerInfo serverInfo, int chatSessionID) async {
    final db = await _database;

    final List<Map<String, Object?>> messagesMap = await db.query(
      'chat_messages',
      where: 'server_url = ? AND chat_session_id = ?',
      whereArgs: [serverInfo.toString(), chatSessionID],
    );

    List<Message> messages = messagesMap.map((record) {
      final int clientID = record['client_id'] as int;
      final int messageID = record['client_id'] as int;
      final String timeWritten = record['ts_entered'] as String;
      final MessageContentType contentType = MessageContentType.fromId(record['content_type'] as int);
      final String? text = record['text'] as String?;
      final String? fileName = record['text'] as String?;

      return Message(
          username: "",
          clientID: clientID,
          messageID: messageID,
          chatSessionID: chatSessionID,
          chatSessionIndex: -1,
          epochSecond: DateTime.parse(timeWritten).millisecondsSinceEpoch,
          text: text != null ? Uint8List.fromList(text.codeUnits) : null,
          fileName: fileName != null ? Uint8List.fromList(fileName.codeUnits) : null,
          contentType: contentType,
          deliveryStatus: MessageDeliveryStatus.delivered);
    }).toList();

    return messages;
  }
}

class LocalAccountInfo {
  final String email;
  final String passwordHash;
  final DateTime lastUsed;

  factory LocalAccountInfo.fuck({
    required String email,
    required String passwordHash,
  }) {
    return LocalAccountInfo(
        email: email, passwordHash: passwordHash, lastUsed: DateTime.now());
  }

  const LocalAccountInfo({
    required this.email,
    required this.passwordHash,
    required this.lastUsed,
  });

  Map<String, Object?> toMap() {
    return {
      'email': email,
      'password_hash': passwordHash,
      'last_used': lastUsed.toIso8601String()
    };
  }
}

class LocalUserInfo {
  final String displayName;
  final int clientID;
  final Uint8List profilePhoto;
  final int lastUpdatedEpochSecond;

  const LocalUserInfo({
    required this.displayName,
    required this.clientID,
    required this.profilePhoto,
    required this.lastUpdatedEpochSecond,
  });

  Map<String, Object?> toMap() {
    return {
      'display_name': displayName,
      'client_id': clientID,
      'profile_photo': profilePhoto,
      'last_updated_at': lastUpdatedEpochSecond,
    };
  }
}

class InvalidServerUrlException implements Exception {
  final String message;

  const InvalidServerUrlException(this.message);

  @override
  String toString() {
    return message;
  }
}

class ServerInfo {
  final Uri _serverUrl;
  final InternetAddress _address;
  final int _port;
  DateTime lastUsed;

  factory ServerInfo(Uri serverUrl, [DateTime? lastUsed]) {
    if (!serverUrl.toString().startsWith("https://")) {
      serverUrl = Uri.parse("https://${serverUrl.toString()}");
    }

    // Check if url is valid
    if (!(serverUrl.hasScheme && serverUrl.hasAuthority)) {
      throw InvalidServerUrlException("Invalid server URL: $serverUrl");
    }

    InternetAddress address = InternetAddress(serverUrl.host);
    int port = serverUrl.port;

    return ServerInfo._(serverUrl, address, port, lastUsed ?? DateTime.now());
  }

  ServerInfo._(this._serverUrl, this._address, this._port, this.lastUsed);

  Uri get serverUrl => _serverUrl;
  InternetAddress get address => _address;
  int get port => _port;

  Map<String, Object?> toMap() {
    return {
      'server_url': _serverUrl.toString(),
      'last_used': lastUsed.toIso8601String()
    };
  }

  @override
  bool operator ==(Object other) =>
      other is ServerInfo &&
      other.runtimeType == runtimeType &&
      other.serverUrl == serverUrl;

  @override
  int get hashCode => serverUrl.hashCode;

  @override
  String toString() {
    return serverUrl.toString();
  }
}
