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
  }

  Future<void> removeServerInfo(ServerInfo info) async {
    final db = await database;

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
}