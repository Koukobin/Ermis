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

class ByteBuf {
  Uint8List _buffer;
  final bool growable;

  int _writtenBytes = 0;

  int _readerIndex = 0;
  int _writerIndex = 0;
  
  int _markedReaderIndex = 0;
  int _markedWriterIndex = 0;

  ByteBuf(int capacity, {this.growable = false}) : _buffer = Uint8List(capacity);

  factory ByteBuf.wrap(Uint8List buffer, {growable = false}) {
    return ByteBuf(buffer.length, growable: growable)..writeBytes(buffer);
  }

  ByteBuf.smallBuffer({this.growable = false}) : _buffer = Uint8List(256);

  ByteBuf.empty({this.growable = false}) : _buffer = Uint8List(0);

  Uint8List readBytes(int length) {
    if (readableBytes < length) {
      throw Exception("Not enough readable bytes");
    }
    int newReaderIndex = _readerIndex + length;
    Uint8List bytes = _buffer.sublist(_readerIndex, newReaderIndex);
    _readerIndex = newReaderIndex;
    return bytes;
  }

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

  void writeByteBuf(ByteBuf bytebuf) {
    writeBytes(bytebuf.buffer);
  }

  void writeInt(int value) {
    ByteData byteData = ByteData(4)..setInt32(0, value, Endian.big);
    writeBytes(byteData.buffer.asUint8List());
  }

  void writeBoolean(bool boolean) {
    writeBytes(Uint8List.fromList([boolean ? 1 : 0]));
  }

  int readInt32() {
    ByteData byteData = ByteData.sublistView(_buffer, _readerIndex, _readerIndex + 4);
    _readerIndex += 4;
    return byteData.getInt32(0, Endian.big);
  }

  int readInt64() {
    ByteData byteData = ByteData.sublistView(_buffer, _readerIndex, _readerIndex + 8);
    _readerIndex += 8;
    return byteData.getInt64(0, Endian.big);
  }

  double readFloat64() {
    ByteData byteData = ByteData.sublistView(_buffer, _readerIndex, _readerIndex + 8);
    _readerIndex += 8;
    return byteData.getFloat64(0, Endian.big);
  }

  bool readBoolean() {
    bool value = buffer[_readerIndex] == 1;
    _readerIndex += 1;
    return value;
  }

  void removeLeftOverData() {
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

  void markReaderIndex() {
    _markedReaderIndex = _readerIndex;
  }

  void resetReaderIndex() {
    _readerIndex = _markedReaderIndex;
  }

  void markWriterIndex() => _markedWriterIndex = _writerIndex;
  void resetWriterIndex() => _writerIndex = _markedWriterIndex;

  int get readableBytes {
    return _writtenBytes - _readerIndex;
  }

  int get capacity => buffer.length;
  Uint8List get buffer => _buffer;

  int get readerIndex => _readerIndex;
  int get writerIndex => _writerIndex;
}
