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

enum ChangeUsernameResult {
  successfullyChangedUsername(
    id: 0,
    resultHolder: ResultHolder(true, "Successfully changed username!"),
  ),
  errorWhileChangingUsername(
    id: 1,
    resultHolder: ResultHolder(false, "There was an error while trying to change username!"),
  );

  final int id;
  final ResultHolder resultHolder;

  const ChangeUsernameResult({
    required this.id,
    required this.resultHolder,
  });

  static ChangeUsernameResult fromId(int id) {
    try {
      return ChangeUsernameResult.values.firstWhere((type) => type.id == id);
    } catch (e) {
      throw EnumNotFoundException('No ChangeUsernameResult found for id $id');
    }
  }
}