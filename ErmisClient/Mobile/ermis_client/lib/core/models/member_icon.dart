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
import 'package:ermis_mobile/core/networking/user_info_manager.dart';
import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

part 'member_icon.g.dart';

class Uint8ListConverter implements JsonConverter<Uint8List, String> {
  const Uint8ListConverter();

  @override
  Uint8List fromJson(String json) {
    return base64Decode(json);
  }

  @override
  String toJson(Uint8List object) {
    return base64Encode(object);
  }
}

@JsonSerializable()
class MemberIcon {
  final String profilePhotoID;
  @Uint8ListConverter()
  Uint8List profilePhoto;

  MemberIcon({
    required this.profilePhotoID,
    required this.profilePhoto,
  });

  MemberIcon.empty({
    required this.profilePhotoID,
  }) : profilePhoto = Uint8List(0);

  MemberIcon.emptY() : profilePhotoID = "", profilePhoto = Uint8List(0);

  String getUrl() {
    print(profilePhotoID);
    print(profilePhotoID);
    print(profilePhotoID);
    print(profilePhotoID);
    print(profilePhotoID);
    return "${UserInfoManager.serverInfo.serverUrl}/user-profiles/$profilePhotoID";
  }

  bool isLoaded() {
    return profilePhoto.isNotEmpty;
  }

  /// This hashCode is not ideal nor is it optimal but it is
  /// good enough and sufficient for virtually all cases
  @override
  int get hashCode => profilePhotoID.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MemberIcon) return false;

    return profilePhotoID == other.profilePhotoID &&
        profilePhoto == other.profilePhoto;
  }

  factory MemberIcon.fromJson(Map<String, dynamic> json) => _$MemberIconFromJson(json);
  Map<String, dynamic> toJson() => _$MemberIconToJson(this);
}