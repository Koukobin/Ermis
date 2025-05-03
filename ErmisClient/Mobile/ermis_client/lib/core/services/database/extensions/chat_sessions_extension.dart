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


import 'dart:typed_data';

import 'package:ermis_client/core/services/database/database_service.dart';
import 'package:ermis_client/core/services/database/models/server_info.dart';
import 'package:sqflite/sqflite.dart';
import 'package:zstandard/zstandard.dart';

import '../../../models/chat_session.dart';
import '../../../models/member.dart';
import '../../../models/member_icon.dart';
import '../../../networking/common/message_types/client_status.dart';

extension ChatSessionsExtension on DBConnection {
  Future<List<int>> fetchChatSessionIDS({
    required ServerInfo server,
    required String email,
  }) async {
    final db = await database;

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

  Future<List<ChatSession>> fetchChatSessions({
    required ServerInfo server,
    required int clientIDExclude,
  }) async {
    final db = await database;

    final List<Map<String, dynamic>> results = await db.rawQuery(
      '''
        SELECT * 
        FROM chat_session_members AS csm
        INNER JOIN members AS m ON m.client_id = csm.client_id
        WHERE m.server_url = ? AND NOT m.client_id = ? 
      ''',
      [server.toString(), clientIDExclude],
    );

    Map<int, ChatSession> chatSessions = {};
    Map<int, Member> cache = {};

    for (Map<String, dynamic> record in results) {
      final int clientID = record['client_id'] as int;
      final int chatSessionID = record['chat_session_id'] as int;

      chatSessions.putIfAbsent(chatSessionID, () => ChatSession(chatSessionID, -1));

      Member? cached = cache[clientID];
      if (cached != null) {
        chatSessions[chatSessionID]!.members.add(cached);
        continue;
      }

      final String displayName = record['display_name'] as String;
      final int lastUpdatedAtEpochSecond = record['last_updated_at'] as int;
            
      final Uint8List compressedProfilePhoto = record['profile_photo'] as Uint8List;
      final Uint8List decompressedProfile = (await compressedProfilePhoto.decompress())!;

      Member member = Member(
        displayName,
        clientID,
        MemberIcon(decompressedProfile),
        ClientStatus.offline,
        lastUpdatedAtEpochSecond,
      );

      chatSessions[chatSessionID]!.members.add(member);

      cache[clientID] = member;
    }

    return chatSessions.values.toList();
  }

  Future<void> insertChatSessionMember({
    required String serverUrl,
    required int chatSessionId,
    required int clientId,
  }) async {
    final db = await database;

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

  Future<void> insertChatSession(String serverUrl, int chatSessionId) async {
    final db = await database;

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
    final db = await database;

    // For some reason, they have to be deleted individually each
    await db.delete(
      'chat_messages',
      where: 'server_url = ? AND chat_session_id = ?',
      whereArgs: [serverUrl, chatSessionId],
    );
    await db.delete(
      'chat_session_members',
      where: 'server_url = ? AND chat_session_id = ?',
      whereArgs: [serverUrl, chatSessionId],
    );
    await db.delete(
      'chat_sessions',
      where: 'server_url = ? AND chat_session_id = ?',
      whereArgs: [serverUrl, chatSessionId],
    );
  }
}