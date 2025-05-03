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

import 'package:ermis_client/core/models/member_icon.dart';
import 'package:ermis_client/core/networking/common/message_types/client_status.dart';

class Member {
  String username;
  int clientID;
  MemberIcon icon;
  ClientStatus status;
  final int lastUpdatedAtEpochSecond;

  Member(this.username, this.clientID, this.icon, this.status, this.lastUpdatedAtEpochSecond);

  @override
  int get hashCode => clientID.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Member) return false;

    return clientID == other.clientID &&
        icon == other.icon &&
        username == other.username &&
        status == other.status;
  }

  @override
  String toString() => '$username@$clientID';
}
