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
import 'dart:typed_data';
import 'package:ermis_client/client/io/byte_buf.dart';
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
  late Uint8List _aesKey;

  VoiceCallUDPSocket();

  set chatSessionID(int chatSessionID) => _chatSessionID = chatSessionID;
  set key(int key) => _key = key;
  set aesKey(Uint8List aesKey) => _aesKey = aesKey;

  Future<void> initialize(InternetAddress remoteAddress, int remotePort,
      int chatSessionIndex) async {
    if (remotePort <= 0) {
      throw ArgumentError("Port cannot be below zero");
    }

    _udpSocket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      9090,
    );

    _remoteAddress = remoteAddress;
    _remotePort = remotePort;
  }

  void listen(void Function(Datagram datagram)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    _udpSocket.listen(
      (event) {
        Datagram? datagram = _udpSocket.receive();
        if (datagram == null) {
          return;
        }

        onData?.call(datagram);
      },
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
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
    _udpSocket.send(payload.buffer, _remoteAddress, _remotePort);
  }

  void close() {
    ByteBuf buffer = ByteBuf.smallBuffer();
    buffer.writeInt32(_chatSessionID);
    buffer.writeInt32(VoiceCallClientMessage.endCall.id);
    send(buffer.buffer);
    _udpSocket.close();
  }
}

// Secure UDP socket
// class SecureDatagramSocket {
//   late ffi.DynamicLibrary dtlsLib;

//   SecureDatagramSocket() {
//     dtlsLib = ffi.DynamicLibrary.open("path/to/libdtls.so");

//     var libraryPath =
//         path.join(Directory.current.path, 'hello_library', 'libhello.so');
//     if (Platform.isMacOS) {
//       libraryPath =
//           path.join(Directory.current.path, 'hello_library', 'libhello.dylib');
//     } else if (Platform.isWindows) {
//       libraryPath = path.join(
//           Directory.current.path, 'hello_library', 'Debug', 'hello.dll');
//     }
//   }

  // @ffi.Native<ffi.Void Function(Uint8List)>(symbol: 'send')
  // external void send(
  //   Uint8List data,
  // );

  // // FFI binding to send method from Rust
  // void send(Uint8List data) {
  //   final sendFunc = dtlsLib.lookupFunction<
  //       void Function(ffi.Pointer<Utf8>, Uint8List),
  //       void Function(ffi.Pointer<Utf8>, Uint8List)>('send');

  // Convert data to a pointer (ensure correct memory allocation)
  //   final myString = 'Hello';
  //   final pointer = myString.toNativeUtf8();
  //   sendFunc(pointer, data);
  // }
// }
// 
// class SecureUdpSocket {
//   final RawDatagramSocket _socket;
//   final Uint8List _key;

//   SecureUdpSocket(this._socket, this._key);

//   Future<void> sendSecure(String message, InternetAddress address, int port) async {
//     Uint8List encrypted = aesGcmEncrypt(Uint8List.fromList(message.codeUnits));
//     _socket.send(encrypted, address, port);
//   }

//   Stream<Uint8List> receiveSecure1() async* {
//     await for (final RawSocketEvent event in _socket) {
//       switch (event) {
//         case RawSocketEvent.read:
//           Datagram? datagram = _socket.receive();
//           if (datagram == null) break;
          
//           Uint8List decrypted = aesGcmDecrypt(datagram.data);
//           yield decrypted;
//           break;
//         case RawSocketEvent.closed:
//           // TODO: Handle this case.
//           break;
//         case RawSocketEvent.readClosed:
//           // TODO: Handle this case.
//           break;
//         case RawSocketEvent.write:
//           // TODO: Handle this case.
//           break;
//       }

//     }
//   }


//   static Future<SecureUdpSocket> bind(String host, int port, Uint8List key, Uint8List iv) async {
//     RawDatagramSocket socket = await RawDatagramSocket.bind(host, port);
//     return SecureUdpSocket(socket, key, iv);
//   }
// }
// void main() {
//   // Example plaintext
//   final plaintext = 'Hello, AES-GCM in Dart!';
  
//   // Key and IV
//   final key = encrypt.Key.fromSecureRandom(32); // 256-bit key
//   final iv = encrypt.IV.fromSecureRandom(12);   // 96-bit IV (standard for AES-GCM)

//   // Encrypt
//   final encrypted = aesGcmEncrypt(plaintext, key, iv);

//   print('Encrypted: ${base64.encode(encrypted.ciphertext)}');
//   print('IV: ${base64.encode(iv.bytes)}');

//   // Decrypt
//   final decrypted = aesGcmDecrypt(
//     encrypted.ciphertext,
//     key,
//     iv
//   );

//   print('Decrypted: $decrypted');
// }

// class EncryptedData {
//   final Uint8List ciphertext;

//   EncryptedData(this.ciphertext);
// }


// EncryptedData aesGcmEncrypt(String plaintext, encrypt.Key key, encrypt.IV iv) {
//   final encrypter = encrypt.Encrypter(
//     encrypt.AES(
//       key,
//       mode: encrypt.AESMode.gcm,
//       padding: null,
//     ),
//   );

//   final encrypted = encrypter.encryptBytes(
//     utf8.encode(plaintext),
//     iv: iv,
//   );

//   return EncryptedData(encrypted.bytes);
// }

// String aesGcmDecrypt(
//   Uint8List ciphertext,
//   encrypt.Key key,
//   encrypt.IV iv,
// ) {
//   final encrypter = encrypt.Encrypter(
//     encrypt.AES(
//       key,
//       mode: encrypt.AESMode.gcm,
//       padding: null,
//     ),
//   );


//   final decrypted = encrypter.decryptBytes(
//     encrypt.Encrypted.from64(base64.encode(ciphertext)),
//     iv: iv,
//   );

//   return utf8.decode(decrypted);
// }