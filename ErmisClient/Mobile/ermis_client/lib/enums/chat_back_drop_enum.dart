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

import 'package:ermis_mobile/constants/app_constants.dart';
import 'package:ermis_mobile/core/exceptions/enum_not_found_exception.dart';
import 'package:ermis_mobile/generated/l10n.dart';

enum ChatBackDrop {
  monotone(id: 0),
  abstract(id: 1),
  ermis(id: 2),
  gradient(id: 3),
  custom(id: 4);

  /// This is used to identify each chat backdrop by its id
  final int id;

  const ChatBackDrop({required this.id});

  static ChatBackDrop fromId(int id) {
    try {
      return ChatBackDrop.values.firstWhere((type) => type.id == id);
    } catch (e) {
      throw EnumNotFoundException('No $ChatBackDrop found for id $id');
    }
  }

  String get name => switch (this) {
        monotone => S.current.default_monotone,
        abstract => S.current.abstract,
        ermis => AppConstants.applicationTitle,
        gradient => S.current.gradient,
        custom => S.current.custom,
      };
}
