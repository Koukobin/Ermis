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

enum MessageFields {
  text, fileName, fileBytes;
}

enum MessageContentType {
  text (0,  [MessageFields.text]),
  file (1,  [MessageFields.fileName, MessageFields.fileBytes]),
  image(2,  [MessageFields.fileName, MessageFields.fileBytes]),
  voice(3,  [MessageFields.fileName, MessageFields.fileBytes]),
  video(5,  [MessageFields.fileName, MessageFields.fileBytes]),
  gif  (4,  [MessageFields.text]);

  final int id;
  const MessageContentType(this.id, List<MessageFields> fields);

  // This function mimics the fromId functionality and throws an exception when no match is found.
  static MessageContentType fromId(int id) {
    try {
      return MessageContentType.values.firstWhere((type) => type.id == id);
    } catch (e) {
      throw EnumNotFoundException('No ContentType found for id $id');
    }
  }
}
