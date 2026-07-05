/* Copyright (C) 2026 Ilias Koukovinis <ilias.koukovinis@gmail.com>
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

import 'dart:async';
import 'package:ermis_mobile/core/models/member.dart';
import 'package:ermis_mobile/core/networking/user_info_manager.dart';
import 'package:ermis_mobile/core/services/database/database_service.dart';
import 'package:ermis_mobile/core/services/database/extensions/members_extension.dart';
import 'package:flutter/foundation.dart';

import '../models/member_icon.dart';
import 'custom_http_service.dart';

class IconLoaderUtil {
  static Future<Uint8List> loadIcon(Member member) async {
    if (member.icon.isLoaded()) {
      return member.icon.profilePhoto;
    }

    Uint8List imageBytes = await loadIcon$0(member.icon);

    DBConnection conn = ErmisDB.getConnection();
    conn.insertMember(
      serverUrl: UserInfoManager.serverInfo.serverUrl.toString(),
      member: member,
    );

    return imageBytes;
  }

  static Future<Uint8List> loadIcon$0(MemberIcon icon) async {
    if (icon.isLoaded()) {
      return icon.profilePhoto;
    }

    String iconUrl = icon.getUrl();
    icon.profilePhoto =
        await CustomHttpClient().fetchUint8ListFromUrl(iconUrl) ?? Uint8List(0);

    return icon.profilePhoto;
  }
}
