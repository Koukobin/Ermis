// /* Copyright (C) 2025 Ilias Koukovinis <ilias.koukovinis@gmail.com>
//  *
//  * This program is free software: you can redistribute it and/or modify
//  * it under the terms of the GNU Affero General Public License as
//  * published by the Free Software Foundation, either version 3 of the
//  * License, or (at your option) any later version.
//  * 
//  * This program is distributed in the hope that it will be useful,
//  * but WITHOUT ANY WARRANTY; without even the implied warranty of
//  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  * GNU Affero General Public License for more details.
//  * 
//  * You should have received a copy of the GNU Affero General Public License
//  * along with this program. If not, see <https://www.gnu.org/licenses/>.
//  */

// import 'dart:async';
// import 'dart:io';
// import 'dart:math';
// import 'dart:typed_data';
// import 'package:encrypt/encrypt.dart';
// import 'package:ermis_mobile/core/data/models/network/byte_buf.dart';
// import 'package:ermis_mobile/core/models/inet_socket_address.dart';

// enum VoiceCallServerMessage {
//   voice(4),
//   userAdded(0),
//   callEnded(1);

//   final int id;

//   const VoiceCallServerMessage(this.id);

//   static VoiceCallServerMessage fromId(int id) {
//     return VoiceCallServerMessage.values.firstWhere((type) => type.id == id);
//   }
// }

// enum VoiceCallClientMessage {
//   voice(4),
//   endCall(1);

//   final int id;

//   const VoiceCallClientMessage(this.id);

//   static VoiceCallClientMessage fromId(int id) {
//     return VoiceCallClientMessage.values.firstWhere((type) => type.id == id);
//   }
// }

// mixin AesGcmCryto {
//   late Encrypter _encrypter;

//   Uint8List aesGcmEncrypt(Uint8List plainText) {
//     final random = Random();

//     final iv = IV(Uint8List.fromList(List.generate(12, (int index) {
//       return random.nextInt(192);
//     })));

//     final Encrypted encrypted = _encrypter.encryptBytes(
//       plainText,
//       iv: iv,
//     );

//     return Uint8List.fromList(iv.bytes + encrypted.bytes);
//   }

//   Uint8List aesGcmDecrypt(Uint8List ciphertext) {
//     ByteBuf buffer = ByteBuf.deepWrap(ciphertext);
//     Uint8List iv = buffer.readBytes(12);
//     Uint8List rest = buffer.readRemainingBytes();

//     final List<int> decrypted = _encrypter.decryptBytes(
//       Encrypted(rest),
//       iv: IV(iv),
//     );

//     return Uint8List.fromList(decrypted);
//   }
// }

// class VoiceCallUDPSocket with AesGcmCryto {
//   RawDatagramSocket? _udpSocket;
//   late Key _aesKey;

//   bool _isInitialized = false;
//   bool get isInitialized => _isInitialized;

//   Future<void> openSocket() async {
//     if (_udpSocket != null) {
//       _udpSocket!.close();
//       _udpSocket = null;
//       _isInitialized = false;
//     }

//     _udpSocket = await RawDatagramSocket.bind(
//       InternetAddress.anyIPv4,
//       9090,
//     );
//   }

//   Future<void> initialize(Uint8List aesKey) async {
//     _aesKey = Key(aesKey);

//     _encrypter = Encrypter(
//       AES(
//         _aesKey,
//         mode: AESMode.gcm,
//       ),
//     );

//     _isInitialized = true;
//   }

//   Stream<Uint8List?> get stream => _udpSocket!.map((RawSocketEvent event) {
//         Datagram? datagram = _udpSocket!.receive();
//         if (datagram == null) {
//           return null;
//         }

//         return aesGcmDecrypt(datagram.data);
//       });

//   StreamSubscription<RawSocketEvent> listen(
//     void Function(Uint8List data) onData, {
//     void Function()? onError,
//     void Function()? onDone,
//     bool? cancelOnError,
//   }) {
//     return _udpSocket!.listen(
//       (event) {
//         Datagram? datagram = _udpSocket!.receive();
//         if (datagram == null) {
//           return;
//         }

//         ByteBuf decrypted = ByteBuf.shallowWrap(aesGcmDecrypt(datagram.data));
//         VoiceCallClientMessage type = VoiceCallClientMessage.fromId(decrypted.readInt32());

//         switch (type) {
//           case VoiceCallClientMessage.voice:
//             onData(decrypted.readRemainingBytes());
//             break;
//           case VoiceCallClientMessage.endCall:
//             onDone?.call();
//             break;
//         }
//       },
//       onError: onError,
//       onDone: onDone,
//       cancelOnError: cancelOnError,
//     );
//   }

//   void sendSecureVoice(Uint8List message, JavaInetSocketAddress socket) {
//     ByteBuf buffer = ByteBuf(4 + message.length);
//     buffer.writeInt32(VoiceCallClientMessage.voice.id);
//     buffer.writeBytes(message);

//     rawSecureSend(buffer, socket.address, socket.port);
//   }

//   void rawSecureSend(ByteBuf message, InternetAddress address, int port) {
//     final encrypted = aesGcmEncrypt(message.buffer);

//     if (encrypted.length <= 32768) {
//       _udpSocket!.send(encrypted, address, port);
//     } else {
//       // ΕΔΩ ΕΓΚΕΙΤΑΙ ΤΟ ΠΡΟΒΛΗΜΑ
//       for (int i = 0; i < encrypted.length; i += 1024) {
//         int end = (i + 1024).clamp(0, encrypted.length);
//         _udpSocket!.send(encrypted.sublist(i, end), address, port);
//       }
//     }
//   }

//   void close(Iterable<JavaInetSocketAddress> sockets) {
//     ByteBuf buffer = ByteBuf(4);
//     buffer.writeInt32(VoiceCallClientMessage.endCall.id);

//     for (JavaInetSocketAddress socket in sockets) {
//       rawSecureSend(buffer, socket.address, socket.port);
//     }

//     _udpSocket!.close();
//     _udpSocket = null;
//     _isInitialized = false;
//   }
// }
