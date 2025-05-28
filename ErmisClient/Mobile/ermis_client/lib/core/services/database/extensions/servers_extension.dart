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

extension ServersExtension on DBConnection {
  Future<void> updateServerUrlLastUsed(ServerInfo serverInfo) async {
    final db = await database;

    await db.update(
      'servers',
      {
        'last_used': serverInfo.lastUsed.toIso8601String()
      }, // Set current timestamp
      where: 'server_url = ?',
      whereArgs: [
        serverInfo.toString(), // Identifier
      ],
    );
  }

  Future<void> insertServerInfo(ServerInfo info) async {
    final db = await database;

    info.lastUsed = DateTime.now();
    await db.insert(
      'servers',
      info.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    await db.insert(
      "servers_network_usage",
      {
        "server_url": info.toString(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> removeServerInfo(ServerInfo info) async {
    final db = await database;

    await db.delete('servers',
        where: 'server_url = ?', whereArgs: [info.serverUrl.toString()]);
  }

  Future<ServerInfo> getServerUrlLastUsed() async {
    return (await getServerUrls())[0];
  }

  /// Fetches all server urls created by user sorted by most recently used
  Future<List<ServerInfo>> getServerUrls() async {
    final db = await database;

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

  /// Retrieves a rough approximation of storage utilized by
  /// data stored locally associated with the given server
  Future<int> getByteSize(ServerInfo info) async {
    final db = await database;

    // Approximation
    final int serverDataBytes = Sqflite.firstIntValue(
      await db.rawQuery('SELECT SUM(length(server_url) + length(last_used)) FROM servers'),
    ) ?? 0;

    // Approximation
    final int memberDataBytes = Sqflite.firstIntValue(
      await db.rawQuery('SELECT SUM(length(profile_photo) + length(display_name) + length(client_id) + length(last_updated_at)) FROM members;'),
    ) ?? 0;

    // Approximation
    final int chatMessagesBytes = Sqflite.firstIntValue(
      await db.rawQuery('SELECT SUM(length(text) + length(file_name) + length(content_type) + length(message_id) + length(delivery_status) + length(ts_entered)) FROM chat_messages;'),
    ) ?? 0;

    // Rough estimate
    return serverDataBytes + memberDataBytes + chatMessagesBytes;
  }

  Future<void> insertDataBytesReceived(ServerInfo info, int bytesSize) async {
    final db = await database;

    await db.insert(
      "servers_network_usage",
      {
        "server_url": info.toString(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    await db.rawUpdate("""UPDATE servers_network_usage
        SET total_bytes_received = total_bytes_received + $bytesSize
        WHERE server_url = "$info";""",
    );
  }

  Future<void> insertDataBytesSent(ServerInfo info, int bytesSize) async {
    final db = await database;

    await db.insert(
      "servers_network_usage",
      {
        "server_url": info.toString(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    await db.rawUpdate("""UPDATE servers_network_usage
        SET total_bytes_sent = total_bytes_sent + $bytesSize
        WHERE server_url = "$info";""",
    );
  }

  Future<int> getDataBytesReceived(ServerInfo info) async {
    final db = await database;

    int s = Sqflite.firstIntValue(
          await db.rawQuery('SELECT total_bytes_received FROM servers_network_usage WHERE server_url = "$info";'),
        ) ?? 0;

    return s;
  }

  Future<int> getDataBytesSent(ServerInfo info) async {
    final db = await database;

    int s = Sqflite.firstIntValue(
          await db.rawQuery('SELECT total_bytes_sent FROM servers_network_usage WHERE server_url = "$info";'),
        ) ?? 0;

    return s;
  }
}
