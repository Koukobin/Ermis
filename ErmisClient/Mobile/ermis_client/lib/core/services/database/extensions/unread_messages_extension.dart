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

import 'package:ermis_client/core/services/database/database_service.dart';
import 'package:ermis_client/core/services/database/models/server_info.dart';
import 'package:sqflite/sqflite.dart';

extension UnreadMessagesExtension on DBConnection {

  Future<void> insertUnreadMessage(ServerInfo serverInfo, int chatSessionID, int messageID) async {
    final db = await database;

    await db.insert(
      'unread_messages',
      {
        'server_url': serverInfo.toString(),
        'chat_session_id': chatSessionID,
        'message_id': messageID,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteUnreadMessages(ServerInfo serverInfo, int chatSessionID, List<int> messageIDs) async {
    // Create copy of messages to avoid "Unhandled Exception: Concurrent modification during iteration."
    // I have no idea from where this error originates.
    final messagesCopy = List<int>.from(messageIDs);

    for (int messageID in messagesCopy) {
      await deleteUnreadMessage(serverInfo, chatSessionID, messageID);
    }
  }

  Future<void> deleteUnreadMessage(ServerInfo serverInfo, int chatSessionID, int messageID) async {
    final db = await database;

    await db.delete(
      'unread_messages',
      where: 'server_url = ? AND chat_session_id = ? AND message_id = ?',
      whereArgs: [serverInfo.toString(), chatSessionID, messageID],
    );
  }

  Future<List<int>?> retrieveUnreadMessages(ServerInfo serverInfo, int chatSessionID) async {
    final db = await database;

    final List<Map<String, Object?>> messagesMap = await db.query(
      'unread_messages',
      where: 'server_url = ? AND chat_session_id = ?',
      whereArgs: [serverInfo.toString(), chatSessionID],
    );

    List<int> messages = messagesMap.map((record) {
      final int messageID = record['message_id'] as int;
      return messageID;
    }).toList();

    return messages.isEmpty ? null : messages;
  }
}