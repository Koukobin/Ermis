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

import 'dart:io';
import 'dart:typed_data';

import 'package:zstandard/zstandard.dart';

import 'byte_buf.dart';

class ByteBufOutputStream {
  static final zstandard = Zstandard();
  static const int _compressionLevel = 4; // 1 (fastest) to 22 (highest compression)
  final Socket _socket;

  ByteBufOutputStream({required Socket socket}) : _socket = socket;

  void write(ByteBuf msg) async {
    int msgLength = msg.readableBytes;
    Uint8List msgBytes = msg.readBytes(msgLength);

    if (msgLength > 100) {
      msgBytes = (await zstandard.compress(msgBytes, _compressionLevel))!;
      msgLength = msgBytes.length;
    }

    // Convert the message length to bytes (big-endian representation)
    Uint8List lengthOfMsgBytes = Uint8List(4); // An integer is 4 bytes
    ByteData.view(lengthOfMsgBytes.buffer).setInt32(0, msgLength, Endian.big);

    // Combine the length bytes and the message bytes;
    // the length of the payload is explicitly declared at the beginning
    Uint8List payload = Uint8List(4 + msgLength);
    payload.setRange(0, 4, lengthOfMsgBytes); // Copy length bytes
    payload.setRange(4, 4 + msgLength, msgBytes); // Copy message bytes

    _socket.add(payload);
  }
}
