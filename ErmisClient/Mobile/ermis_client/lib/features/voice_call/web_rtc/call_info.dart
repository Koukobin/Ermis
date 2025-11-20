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

import 'package:ermis_mobile/core/models/member.dart';
import 'package:json_annotation/json_annotation.dart';

part 'call_info.g.dart';

@JsonSerializable()
class CallInfo {
  final int chatSessionID;
  final int chatSessionIndex;
  final Member member;
  final bool isInitiator;

  const CallInfo({
    required this.chatSessionID,
    required this.chatSessionIndex,
    required this.member,
    required this.isInitiator,
  });

  factory CallInfo.fromJson(Map<String, dynamic> json) => _$CallInfoFromJson(json);
  Map<String, dynamic> toJson() => _$CallInfoToJson(this);
}
