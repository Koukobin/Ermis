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

import 'package:camera/camera.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:ermis_client/util/dialogs_utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img;

typedef FileCallBack = void Function(String fileName, Uint8List fileContent);

class MyCamera {
  static Future<CameraController> initializeCamera() async {
    // Get a list of available cameras
    final cameras = await availableCameras();

    // Select the first camera (typically the back camera)
    final CameraDescription camera = cameras.first;

    // Initialize the camera
    CameraController controller =
        CameraController(camera, ResolutionPreset.high);
    return controller..initialize();
  }

  static Future<XFile?> capturePhoto() async {
    final picker = ImagePicker();
    XFile? pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      return pickedFile;
    }
    return null;
  }
}

Future<String?> saveFileToDownloads(String fileName, Uint8List fileData) async {
  bool isSuccessful = await requestPermissions();

  if (!isSuccessful) {
    return null;
  }

  final params = SaveFileDialogParams(
    fileName: fileName,
    data: fileData,
  );

  final filePath = await FlutterFileDialog.saveFile(params: params);
  return filePath;
}

Future<void> writeFile(Uint8List fileData, String filePath) async {
  if (kDebugMode) {
    debugPrint(filePath);
  }

  // Write the file to disk
  File file = File(filePath);
  await file.create();
  await file.writeAsBytes(fileData, mode: FileMode.write, flush: true);
}

Future<bool> requestPermissions({BuildContext? context}) async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

  if (kDebugMode && context != null) {
    showSimpleAlertDialog(
        context: context,
        title: "Debug Mode",
        content: "Android Version:${androidInfo.version.sdkInt.toString()}");
  }

  // WARNING: very shitty code
  bool success = true;

  Future<bool> checkPermission(Permission permission) async {
    if (await permission.request().isPermanentlyDenied ||
        await permission.request().isDenied) {
      return false;
    }
    return true;
  }

  if (androidInfo.version.sdkInt <= 29) {
    success = await checkPermission(Permission.storage);
  } else if (androidInfo.version.sdkInt < 33) {
    success = await checkPermission(Permission.manageExternalStorage);
  } else if (androidInfo.version.sdkInt >= 33) {
    const permissions = [
      Permission.photos,
      Permission.audio,
      Permission.videos,
    ];

    for (Permission permission in permissions) {
      success = await checkPermission(permission);
    }
  }

  if (!success) openAppSettings();
  return success;
}

Future<void> attachSingleFile(
    BuildContext context, FileCallBack onFinished) async {
  bool isSuccessful = await requestPermissions(context: context);

  if (!isSuccessful) {
    return;
  }

  FilePickerResult? result = await FilePicker.platform.pickFiles(
    allowMultiple: false, // Do not allow the selection of multiple files
  );

  if (result != null) {
    PlatformFile file = result.files.first;

    Uint8List? fileBytes = file.bytes;
    // If the file has not already been loaded into RAM, load it manually
    fileBytes ??= await File(file.path!).readAsBytes();

    onFinished(file.name, fileBytes);
  } else {
    // User canceled the file picker
  }
}

Future<String> readFileFromPath(String filePath) async {
  final file = File(filePath);
  return await file.readAsString();
}

Future<String> loadAssetFile(String assetPath) async {
  return await rootBundle.loadString(assetPath);
}

/// This function checks for the given file's signature and allows
/// you to identify whether the byte data is valid for a particular
/// image format.
bool isImage(Uint8List bytes) {
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

Size getImageDimensions(Uint8List imageBytes) {
  // Decode the image bytes to an image object
  img.Image? image = img.decodeImage(imageBytes);

  if (image == null) return Size(0, 0);
  return Size(image.width.toDouble(), image.height.toDouble());
}
