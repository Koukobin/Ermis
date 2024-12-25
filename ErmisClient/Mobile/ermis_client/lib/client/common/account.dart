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

import 'dart:typed_data';
import 'dart:convert';

class Account {
  final Uint8List profilePhoto;
  final String displayName;
  final String email;
  final int clientID;

  Account({
    required this.profilePhoto,
    required this.displayName,
    required this.email,
    required this.clientID,
  });

  @override
  int get hashCode {
    const prime = 31;
    var result = 1;
    result = prime * result + profilePhoto.hashCode;
    result = prime * result + displayName.hashCode;
    result = prime * result + email.hashCode;
    result = prime * result + clientID.hashCode;
    return result;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Account) {
      return false;
    }
    return clientID == other.clientID &&
        profilePhoto == other.profilePhoto &&
        email == other.email &&
        displayName == other.displayName;
  }

  String name() {
    return "$displayName@$clientID";
  }

  @override
  String toString() {
    return 'Account [icon=${base64Encode(profilePhoto)}, username=$displayName, email=$email, clientID=$clientID]';
  }
}
