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

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:encrypt/encrypt.dart';
import 'package:ermis_client/core/data/models/network/byte_buf.dart';
// import 'dart:ffi' as ffi;
// import 'package:path/path.dart' as path;

enum VoiceCallServerMessage {
  voice(4),
  userAdded(0),
  callEnded(1);

  final int id;

  const VoiceCallServerMessage(this.id);

  static VoiceCallServerMessage fromId(int id) {
    return VoiceCallServerMessage.values.firstWhere((type) => type.id == id);
  }
}

enum VoiceCallClientMessage {
  voice(4),
  endCall(1);

  final int id;

  const VoiceCallClientMessage(this.id);
}

class VoiceCallUDPSocket {
  late RawDatagramSocket _udpSocket;

  late InternetAddress _remoteAddress;
  late int _remotePort;

  late int _chatSessionID;
  late int _key;
  late encrypt.Key _aesKey;
  late Encrypter _encrypter;

  VoiceCallUDPSocket();

  set chatSessionID(int chatSessionID) => _chatSessionID = chatSessionID;
  set key(int key) => _key = key;
  set aesKey(Uint8List aesKey) => _aesKey = encrypt.Key(aesKey);

  Future<void> initialize(Uint8List aesKey) async {
    _udpSocket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      9090,
    );

    _encrypter = Encrypter(
      AES(
        encrypt.Key(aesKey),
        mode: AESMode.gcm,
        padding: null,
      ),
    );

  }

  void listen(
    void Function(Uint8List data)? onData, {
    void Function()? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    _udpSocket.listen(
      (event) {
        Datagram? datagram = _udpSocket.receive();
        if (datagram == null) {
          return;
        }

        onData?.call(aesGcmDecrypt(datagram.data));
      },
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  void rawSecureSend(List<int> message, InternetAddress address, int port) {
    Random random = Random();
    final Encrypted encrypted = _encrypter.encryptBytes(
      message,
      iv: IV(Uint8List.fromList(List.generate(12, (int index) {
        return random.nextInt(10);
      }))),
    ); // IV probably not need in this context
    _udpSocket.send(encrypted.bytes, address, port);
    print(encrypted.bytes);
  }

  void send(Uint8List message) {
    // If message greater than 4096 send message in chunks
    if (message.length <= 32768) {
      _sendSingleMessage(message);
    } else {
      // ΕΔΩ ΕΓΚΕΙΤΑΙ ΤΟ ΠΡΟΒΛΗΜΑ
      for (int i = 0; i < message.length; i += 1024) {
        int end = (i + 1024 < message.length) ? i + 1024 : message.length;
        _sendSingleMessage(
            Uint8List.fromList(message.getRange(i, end).toList()));
      }
    }
  }

  void _sendSingleMessage(Uint8List message) {
    final payload = ByteBuf.smallBuffer(growable: true);
    payload.writeInt32(_chatSessionID);
    payload.writeInt32(VoiceCallClientMessage.voice.id);
    payload.writeInt32(_key);
    payload.writeBytes(message);
    _udpSocket.send(aesGcmEncrypt(payload.buffer), _remoteAddress, _remotePort);
  }

  void close() {
    ByteBuf buffer = ByteBuf.smallBuffer();
    buffer.writeInt32(_chatSessionID);
    buffer.writeInt32(VoiceCallClientMessage.endCall.id);
    send(buffer.buffer);
    _udpSocket.close();
  }

  Uint8List aesGcmEncrypt(Uint8List plainText) {
    final iv = encrypt.IV.fromSecureRandom(12);
    final encrypter = encrypt.Encrypter(
      encrypt.AES(
        _aesKey,
        mode: encrypt.AESMode.gcm,
        padding: null,
      ),
    );

    final encrypted = encrypter.encryptBytes(
      plainText,
      iv: iv,
    );

    return encrypted.bytes;
  }

  Uint8List aesGcmDecrypt(Uint8List ciphertext) {
    final encrypter = encrypt.Encrypter(
      encrypt.AES(
        _aesKey,
        mode: encrypt.AESMode.gcm,
        padding: null,
      ),
    );

    final List<int> decrypted = encrypter.decryptBytes(
      encrypt.Encrypted(ciphertext),
      iv: encrypt.IV.allZerosOfLength(12),
    );

    return Uint8List.fromList(decrypted);
  }
}
