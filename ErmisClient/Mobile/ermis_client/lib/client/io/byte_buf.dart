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

/// A buffer class that fasciliates working with byte data.
///
/// Supports reading and writing of various data types, as well as buffer resizing
/// when `growable` is set to `true`.
class ByteBuf {
  Uint8List _buffer;
  final bool growable;

  int _writtenBytes = 0;

  int _readerIndex = 0;
  int _writerIndex = 0;
  
  int _markedReaderIndex = 0;
  int _markedWriterIndex = 0;

  /// Creates a `ByteBuf` with a specified capacity.
  ///
  /// If `growable` is set to `true`, the buffer will expand when needed.
  ByteBuf(int capacity, {this.growable = false}) : _buffer = Uint8List(capacity);

  /// Wraps an existing `Uint8List` buffer into a `ByteBuf`.
  factory ByteBuf.wrap(Uint8List buffer, {growable = false}) {
    return ByteBuf(buffer.length, growable: growable)..writeBytes(buffer);
  }

  /// Creates a small buffer of 256 bytes.
  ByteBuf.smallBuffer({this.growable = false}) : _buffer = Uint8List(256);

  /// Creates an empty buffer.
  ByteBuf.empty({this.growable = false}) : _buffer = Uint8List(0);

  /// Reads a specified number of bytes from the buffer.
  ///
  /// Throws an exception if there are not enough readable bytes.
  Uint8List readBytes(int length) {
    if (readableBytes < length) {
      throw Exception("Not enough readable bytes");
    }
    int newReaderIndex = _readerIndex + length;
    Uint8List bytes = _buffer.sublist(_readerIndex, newReaderIndex);
    _readerIndex = newReaderIndex;
    return bytes;
  }

  /// Writes a `Uint8List` of bytes into the buffer.
  ///
  /// Expands the buffer if `growable` is enabled and there is insufficient space.
  void writeBytes(Uint8List bytes) {
    if (_writerIndex + bytes.length > capacity) {

      if (!growable) {
        throw Exception("Not enough writable space");
      }

      Uint8List tempBuffer = Uint8List(_writerIndex + bytes.length);
      tempBuffer.setRange(0, capacity, _buffer);
      _buffer = tempBuffer;
    }

    // Expand buffer if growable is true
    _buffer.setRange(_writerIndex, _writerIndex + bytes.length, bytes);
    _writerIndex += bytes.length;

    if (_writerIndex > _writtenBytes) _writtenBytes += bytes.length;
  }

  /// Writes another `ByteBuf` into this buffer.
  void writeByteBuf(ByteBuf bytebuf) {
    writeBytes(bytebuf.buffer);
  }

  /// Writes a 32-bit integer in big-endian order.
  void writeInt32(int value) {
    ByteData byteData = ByteData(4)..setInt32(0, value, Endian.big);
    writeBytes(byteData.buffer.asUint8List());
  }

  /// Writes a boolean value (1 byte: 1 for `true`, 0 for `false`).
  void writeBoolean(bool boolean) {
    writeBytes(Uint8List.fromList([boolean ? 1 : 0]));
  }

  /// Reads a 32-bit integer in big-endian order.
  int readInt32() {
    ByteData byteData = ByteData.sublistView(_buffer, _readerIndex, _readerIndex + 4);
    _readerIndex += 4;
    return byteData.getInt32(0, Endian.big);
  }

  /// Reads a 64-bit integer in big-endian order.
  int readInt64() {
    ByteData byteData = ByteData.sublistView(_buffer, _readerIndex, _readerIndex + 8);
    _readerIndex += 8;
    return byteData.getInt64(0, Endian.big);
  }

  /// Reads a 64-bit floating-point number in big-endian order.
  double readFloat64() {
    ByteData byteData = ByteData.sublistView(_buffer, _readerIndex, _readerIndex + 8);
    _readerIndex += 8;
    return byteData.getFloat64(0, Endian.big);
  }

  /// Reads a boolean value (1 byte: 1 for `true`, 0 for `false`).
  bool readBoolean() {
    bool value = buffer[_readerIndex] == 1;
    _readerIndex += 1;
    return value;
  }

  /// Discards the bytes between index `0` and `readerIndex`.
  ///
  /// Moves the bytes between `readerIndex` and `writerIndex` to index `0`,
  /// then updates `readerIndex` and `writerIndex` to `0` and
  /// `oldWriterIndex - oldReaderIndex`, respectively.
  void discardReadBytes() {
    _buffer = Uint8List.sublistView(_buffer, _readerIndex, capacity);

    _writerIndex = _writerIndex - _readerIndex;
    if (_writerIndex < 0) {
      _writerIndex = 0;
    }
    _markedWriterIndex = _markedWriterIndex - _readerIndex;
    if (_markedWriterIndex < 0) {
      _markedWriterIndex = 0;
    }
    _writtenBytes = _writerIndex;

    _readerIndex = 0;
    _markedReaderIndex = 0;
  }

  /// Marks the current reader index.
  void markReaderIndex() {
    _markedReaderIndex = _readerIndex;
  }

  /// Resets the reader index to the last marked position.
  void resetReaderIndex() {
    _readerIndex = _markedReaderIndex;
  }

  /// Marks the current writer index.
  void markWriterIndex() => _markedWriterIndex = _writerIndex;

  /// Resets the writer index to the last marked position.
  void resetWriterIndex() => _writerIndex = _markedWriterIndex;

  /// Returns the number of readable bytes.
  int get readableBytes => _writtenBytes - _readerIndex;
  double get readableInt32s => (_writtenBytes - _readerIndex) / 4;

  /// Returns the total buffer capacity.
  int get capacity => buffer.length;

  /// Returns the underlying buffer.
  Uint8List get buffer => _buffer;

  /// Returns the current reader index.
  int get readerIndex => _readerIndex;

  /// Returns the current writer index.
  int get writerIndex => _writerIndex;
}
