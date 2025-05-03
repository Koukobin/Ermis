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

import 'package:flutter/foundation.dart';

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

  Map<String, Object?> toMap1() {
    return {
      'display_name': displayName,
      'client_id': clientID,
      'profile_photo': profilePhoto,
      'last_updated_at': lastUpdatedEpochSecond,
    };
  }
}
