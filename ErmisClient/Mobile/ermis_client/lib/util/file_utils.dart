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
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:image_picker/image_picker.dart';

import 'permissions.dart';

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

Future<Uint8List> createWavFile(Uint8List pcmData) async {
  // WAV Header structure
  int sampleRate = 44100; // Change if needed
  int numChannels = 2;    // Stereo
  int bitDepth = 16;      // 16-bit audio

  // Calculate the size of the WAV file
  int pcmDataSize = pcmData.lengthInBytes;
  int headerSize = 44; // Standard WAV header size
  int dataSize = pcmDataSize;
  int fileSize = headerSize + dataSize;

  // Create the WAV header (44 bytes)
  List<int> header = List.filled(headerSize, 0);

  // Chunk ID ("RIFF")
  header[0] = 82;
  header[1] = 73;
  header[2] = 70;
  header[3] = 70;

  // File size (total size minus 8 bytes for the "RIFF" chunk descriptor)
  header[4] = (fileSize - 8) & 0xFF;
  header[5] = ((fileSize - 8) >> 8) & 0xFF;
  header[6] = ((fileSize - 8) >> 16) & 0xFF;
  header[7] = ((fileSize - 8) >> 24) & 0xFF;

  // Format ("WAVE")
  header[8] = 87;
  header[9] = 65;
  header[10] = 86;
  header[11] = 69;

  // Subchunk1 ID ("fmt ")
  header[12] = 102;
  header[13] = 109;
  header[14] = 116;
  header[15] = 32;

  // Subchunk1 size (16 for PCM)
  header[16] = 16;
  header[17] = 0;
  header[18] = 0;
  header[19] = 0;

  // Audio format (1 for PCM)
  header[20] = 1;
  header[21] = 0;

  // Number of channels (2 for stereo)
  header[22] = numChannels;
  header[23] = 0;

  // Sample rate
  header[24] = sampleRate & 0xFF;
  header[25] = (sampleRate >> 8) & 0xFF;
  header[26] = (sampleRate >> 16) & 0xFF;
  header[27] = (sampleRate >> 24) & 0xFF;

  // Byte rate (sampleRate * numChannels * bitDepth / 8)
  int byteRate = sampleRate * numChannels * (bitDepth ~/ 8);
  header[28] = byteRate & 0xFF;
  header[29] = (byteRate >> 8) & 0xFF;
  header[30] = (byteRate >> 16) & 0xFF;
  header[31] = (byteRate >> 24) & 0xFF;

  // Block align (numChannels * bitDepth / 8)
  int blockAlign = numChannels * (bitDepth ~/ 8);
  header[32] = blockAlign & 0xFF;
  header[33] = (blockAlign >> 8) & 0xFF;

  // Bits per sample (16-bit)
  header[34] = bitDepth;
  header[35] = 0;

  // Subchunk2 ID ("data")
  header[36] = 100;
  header[37] = 97;
  header[38] = 116;
  header[39] = 97;

  // Subchunk2 size (size of the audio data)
  header[40] = dataSize & 0xFF;
  header[41] = (dataSize >> 8) & 0xFF;
  header[42] = (dataSize >> 16) & 0xFF;
  header[43] = (dataSize >> 24) & 0xFF;

  // Write the WAV header and PCM data to a file
  // Combine the header and PCM data
  List<int> wavFileData = [...header, ...pcmData];
  return Uint8List.fromList(wavFileData);
}
