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

enum EntryType {
  createAccount(1),
  login(2);

  final int id;
  const EntryType(this.id);

  static final Map<int, EntryType> _valuesById = {
    for (var entry in EntryType.values) entry.id: entry,
  };

  static EntryType? fromId(int id) => _valuesById[id];
}

/// A tagging interface that all credential enums must extend.
abstract class CredentialInterface {
  int get id;
}