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

import 'package:ermis_client/client/common/message.dart';
import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ErmisDB {
  static DBConnection? conn;

  ErmisDB._() {
    throw Exception(
        "Database cannot be constructed since it is statically initialized!");
  }

  static DBConnection getConnection() {
    conn ??= DBConnection._create();
    return conn!;
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
    return openDatabase(
        join(await getDatabasesPath(), 'ermis_sqlite_database_5.db'),
        onCreate: (db, version) async {
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

      // 'chat_sessions' table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS chat_sessions (
          server_url TEXT NOT NULL REFERENCES servers(server_url) ON DELETE CASCADE,
          chat_session_id INTEGER NOT NULL,
          PRIMARY KEY (server_url, chat_session_id)
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
    }, version: 1);
  }

  Future<void> addUserAccount(UserAccount userAccount, ServerInfo serverInfo) async {
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

  Future<UserAccount?> getLastUsedAccount(ServerInfo serverInfo) async {
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

    return UserAccount(
        email: email,
        passwordHash: passwordHash,
        lastUsed: DateTime.parse(lastUsed));
  }

  /// Retrieves the list of user accounts associated with a specified server.
  /// Each account includes the email, password hash, and the timestamp of last use.
  /// The accounts are sorted by the last used timestamp in descending order.
  Future<List<UserAccount>> getUserAccounts(ServerInfo serverInfo) async {
    final db = await _database;

    final List<Map<String, Object?>> userAccountMap = await db.query(
      "server_accounts",
      columns: ["email", "password_hash", "last_used"],
      where: 'server_url = ?',
      whereArgs: [serverInfo.toString()],
    );

    List<UserAccount> userAccount = userAccountMap.map((record) {
      final String email = record['email'] as String;
      final String passwordHash = record['password_hash'] as String;
      final String lastUsed = record['last_used'] as String;
      return UserAccount(
          email: email,
          passwordHash: passwordHash,
          lastUsed: DateTime.parse(lastUsed));
    }).toList();

    userAccount.sort((a, b) {
      final DateTime lastUsedA = a.lastUsed;
      final DateTime lastUsedB = b.lastUsed;

      return lastUsedB.compareTo(lastUsedA); // Most recent first
    });

    return userAccount;
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

  Future<void> insertChatSession(String serverUrl, int chatSessionId) async {
    final db = await _database;

    await db.insert(
      'chat_sessions',
      {
        'server_url': serverUrl,
        'chat_session_id': chatSessionId,
        'created_at':
            DateTime.now().toIso8601String(), // Optional: Override default
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

  Future<void> insertChatMessage({required ServerInfo serverInfo, required Message message}) async {
    final db = await _database;

    await db.insert(
      'chat_messages',
      {
        'server_url': serverInfo.toString(),
        'chat_session_id': message.getChatSessionID,
        'message_id': message.getMessageID,
        'client_id': message.getClientID,
        'text': message.getText,
        'file_name': message.getFileName,
        'content_type': message.getContentType,
        'ts_entered':
            DateTime.fromMicrosecondsSinceEpoch(message.getTimeWritten),
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
}

class UserAccount {
  final String email;
  final String passwordHash;
  final DateTime lastUsed;

  factory UserAccount.fuck({required String email, required String passwordHash}) {
    return UserAccount(email: email, passwordHash: passwordHash, lastUsed: DateTime.now());
  }

  UserAccount({required this.email, required this.passwordHash, required this.lastUsed});

  // bool isValid() => email != null || passwordHash != null;
  // bool isNotValid() => !isValid();

  Map<String, Object?> toMap() {
    return {
      'email': email,
      'password_hash': passwordHash,
      'last_used': lastUsed.toIso8601String()
    };
  }
}

class InvalidServerUrlException implements Exception {

  String message;

  InvalidServerUrlException(this.message);

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

  Map<String, Object?> toMap() {
    return {
      'server_url': _serverUrl.toString(),
      'last_used': lastUsed.toIso8601String()
    };
  }

  Uri get serverUrl => _serverUrl;
  InternetAddress get address => _address;
  int get port => _port;

  @override
  String toString() {
    return serverUrl.toString();
  }
}
