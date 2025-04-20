

import 'dart:math';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';

void main() {
  final random = Random();
  final key = Key(Uint8List.fromList(List.generate(32, (int index) {
    return random.nextInt(192);  // Generate a 16-byte IV for AES
  })));  // 256-bit key
  final iv = IV(Uint8List.fromList(List.generate(12, (int index) {
    return random.nextInt(192);  // Generate a 16-byte IV for AES
  })));

  final encrypter = Encrypter(AES(key, mode: AESMode.gcm));  // Use gcm mode

  final Encrypted encrypted = encrypter.encryptBytes(
    ['h'.codeUnitAt(0), 'i'.codeUnitAt(0)],  // 'h' and 'i' as byte list
    iv: iv,
  );

  print(key.bytes);
  print(iv.bytes);
  print('Encrypted bytes: ${iv.bytes + encrypted.bytes}');
  print('Encrypted size: ${encrypted.bytes.length}');  // Should print the length of the encrypted data
}