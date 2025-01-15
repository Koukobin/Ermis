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

import 'package:ermis_client/client/io/byte_buf.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ByteBuf Tests', () {
    test('Initial state and capacity', () {
      ByteBuf buf = ByteBuf(10);
      expect(buf.capacity, 10);
      expect(buf.readableBytes, 0);
    });

    test('Write and read bytes', () {
      ByteBuf buf = ByteBuf(10);
      buf.writeBytes(Uint8List.fromList([1, 2, 3]));
      expect(buf.readableBytes, 3);
      expect(buf.readBytes(2), [1, 2]);
      expect(buf.readableBytes, 1);
      expect(buf.readBytes(1), [3]);
    });

    test('Write beyond capacity (growable)', () {
      ByteBuf buf = ByteBuf(5, growable: true);
      buf.writeBytes(Uint8List.fromList([1, 2, 3, 4, 5, 6, 7]));
      expect(buf.capacity, greaterThanOrEqualTo(7));
      expect(buf.readableBytes, 7);
    });

    test('Write beyond capacity (non-growable)', () {
      ByteBuf buf = ByteBuf(5);
      expect(() => buf.writeBytes(Uint8List.fromList([1, 2, 3, 4, 5, 6])),
          throwsException);
    });

    test('Write and read int', () {
      ByteBuf buf = ByteBuf(10);
      buf.writeInt(0x12345678);
      expect(buf.readInt32(), 0x12345678);
    });

    test('Write and read boolean', () {
      ByteBuf buf = ByteBuf(2);
      buf.writeBoolean(true);
      buf.writeBoolean(false);
      expect(buf.readBoolean(), true);
      expect(buf.readBoolean(), false);
    });

    test('Write and read double', () {
      ByteBuf buf = ByteBuf(16);
      buf.writeBytes(((ByteData(8)..setFloat64(0, 3.14)).buffer.asUint8List()));
      expect(buf.readFloat64(), closeTo(3.14, 0.0001));
    });

    test('Mark and reset reader index', () {
      ByteBuf buf = ByteBuf(10);
      buf.writeBytes(Uint8List.fromList([1, 2, 3, 4]));
      buf.readBytes(2); // Read [1, 2]
      buf.markReaderIndex();
      buf.readBytes(1); // Read [3]
      buf.resetReaderIndex();
      expect(buf.readBytes(2), [3, 4]);
    });

    test('Mark and reset writer index', () {
      ByteBuf buf = ByteBuf(10);
      buf.writeBytes(Uint8List.fromList([1, 2]));
      buf.markWriterIndex();
      buf.writeBytes(Uint8List.fromList([3]));
      buf.resetWriterIndex();
      buf.writeBytes(Uint8List.fromList([1]));
      expect(buf.readBytes(buf.readableBytes), [1, 2, 1]);
    });

    test('Remove leftover data', () {
      ByteBuf buf = ByteBuf(10);
      buf.writeBytes(Uint8List.fromList([1, 2, 3, 4, 5]));
      buf.readBytes(3); // Read [1, 2, 3]
      buf.removeLeftOverData();
      expect(buf.readableBytes, 2); // Only [4, 5] remain
      expect(buf.readBytes(buf.readableBytes), [4, 5]);
    });

    test('ByteBuf.wrap works', () {
      Uint8List list = Uint8List.fromList([10, 20, 30]);
      ByteBuf buf = ByteBuf.wrap(list);
      expect(buf.capacity, list.length);
      expect(buf.readBytes(3), [10, 20, 30]);
    });
  });
}