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

import '../exceptions/EnumNotFoundException.dart';
import 'ResultHolder.dart';

enum IsPasswordValidResult {
  successfullyValidatedPassword(
    id: 1,
    resultHolder: ResultHolder(true, "Successfully validated password!"),
  ),
  requirementsNotMet(
    id: 2,
    resultHolder: ResultHolder(false, "Password requirements not met!"),
  );

  final int id;
  final ResultHolder resultHolder;

  const IsPasswordValidResult({
    required this.id,
    required this.resultHolder,
  });

  static IsPasswordValidResult fromId(int id) {
    try {
      return IsPasswordValidResult.values.firstWhere((type) => type.id == id);
    } catch (e) {
      throw EnumNotFoundException('No IsPasswordValidResult found for id $id');
    }
  }
}