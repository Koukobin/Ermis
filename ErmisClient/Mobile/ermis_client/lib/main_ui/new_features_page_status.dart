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

import 'package:json_annotation/json_annotation.dart';

part 'new_features_page_status.g.dart';

@JsonSerializable()
class NewFeaturesPageStatus {
  bool hasShown;
  String version;

  NewFeaturesPageStatus({required this.hasShown, required this.version});

  // Factory method to create a User from JSON
  factory NewFeaturesPageStatus.fromJson(Map<String, dynamic> json) => _$NewFeaturesPageStatusFromJson(json);

  // Method to convert a User to JSON
  Map<String, dynamic> toJson() => _$NewFeaturesPageStatusToJson(this);
}
