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

import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class ImageUtils {
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
