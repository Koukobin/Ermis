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


import 'dart:convert';

import 'package:ermis_mobile/core/services/database/database_service.dart';
import 'package:ermis_mobile/core/services/database/models/server_info.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../../../models/message.dart';
import '../../../networking/common/message_types/content_type.dart';
import '../../../networking/common/message_types/message_delivery_status.dart';
import '../utils/content_type_converter.dart';

extension ChatMessagesExtension on DBConnection {
  Future<void> insertChatMessages({required ServerInfo serverInfo, required List<Message> messages}) async {
    // Create copy of messages to avoid "Unhandled Exception: Concurrent modification during iteration."
    // I have no idea from where this error originates.
    final messagesCopy = List<Message>.from(messages);

    for (Message message in messagesCopy) {
      await insertChatMessage(serverInfo: serverInfo, message: message);
    }
  }

  Future<int> insertChatMessage({
    required ServerInfo serverInfo,
    required Message message,
    ConflictAlgorithm onConflict = ConflictAlgorithm.ignore,
  }) async {
    final db = await database;

    final epochSecond = message.epochSecond;
    
    late final String tsEntered;

    // Ensure epochSecond is within valid DateTime range
    if (epochSecond < -8640000000000 ~/ 1000 || epochSecond > 8640000000000 ~/ 1000) {
      tsEntered = DateTime.fromMillisecondsSinceEpoch(epochSecond).toIso8601String();

      if (kDebugMode) {
        debugPrint("EPOCH SECOND $epochSecond IS OUT OF VALID $DateTime RANGE");
        debugPrint("EPOCH SECOND $epochSecond IS OUT OF VALID $DateTime RANGE");
        debugPrint("EPOCH SECOND $epochSecond IS OUT OF VALID $DateTime RANGE");
        debugPrint("EPOCH SECOND $epochSecond IS OUT OF VALID $DateTime RANGE");
        debugPrint("EPOCH SECOND $epochSecond IS OUT OF VALID $DateTime RANGE");
        debugPrint("EPOCH SECOND $epochSecond IS OUT OF VALID $DateTime RANGE");
        debugPrint("EPOCH SECOND $epochSecond IS OUT OF VALID $DateTime RANGE");
        debugPrint("EPOCH SECOND $epochSecond IS OUT OF VALID $DateTime RANGE");
        debugPrint("EPOCH SECOND $epochSecond IS OUT OF VALID $DateTime RANGE");
        debugPrint("EPOCH SECOND $epochSecond IS OUT OF VALID $DateTime RANGE");
      }
    }
    tsEntered = DateTime.fromMillisecondsSinceEpoch(epochSecond * 1000).toIso8601String();

    int resultUpdate = await db.insert(
      'chat_messages',
      {
        'server_url': serverInfo.toString(),
        'display_name': message.username,
        'chat_session_id': message.chatSessionID,
        'message_id': message.messageID,
        'client_id': message.clientID,
        'text': message.text,
        'file_name': message.fileName,
        'content_type': ContentTypeConverter.contentTypesToDatabaseInts[message.contentType],
        'delivery_status': DeliveryStatusConverter.deliveryStatusToDatabaseInts[message.deliveryStatus],
        'ts_entered': tsEntered,
      },
      conflictAlgorithm: onConflict,
    );

    return resultUpdate;
  }

  Future<void> deleteChatMessage(
    String serverUrl,
    int chatSessionId,
    int messageId,
  ) async {
    final db = await database;

    await db.delete(
      'chat_messages',
      where: 'server_url = ? AND chat_session_id = ? AND message_id = ?',
      whereArgs: [serverUrl, chatSessionId, messageId],
    );
  }

  Future<List<Message>> retrieveChatMessages({
    required ServerInfo serverInfo,
    required int chatSessionID,
    required int? offset,
  }) async {
    final db = await database;

    final List<Map<String, Object?>> messagesMap = await db.query(
      'chat_messages',
      where: 'server_url = ? AND chat_session_id = ?',
      whereArgs: [serverInfo.toString(), chatSessionID],
      orderBy: "message_id DESC",
      limit: 100,
      offset: offset,
    );

    List<Message> messages = messagesMap.map((record) {
      final String displayName = record['display_name'] as String;
      final int clientID = record['client_id'] as int;
      final int messageID = record['message_id'] as int;
      final String timeWritten = record['ts_entered'] as String;
      final MessageContentType contentType = ContentTypeConverter.databaseIntsToContentTypes[record['content_type'] as int]!;
      final MessageDeliveryStatus deliveryStatus = DeliveryStatusConverter.databaseIntsToDeliveryStatus[record['delivery_status'] as int]!;
      final String? text = record['text'] as String?;
      final String? fileName = record['file_name'] as String?;

      return Message(
        username: displayName,
        clientID: clientID,
        messageID: messageID,
        chatSessionID: chatSessionID,
        chatSessionIndex: -1,
        epochSecond: (DateTime.parse(timeWritten).millisecondsSinceEpoch / 1000).toInt(),
        text: text != null ? utf8.encode(text) : null,
        fileName: fileName != null ? utf8.encode(fileName) : null,
        contentType: contentType,
        deliveryStatus: deliveryStatus,
      );
    }).toList();

    return messages;
  }
}