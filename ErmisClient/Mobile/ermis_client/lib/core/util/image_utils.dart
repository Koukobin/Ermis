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

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

enum ImageType {
  png,
  jpeg,
  gif,
  bmp,
  tiff,
  ico,
  cur,
  pvr,
  webp,
  psd,
  exr,
  pnm, // covers PBM, PGM, PPM
  unknown,
}

class ImageUtils {
  /// Detects image type from raw bytes based on magic numbers.
  ///
  /// Pass at least the first 12 bytes of the file for reliable detection.
  /// Returns [ImageType.unknown] if the format cannot be determined.
  static ImageType detectImageType(List<int> bytes) {
    if (bytes.isEmpty) return ImageType.unknown;

    // PNG: 89 50 4E 47 0D 0A 1A 0A
    if (_matchesSignature(bytes, [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])) {
      return ImageType.png;
    }

    // JPEG: FF D8 FF
    if (_matchesSignature(bytes, [0xFF, 0xD8, 0xFF])) {
      return ImageType.jpeg;
    }

    // GIF: 47 49 46 38 37 61 ("GIF87a") or 47 49 46 38 39 61 ("GIF89a")
    if (_matchesSignature(bytes, [0x47, 0x49, 0x46, 0x38, 0x37, 0x61]) ||
        _matchesSignature(bytes, [0x47, 0x49, 0x46, 0x38, 0x39, 0x61])) {
      return ImageType.gif;
    }

    // BMP: 42 4D ("BM")
    if (_matchesSignature(bytes, [0x42, 0x4D])) {
      return ImageType.bmp;
    }

    // TIFF: 49 49 2A 00 (little-endian) or 4D 4D 00 2A (big-endian)
    if (_matchesSignature(bytes, [0x49, 0x49, 0x2A, 0x00]) ||
        _matchesSignature(bytes, [0x4D, 0x4D, 0x00, 0x2A])) {
      return ImageType.tiff;
    }

    // WebP: 52 49 46 46 (?? ?? ?? ??) 57 45 42 50
    // "RIFF" at offset 0, "WEBP" at offset 8
    if (bytes.length >= 12 &&
        _matchesSignature(bytes, [0x52, 0x49, 0x46, 0x46]) &&
        _matchesSignature(bytes.sublist(8), [0x57, 0x45, 0x42, 0x50])) {
      return ImageType.webp;
    }

    // ICO: 00 00 01 00
    if (_matchesSignature(bytes, [0x00, 0x00, 0x01, 0x00])) {
      return ImageType.ico;
    }

    // CUR: 00 00 02 00
    if (_matchesSignature(bytes, [0x00, 0x00, 0x02, 0x00])) {
      return ImageType.cur;
    }

    // PSD (Photoshop): 38 42 50 53 ("8BPS")
    if (_matchesSignature(bytes, [0x38, 0x42, 0x50, 0x53])) {
      return ImageType.psd;
    }

    // EXR (OpenEXR): 76 2F 31 01
    if (_matchesSignature(bytes, [0x76, 0x2F, 0x31, 0x01])) {
      return ImageType.exr;
    }

    // PVR (PowerVR v3): 50 56 52 03 ("PVR\x03")
    if (_matchesSignature(bytes, [0x50, 0x56, 0x52, 0x03])) {
      return ImageType.pvr;
    }

    // PNM variants (plain text headers):
    //   PBM: P1 or P4
    //   PGM: P2 or P5
    //   PPM: P3 or P6
    //   PAM: P7
    if (bytes.length >= 2 && bytes[0] == 0x50) {
      final second = bytes[1];
      if (second >= 0x31 && second <= 0x37) { // '1'..'7'
        return ImageType.pnm;
      }
    }

    return ImageType.unknown;
  }

  static bool _matchesSignature(List<int> bytes, List<int> signature) {
    if (bytes.length < signature.length) return false;
    for (var i = 0; i < signature.length; i++) {
      if (bytes[i] != signature[i]) return false;
    }
    return true;
  }

  /// This function checks for the given file's signature and allows
  /// you to identify whether the byte data is valid for a particular
  /// image format.
  static bool isImage(Uint8List bytes) {
    // Check for JPEG signature
    if (bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF) {
      return true;
    }

    // Check for PNG signature
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0D &&
        bytes[5] == 0x0A &&
        bytes[6] == 0x1A &&
        bytes[7] == 0x0A) {
      return true;
    }

    // Check for GIF signature
    if (bytes.length >= 6 &&
        bytes[0] == 0x47 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        (bytes[3] == 0x38 && (bytes[4] == 0x37 || bytes[4] == 0x39)) &&
        bytes[5] == 0x61) {
      return true;
    }

    // Check for BMP (Windows bitmap) signature
    if (bytes.length >= 2 && bytes[0] == 0x42 && bytes[1] == 0x4D) {
      return true;
    }

    // Check for TIFF signature (big-endian)
    if (bytes.length >= 4 &&
        bytes[0] == 0x49 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x2A &&
        bytes[3] == 0x00) {
      return true;
    }

    // Check for TIFF signature (little-endian)
    if (bytes.length >= 4 &&
        bytes[0] == 0x4D &&
        bytes[1] == 0x4D &&
        bytes[2] == 0x00 &&
        bytes[3] == 0x2A) {
      return true;
    }

    // Check for WEBP signature
    if (bytes.length >= 4 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46) {
      // Check for 'WEBP' in the next bytes
      if (bytes.length >= 12 &&
          bytes[8] == 0x57 &&
          bytes[9] == 0x45 &&
          bytes[10] == 0x42 &&
          bytes[11] == 0x50) {
        return true;
      }
    }

    // Check for HEIC/HEIF signature (using the 'ftyp' box)
    if (bytes.length >= 12 &&
        bytes[4] == 0x66 &&
        bytes[5] == 0x74 &&
        bytes[6] == 0x79 &&
        bytes[7] == 0x70 &&
        (bytes[8] == 0x68 ||
            bytes[8] == 0x69 ||
            bytes[8] == 0x6A ||
            bytes[8] == 0x64)) {
      return true;
    }

    return false;
  }

  static Size resizeImage({
    required Uint8List imageBytes,
    required double maxWidth,
    required double maxHeight,
  }) {
    Size dimensions = ImageUtils.getImageDimensions(imageBytes);
    double width = dimensions.width;
    double height = dimensions.height;

    height = maxHeight;
    width = dimensions.aspectRatio * height;
    if (width > maxWidth) {
      double difference = maxWidth / width;
      height = height * difference;
      width = dimensions.aspectRatio * height;
    }

    if (kDebugMode) {
      debugPrint('Width: ${width.toString()}');
      debugPrint('Height: ${height.toString()}');
    }

    /**
      * Initial shitty calculation of the images' dimensions kept here for science purposes
      * 
      * double width = maxWidth;
      * double height = dimensions.height;
      * 
      * // Iterations flag ensures while loop never causes a crash even
      * // if done wrong
      * int iterations = 100;
      * while (iterations > 0) {
      * 	iterations--;
      * 	if (width > maxWidth) {
      * 		width -= 100;
      * 		height = (1 / dimensions.aspectRatio) * width;
      * 	}
      * 
      * 	if (height > maxHeight) {
      * 		height -= 100;
      * 		width = dimensions.aspectRatio * height;
      * 	}
      * 
      * 	if (width > maxWidth || height > maxHeight)
      * 		continue;
      * 
      * 	break;
      * }
    */

    return Size(width, height);
  }

  static Size getImageDimensions(Uint8List imageBytes) {
    // Decode the image bytes to an image object
    img.Image? image = img.decodeImage(imageBytes);

    if (image == null) return Size(0, 0);
    return Size(image.width.toDouble(), image.height.toDouble());
  }

  static Future<double> resolveImageDimensions(Image image, {double? desiredHeight, double? desiredWidth}) async {
    assert (desiredHeight != null || desiredWidth != null); // Ensure at least one is mentioned
    assert (desiredHeight == null || desiredWidth == null); // Ensure at least one is not mentioned

    ImageStream imageStream = image.image.resolve(const ImageConfiguration());

    ImageStreamListener? listener;

    double? imageWidth;
    double? imageHeight;

    listener = ImageStreamListener((ImageInfo info, bool _) {
      double aspectRatio = info.image.height / info.image.width;

      imageWidth = image.height! / aspectRatio;
      imageHeight = image.height!;

      imageStream.removeListener(listener!);
    });

    imageStream.addListener(listener);

    // Block until data available
    await Future.doWhile(() async {
      return await Future.delayed(const Duration(milliseconds: 10), () {
        return (imageWidth == null && imageHeight == null);
      });
    });

    return desiredHeight == null ? imageWidth! : imageHeight!;
  }
}


enum MediaFormat {
  // Video
  mp4,
  mkv,
  webm,
  flv,
  mpegTs,
  mpegPs,
  avi,
  // Audio
  mp3,
  aac,
  ogg,
  flac,
  wav,
  // Unknown
  unknown,
}

/// Detects the media format of a file based on its file signature
Future<MediaFormat> detectMediaFormat(String filePath) async {
  final file = File(filePath);
  if (!await file.exists()) {
    throw FileSystemException('File not found', filePath);
  }

  // Read 12 bytes to cover all signatures
  final raf = await file.open();
  final bytes = await raf.read(12);
  await raf.close();

  return detectFromBytes(bytes);
}

/// Detects media format from raw bytes by evaluating magic number
MediaFormat detectFromBytes(Uint8List bytes) {
  if (bytes.length < 4) {
    return MediaFormat.unknown;
  }

  bool matchAt(Uint8List bytes, int offset, List<int> signature) {
    if (bytes.length < offset + signature.length) return false;
    for (int i = 0; i < signature.length; i++) {
      if (bytes[offset + i] != signature[i]) return false;
    }
    return true;
  }

  // ── MP4 / M4A / M4V / MOV ──────────────────────────────────────────────────
  // Bytes 4–7 are the box type: ftyp, moov, mdat, free, etc.
  // ftyp box is the standard indicator for MP4-family files.
  if (bytes.length >= 8 && matchAt(bytes, 4, [0x66, 0x74, 0x79, 0x70])) {
    return MediaFormat.mp4;
  }

  // ── Matroska / MKV ─────────────────────────────────────────────────────────
  // EBML header: 1A 45 DF A3
  if (matchAt(bytes, 0, [0x1A, 0x45, 0xDF, 0xA3])) {
    // WebM is a subset of MKV — distinguish by DocType in the EBML header.
    // For magic-number purposes we label it MKV; deeper inspection needed for WebM.
    return MediaFormat.mkv;
  }

  // ── WebM ───────────────────────────────────────────────────────────────────
  // WebM shares the EBML magic number with MKV (caught above).
  // A more reliable check requires reading the EBML DocType string "webm".
  // This branch handles files where the DocType can be found in the first 12 bytes.
  if (bytes.length >= 12) {
    final chunk = String.fromCharCodes(bytes.sublist(0, 12));
    if (chunk.contains('webm')) {
      return MediaFormat.webm;
    }
  }

  // ── FLV ────────────────────────────────────────────────────────────────────
  // 46 4C 56  ("FLV") followed by version byte
  if (matchAt(bytes, 0, [0x46, 0x4C, 0x56])) {
    return MediaFormat.flv;
  }

  // ── MPEG-TS ────────────────────────────────────────────────────────────────
  // Sync byte 0x47 at offset 0 (and repeats every 188 bytes, but 1 byte is enough here)
  if (bytes[0] == 0x47) {
    return MediaFormat.mpegTs;
  }

  // ── MPEG-PS ────────────────────────────────────────────────────────────────
  // Pack start code: 00 00 01 BA
  if (matchAt(bytes, 0, [0x00, 0x00, 0x01, 0xBA])) {
    return MediaFormat.mpegPs;
  }

  // ── AVI ────────────────────────────────────────────────────────────────────
  // RIFF....AVI : 52 49 46 46 ?? ?? ?? ?? 41 56 49 20
  if (bytes.length >= 12 &&
      matchAt(bytes, 0, [0x52, 0x49, 0x46, 0x46]) &&
      matchAt(bytes, 8, [0x41, 0x56, 0x49, 0x20])) {
    return MediaFormat.avi;
  }

  // ── MP3 ────────────────────────────────────────────────────────────────────
  // ID3 tag: 49 44 33
  if (matchAt(bytes, 0, [0x49, 0x44, 0x33])) {
    return MediaFormat.mp3;
  }
  // Raw MP3 sync word: FF FB / FF FA / FF F3 / FF F2
  if (bytes[0] == 0xFF &&
      (bytes[1] == 0xFB ||
          bytes[1] == 0xFA ||
          bytes[1] == 0xF3 ||
          bytes[1] == 0xF2)) {
    return MediaFormat.mp3;
  }

  // ── AAC (ADTS) ─────────────────────────────────────────────────────────────
  // Sync word: FF F1 (MPEG-4 AAC) or FF F9 (MPEG-2 AAC)
  if (bytes[0] == 0xFF && (bytes[1] == 0xF1 || bytes[1] == 0xF9)) {
    return MediaFormat.aac;
  }

  // ── OGG ────────────────────────────────────────────────────────────────────
  // 4F 67 67 53  ("OggS")
  if (matchAt(bytes, 0, [0x4F, 0x67, 0x67, 0x53])) {
    return MediaFormat.ogg;
  }

  // ── FLAC ───────────────────────────────────────────────────────────────────
  // 66 4C 61 43  ("fLaC")
  if (matchAt(bytes, 0, [0x66, 0x4C, 0x61, 0x43])) {
    return MediaFormat.flac;
  }

  // ── WAV ────────────────────────────────────────────────────────────────────
  // RIFF....WAVE : 52 49 46 46 ?? ?? ?? ?? 57 41 56 45
  if (bytes.length >= 12 &&
      matchAt(bytes, 0, [0x52, 0x49, 0x46, 0x46]) &&
      matchAt(bytes, 8, [0x57, 0x41, 0x56, 0x45])) {
    return MediaFormat.wav;
  }

  return MediaFormat.unknown;
}


