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

import 'package:ermis_mobile/core/services/database/database_service.dart';
import 'package:ermis_mobile/core/services/database/extensions/accounts_extension.dart';
import 'package:ermis_mobile/core/services/database/models/local_user_info.dart';
import 'package:ermis_mobile/core/services/database/models/server_info.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:sqflite/sqflite.dart';
import 'package:zstandard/zstandard.dart';

import '../../../models/member.dart';
import '../../../models/member_icon.dart';
import '../../../networking/common/message_types/client_status.dart';
import '../../../util/image_utils.dart';

extension MembersExtension on DBConnection {
  Future<List<Member>> fetchMemberInfo({
    required ServerInfo server,
  }) async {
    final db = await database;

    final List<Map<String, Object?>> membersMap = await db.query(
      'members',
      where: 'server_url = ?',
      whereArgs: [server.toString()],
    );

    List<Member> members = await Future.wait(membersMap.map((record) async {
      final String displayName = record['display_name'] as String;
      final int clientID = record['client_id'] as int;
      final int lastUpdatedAtEpochSecond = record['last_updated_at'] as int;

      final Uint8List compressedProfilePhoto = record['profile_photo'] as Uint8List;
      final Uint8List decompressedProfile = (await compressedProfilePhoto.decompress())!;

      return Member(
        displayName,
        clientID,
        MemberIcon(decompressedProfile),
        ClientStatus.offline,
        lastUpdatedAtEpochSecond,
      );
    }).toList());

    return members;
  }

  Future<List<Member>> fetchMembersAssociatedWithChatSession({
    required ServerInfo server,
    required String serverAccountEmail,
    required int chatSessionID,
  }) async {
    final db = await database;

    LocalUserInfo localInfo = (await getLocalUserInfo(server, serverAccountEmail))!;

    final List<Map<String, dynamic>> results = await db.rawQuery(
      '''
        SELECT m.*
        FROM members m
        JOIN chat_session_members csm 
            ON m.server_url = csm.server_url 
            AND m.client_id = csm.client_id
            AND NOT m.client_id  = ?
        WHERE csm.chat_session_id = ? AND csm.server_url = ?;
      ''',
      [localInfo.clientID, chatSessionID, server.toString()],
    );

    List<Member> members = await Future.wait(results.map((Map<String, dynamic> record) async {
      final String displayName = record['display_name'] as String;
      final int clientID = record['client_id'] as int;
      final int lastUpdatedAtEpochSecond = record['last_updated_at'] as int;

      final Uint8List compressedProfilePhoto = record['profile_photo'] as Uint8List;
      final Uint8List decompressedProfile = (await compressedProfilePhoto.decompress())!;

      return Member(
        displayName,
        clientID,
        MemberIcon(decompressedProfile),
        ClientStatus.offline,
        lastUpdatedAtEpochSecond,
      );
    }).toList());

    return members;
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
    final db = await database;

    Size size = member.icon.profilePhoto.isEmpty
        ? const Size(0, 0)
        : ImageUtils.resizeImage(
            imageBytes: member.icon.profilePhoto,
            maxWidth: 250,
            maxHeight: 250,
    );

    Uint8List compressedProfile = member.icon.profilePhoto.isEmpty
        ? member.icon.profilePhoto
        : await FlutterImageCompress.compressWithList(
            member.icon.profilePhoto,
            quality: 80,
            minHeight: size.height.toInt(),
            minWidth: size.width.toInt(),
          );

    await db.insert(
      'members',
      {
        'server_url': serverUrl,
        'display_name': member.username,
        'client_id': member.clientID,
        'profile_photo': await compressedProfile.compress(compressionLevel: 12),
        'last_updated_at': member.lastUpdatedAtEpochSecond,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}