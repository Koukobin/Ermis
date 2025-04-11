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

class MemberIcon {
  final Uint8List profilePhoto;
  final int lastUpdatedAtEpochSecond;
  const MemberIcon(this.profilePhoto, this.lastUpdatedAtEpochSecond);

  /// This hashCode is not ideal nor is it optimal but it is 
  /// good enough and sufficient for virtually all cases
  @override
  int get hashCode => profilePhoto.length * lastUpdatedAtEpochSecond.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MemberIcon) return false;
    
    return profilePhoto == other.profilePhoto &&
        lastUpdatedAtEpochSecond == other.lastUpdatedAtEpochSecond;
  }
}