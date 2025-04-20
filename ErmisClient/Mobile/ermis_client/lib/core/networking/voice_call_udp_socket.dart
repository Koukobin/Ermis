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

  late InternetAddress remoteAddress;
  late int remotePort;

  late int _chatSessionID;
  late Key _aesKey;
  late Encrypter _encrypter;

  set chatSessionID(int chatSessionID) => _chatSessionID = chatSessionID;
  set aesKey(Uint8List aesKey) => _aesKey = Key(aesKey);

  Future<void> openSocket() async {
    Random rng = Random();
    _udpSocket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      rng.nextInt(1000) + 9000,
    );
  }

  Future<void> initialize(Uint8List aesKey) async {
    _aesKey = Key(aesKey);

    _encrypter = Encrypter(
      AES(
        _aesKey,
        mode: AESMode.gcm,
      ),
    );

  }

  Stream<Uint8List?> get stream => _udpSocket.map((RawSocketEvent event) {
        Datagram? datagram = _udpSocket.receive();
        if (datagram == null) {
          return null;
        }

        return aesGcmDecrypt(datagram.data);
      });

  StreamSubscription<RawSocketEvent> listen(
    void Function(Uint8List data) onData, {
    void Function()? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _udpSocket.listen(
      (event) {
        Datagram? datagram = _udpSocket.receive();
        if (datagram == null) {
          return;
        }

        onData(aesGcmDecrypt(datagram.data));
      },
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  // void rawSend(Uint8List buffer, InternetAddress address, int port) {
  //   if (buffer.length <= 32768) {
  //     _udpSocket.send(buffer, address, port);
  //   } else {
  //     // ΕΔΩ ΕΓΚΕΙΤΑΙ ΤΟ ΠΡΟΒΛΗΜΑ
  //     for (int i = 0; i < buffer.length; i += 1024) {
  //       int end = (i + 1024).clamp(0, buffer.length);
  //       _udpSocket.send(buffer.sublist(i, end), address, port);
  //     }
  //   }
  // }

  void rawSecureSendByteBuf(ByteBuf message, InternetAddress address, int port) {
    final encrypted = aesGcmEncrypt(message.buffer);

    if (encrypted.length <= 32768) {
      _udpSocket.send(encrypted, address, port);
    } else {
      // ΕΔΩ ΕΓΚΕΙΤΑΙ ΤΟ ΠΡΟΒΛΗΜΑ
      for (int i = 0; i < encrypted.length; i += 1024) {
        int end = (i + 1024).clamp(0, encrypted.length);
        _udpSocket.send(encrypted.sublist(i, end), address, port);
      }
    }
  }

  void rawSecureSend(Uint8List message, InternetAddress address, int port) {
    final encrypted = aesGcmEncrypt(message);

    if (encrypted.length <= 32768) {
      _udpSocket.send(encrypted, address, port);
    } else {
      // ΕΔΩ ΕΓΚΕΙΤΑΙ ΤΟ ΠΡΟΒΛΗΜΑ
      for (int i = 0; i < encrypted.length; i += 1024) {
        int end = (i + 1024).clamp(0, encrypted.length);
        _udpSocket.send(encrypted.sublist(i, end), address, port);
      }
    }
  }

  // void send(Uint8List message) {
  //   // If message greater than 4096 send message in chunks
  //   if (message.length <= 32768) {
  //     _sendSingleMessage(message);
  //   } else {
  //     // ΕΔΩ ΕΓΚΕΙΤΑΙ ΤΟ ΠΡΟΒΛΗΜΑ
  //     for (int i = 0; i < message.length; i += 1024) {
  //       int end = (i + 1024).clamp(0, message.length);
  //       _sendSingleMessage(message.sublist(i, end));
  //     }
  //   }
  // }

  // void _sendSingleMessage(Uint8List message) {
  //   _udpSocket.send(aesGcmEncrypt(message), remoteAddress, remotePort);
  // }

  void close() {
    // ByteBuf buffer = ByteBuf.smallBuffer();
    // buffer.writeInt32(_chatSessionID);
    // buffer.writeInt32(VoiceCallClientMessage.endCall.id);
    // send(buffer.buffer);
    _udpSocket.close();
  }

  Uint8List aesGcmEncrypt(Uint8List plainText) {
    final random = Random();

    final iv = IV(Uint8List.fromList(List.generate(12, (int index) {
      return random.nextInt(192);
    })));

    final Encrypted encrypted = _encrypter.encryptBytes(
      plainText,
      iv: iv,
    );

    return Uint8List.fromList(iv.bytes + encrypted.bytes);
  }

  Uint8List aesGcmDecrypt(Uint8List ciphertext) {
    ByteBuf buffer = ByteBuf.wrap(ciphertext);
    Uint8List iv = buffer.readBytes(12);
    Uint8List rest = buffer.readAllBytes();

    final List<int> decrypted = _encrypter.decryptBytes(
      Encrypted(rest),
      iv: IV(iv),
    );

    return Uint8List.fromList(decrypted);
  }
}
