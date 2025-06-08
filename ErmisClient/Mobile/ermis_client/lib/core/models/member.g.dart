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

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Member _$MemberFromJson(Map<String, dynamic> json) => Member(
      json['username'] as String,
      (json['clientID'] as num).toInt(),
      MemberIcon.fromJson(json['icon'] as Map<String, dynamic>),
      $enumDecode(_$ClientStatusEnumMap, json['status']),
      (json['lastUpdatedAtEpochSecond'] as num).toInt(),
    );

Map<String, dynamic> _$MemberToJson(Member instance) => <String, dynamic>{
      'username': instance.username,
      'clientID': instance.clientID,
      'icon': instance.icon,
      'status': _$ClientStatusEnumMap[instance.status]!,
      'lastUpdatedAtEpochSecond': instance.lastUpdatedAtEpochSecond,
    };

const _$ClientStatusEnumMap = {
  ClientStatus.online: 'online',
  ClientStatus.offline: 'offline',
  ClientStatus.doNotDisturb: 'doNotDisturb',
  ClientStatus.invisible: 'invisible',
};
