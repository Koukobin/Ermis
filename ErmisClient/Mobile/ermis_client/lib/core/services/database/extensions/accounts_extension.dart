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
import 'dart:ui';

import 'package:ermis_client/core/services/database/database_service.dart';
import 'package:ermis_client/core/services/database/models/local_account_info.dart';
import 'package:ermis_client/core/services/database/models/local_user_info.dart';
import 'package:ermis_client/core/services/database/models/server_info.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:sqflite/sqflite.dart';
import 'package:zstandard/zstandard.dart';

import '../../../util/image_utils.dart';

extension AccountsExtension on DBConnection {
  Future<void> addUserAccount(LocalAccountInfo userAccount, ServerInfo serverInfo) async {
    final db = await database;

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
    final db = await database;

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
      lastUsed: DateTime.parse(lastUsed),
    );
  }

  /// Retrieves the list of user accounts associated with a specified server.
  /// Each account includes the email, password hash, and the timestamp of last use.
  /// The accounts are sorted by the last used timestamp in descending order.
  Future<List<LocalAccountInfo>> getUserAccounts(ServerInfo serverInfo) async {
    final db = await database;

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
        lastUsed: DateTime.parse(lastUsed),
      );
    }).toList();

    userAccounts.sort((a, b) {
      final DateTime lastUsedA = a.lastUsed;
      final DateTime lastUsedB = b.lastUsed;

      return lastUsedB.compareTo(lastUsedA); // Most recent first
    });

    return userAccounts;
  }

  Future<void> updateLastUsedAccount(ServerInfo serverInfo, String email) async {
    final db = await database;

    await db.update(
      "server_accounts",
      {
        "last_used": DateTime.now().toIso8601String(),
      },
      where: "server_url = ? AND email = ?",
      whereArgs: [serverInfo.toString(), email],
    );
  }

  Future<LocalUserInfo?> getLocalUserInfo(ServerInfo serverInfo, String email) async {
    final db = await database;

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
    final Uint8List compressedProfilePhoto = record['profile_photo'] as Uint8List;
    final int lastUsed = record['last_updated_at'] as int;

    Uint8List decompressedProfile = (await compressedProfilePhoto.decompress())!;

    return LocalUserInfo(
      displayName: displayName,
      clientID: clientID,
      profilePhoto: decompressedProfile,
      lastUpdatedEpochSecond: lastUsed,
    );
  }

  Future<void> insertLocalUserInfo(ServerInfo serverInfo, LocalUserInfo info) async {
    final db = await database;

    String emailAssociatedWithProfile = (await getLastUsedAccount(serverInfo))!.email;

    // For some reason "conflictAlgorithm: ConflictAlgorithm.replace"
    // does not work correctly, so we delete it manually.
    db.delete(
      "server_profiles",
      where: "email = ?",
      whereArgs: [emailAssociatedWithProfile],
    );

    Size size = ImageUtils.resizeImage(
      imageBytes: info.profilePhoto,
      maxWidth: 250,
      maxHeight: 250,
    );

    Uint8List compressedProfile = await FlutterImageCompress.compressWithList(
      info.profilePhoto,
      quality: 70,
      minHeight: size.height.toInt(),
      minWidth: size.width.toInt(),
    );

    db.insert(
      "server_profiles",
      {
        "server_url": serverInfo.toString(),
        "email": emailAssociatedWithProfile,
        'display_name': info.displayName,
        'client_id': info.clientID,
        'profile_photo': await compressedProfile.compress(compressionLevel: 12),
        'last_updated_at': info.lastUpdatedEpochSecond,
      },
      conflictAlgorithm: ConflictAlgorithm.replace, // Why the fuck was there a comment "Why the fuck this does not work?"
    );
    
  }

  Future<void> insertAccountKeyPairs({
    required ServerInfo serverInfo,
    required String email,
    required Uint8List publicKey,
    required Uint8List privateKey,
  }) async {
    final db = await database;

    await db.insert(
      "server_accounts_key_pairs",
      {
        "server_url": serverInfo.toString(),
        "email": email,
        "public_key": String.fromCharCodes(publicKey),
        "private_key": String.fromCharCodes(privateKey),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
