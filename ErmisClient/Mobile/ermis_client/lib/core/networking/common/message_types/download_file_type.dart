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

import '../../../exceptions/EnumNotFoundException.dart';

enum FileType {
  file(0),
  image(1),
  sound(2);

  final int id;
  const FileType(this.id);

  static final Map<int, FileType> _values = {
    for (final type in FileType.values) type.id: type,
  };

  static FileType fromId(int id) {
    FileType? type = _values[id];

    if (type == null) {
      throw EnumNotFoundException('No DownloadFileType found for id $id');
    }

    return type;
  }
}
