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

part of 'new_features_page_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewFeaturesPageStatus _$NewFeaturesPageStatusFromJson(
        Map<String, dynamic> json) =>
    NewFeaturesPageStatus(
      hasShown: json['hasShown'] as bool,
      version: json['version'] as String,
    );

Map<String, dynamic> _$NewFeaturesPageStatusToJson(
        NewFeaturesPageStatus instance) =>
    <String, dynamic>{
      'hasShown': instance.hasShown,
      'version': instance.version,
    };
