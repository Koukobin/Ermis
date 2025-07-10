/* Copyright (C) 2025 Ilias Koukovinis <ilias.koukovinis@gmail.com>
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

// import 'dart:typed_data';

// import 'package:ermis_mobile/core/util/dialogs_utils.dart';
// import 'package:flutter_sound/flutter_sound.dart';

// Future<void> inferAndPlayFile(Uint8List buffer) async {
//   final player = FlutterSoundPlayer();
//   await player.openPlayer();

//   if (await analyzeWav(buffer)) {
//     final metadata = await inferWavMetadata(buffer);
//     await player.startPlayerFromStream(
//       codec: metadata!["codec"],
//       sampleRate: metadata["sampleRate"],
//       numChannels: metadata["numChannels"],
//       interleaved: metadata["interleaved"],
//       bufferSize: metadata["bufferSize"],
//     );
//   } else {
//     showToastDialog("Autio type note recognized");
//     return;
//   }

//   await player.feedUint8FromStream(buffer);
// }

// Future<bool> analyzeWav(Uint8List bytes) async {
//   if (bytes.length < 12) {
//     print('File too short to be a valid WAV');
//     return false;
//   }

//   final riff = String.fromCharCodes(bytes.sublist(0, 4));
//   final wave = String.fromCharCodes(bytes.sublist(8, 12));

//   if (riff == 'RIFF' && wave == 'WAVE') {
//     print('Likely a WAV file');
//     // Look for the "fmt " chunk
//     int fmtChunkOffset = -1;
//     int i = 12;
//     while (i < bytes.length - 8) {
//       final chunkId = String.fromCharCodes(bytes.sublist(i, i + 4));
//       final chunkSize = bytes.buffer.asByteData(i + 4, 4).getInt32(0, Endian.little);
//       if (chunkId == 'fmt ') {
//         fmtChunkOffset = i + 8;
//         break;
//       }
//       i += 8 + chunkSize;
//     }

//     if (fmtChunkOffset != -1 && fmtChunkOffset + 16 <= bytes.length) {
//       // final audioFormat = bytes.buffer.asByteData(fmtChunkOffset, 2).getUint16(0, Endian.little);
//       // final numChannels = bytes.buffer.asByteData(fmtChunkOffset + 2, 2).getUint16(0, Endian.little);
//       // final sampleRate = bytes.buffer.asByteData(fmtChunkOffset + 4, 4).getUint32(0, Endian.little);
//       // final byteRate = bytes.buffer.asByteData(fmtChunkOffset + 8, 4).getUint32(0, Endian.little);
//       // final bitsPerSample = bytes.buffer.asByteData(fmtChunkOffset + 14, 2).getUint16(0, Endian.little);

//       // print('  Audio Format: $audioFormat (1 for PCM)');
//       // print('  Number of Channels: $numChannels');
//       // print('  Sample Rate: $sampleRate Hz');
//       // print('  Byte Rate: $byteRate bytes/second');
//       // print('  Bits per Sample: $bitsPerSample');

//       // if (audioFormat == 1) { // PCM (uncompressed)
//       //   final inferredBitrate = numChannels * sampleRate * bitsPerSample;
//       //   print('  Inferred Bitrate: $inferredBitrate bits/second');
//       // }

//       return true;
//     } else {
//       print('  Could not find or parse "fmt " chunk.');
//     }
//   } else {
//     print('Not likely a WAV file (missing RIFF or WAVE headers)');
//   }

//   return false;
// }

// Future<Map<String, dynamic>?> inferWavMetadata(Uint8List bytes) async {
//   if (bytes.length < 44) return null; // Minimum size for PCM WAV header

//   final audioFormat = bytes.buffer.asByteData(20, 2).getUint16(0, Endian.little);
//   final numChannels = bytes.buffer.asByteData(22, 2).getUint16(0, Endian.little);
//   final sampleRate = bytes.buffer.asByteData(24, 4).getUint32(0, Endian.little);
//   final bitsPerSample = bytes.buffer.asByteData(34, 2).getUint16(0, Endian.little);
//   final byteRate = bytes.buffer.asByteData(28, 4).getUint32(0, Endian.little);
//   final blockAlign = bytes.buffer.asByteData(32, 2).getUint16(0, Endian.little);

//   bool interleaved = (audioFormat == 1 && numChannels > 1 && blockAlign == numChannels * bitsPerSample / 8);

//   return {
//     'codec': audioFormat == 1 && bitsPerSample == 16 ? Codec.pcm16 : null,
//     'sampleRate': sampleRate,
//     'numChannels': numChannels,
//     'interleaved': interleaved,
//   };
// }

// Future<void> analyzeMp3(String filePath) async {
//   final file = File(filePath);
//   if (!await file.exists()) {
//     print('File not found');
//     return;
//   }

//   final bytes = await file.readAsBytes();
//   if (bytes.length < 3) {
//     print('File too short to be a valid MP3');
//     return;
//   }

//   // Look for the ID3 tag (optional)
//   if (bytes.length >= 3 && String.fromCharCodes(bytes.sublist(0, 3)) == 'ID3') {
//     print('Likely an MP3 file with an ID3 tag');
//     // You would need to parse the ID3 tag to potentially find bitrate info
//     // This is complex and not always present or accurate for the audio stream.
//   } else {
//     print('Likely an MP3 file (no initial ID3 tag found)');
//   }

//   // Try to find the first MP3 frame sync word (0xFFE0 - 0xFFFE)
//   for (int i = 0; i < bytes.length - 1; i++) {
//     if (bytes[i] == 0xFF && (bytes[i + 1] & 0xE0) == 0xE0) {
//       print('Found potential MP3 frame sync word at index $i');
//       // You would need to parse the frame header at this point to determine bitrate.
//       // This involves looking at specific bits within the following bytes.
//       // The bitrate is encoded in a 4-bit field. You'd need a lookup table
//       // based on the MPEG version and layer.
//       break; // Found the first frame, further analysis needed
//     }
//   }
// }