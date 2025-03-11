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

import 'dart:typed_data';

class Lz4Dart {
  Uint8List uncompress(List<int> data, int uncompressedLength) {
    final dest = Uint8List(uncompressedLength);
    for (var op = 0, ip = 0;;) {
      final token = data[ip++];
      var length = token >> 4;
      if (length == 15) {
        do {
          length += data[ip];
        } while (data[ip++] == 255);
      }
      while (--length >= 0) {
        dest[op++] = data[ip++];
      }
      if (ip >= data.length) break;
      final offset = data[ip++] + (data[ip++] << 8);
      assert(offset != 0);
      var matchp = op - offset;
      var matchlength = (token & 15) + 4;
      if (matchlength == 19) {
        do {
          matchlength += data[ip];
        } while (data[ip++] == 255);
      }
      while (--matchlength >= 0) {
        dest[op++] = dest[matchp++];
      }
    }
    return dest;
  }
}