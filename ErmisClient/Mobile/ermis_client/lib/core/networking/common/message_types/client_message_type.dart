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

import '../../../exceptions/enum_not_found_exception.dart';

enum ClientMessageType {
  clientContent(0),
  entry(1),
  command(2);

  final int id;
  const ClientMessageType(this.id);

  // This function mimics the fromId functionality and throws an exception when no match is found.
  static ClientMessageType fromId(int id) {
    try {
      return ClientMessageType.values.firstWhere((type) => type.id == id);
    } catch (e) {
      throw EnumNotFoundException('No ClientMessageType found for id $id');
    }
  }
}
