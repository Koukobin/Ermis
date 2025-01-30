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

import 'dart:typed_data';
import 'package:synchronized/synchronized.dart';
import 'package:zstandard/zstandard.dart';
import 'byte_buf.dart';

bool _isZstdCompressed(Uint8List data) {
  if (data.length < 4) {
    return false;
  }

  // Signature of ZTSD decompression
  return data[0] == 0x28 &&
      data[1] == 0xB5 &&
      data[2] == 0x2F &&
      data[3] == 0xFD;
}

class ByteBufInputStream {
  static final zstandard = Zstandard();
  Stream<Uint8List> broadcastStream;

  ByteBufInputStream({required this.broadcastStream});

  Future<ByteBuf> read() async {
    Uint8List data = await broadcastStream.first;
    return await decodeSimple(data);
  }

  static ByteBuf buffer = ByteBuf.empty(growable: true);
  static final _lock = Lock();

  static Future<ByteBuf> decodeSimple(Uint8List data) {
    return _lock.synchronized(() async {
      buffer.writeBytes(Uint8List.fromList(data));

      buffer.markReaderIndex();

      int messageLength = buffer.readInt32();

      // Check if we have received enough data for the message
      if (buffer.readableBytes >= messageLength) {
        Uint8List message = buffer.readBytes(messageLength);

        if (_isZstdCompressed(message)) {
          message = (await zstandard.decompress(message))!;
          messageLength = message.length;
        }

        buffer.removeLeftOverData();
        return ByteBuf.wrap(message);
      }

      buffer.resetReaderIndex();

      return ByteBuf.empty();
    });
  }

  Stream<Uint8List> get stream => broadcastStream;
}
