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

import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';

class AESGCMKey {
  final Key _key;
  final IV _iv;

  AESGCMKey(Uint8List secretKey)
      : _key = Key(secretKey),
        _iv = IV.fromSecureRandom(12);

  /// Encrypt a message (String)
  Uint8List encrypt(String message) {
    return _encrypt(utf8.encode(message));
  }

  /// Encrypt a message (Bytes)
  Uint8List _encrypt(Uint8List message) {
    final encrypter = Encrypter(
      AES(_key, mode: AESMode.gcm, padding: null),
    );
    final encrypted = encrypter.encryptBytes(message, iv: _iv);
    return Uint8List.fromList(encrypted.bytes + _iv.bytes);
  }

  /// Decrypt an encrypted message (Bytes)
  String decrypt(Uint8List encryptedMessage) {
    // Extract components: ciphertext, IV, and MAC
    final macOffset = encryptedMessage.length - 16; // 16 bytes for GCM tag
    final ivOffset = macOffset - 12; // 12 bytes for IV
    final ciphertext = encryptedMessage.sublist(0, ivOffset);
    final ivBytes = encryptedMessage.sublist(ivOffset, macOffset);

    final encrypter = Encrypter(
      AES(_key, mode: AESMode.gcm, padding: null),
    );

    final iv = IV(ivBytes);

    final decrypted = encrypter.decryptBytes(
      Encrypted(ciphertext),
      iv: iv,
    );

    return utf8.decode(decrypted);
  }

  /// Get the raw secret key
  Uint8List get secretKey => _key.bytes;
}
