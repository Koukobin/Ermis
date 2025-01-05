import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class Microphone {

  static Future<Stream<Uint8List>?> startRecording() async {
    final record = AudioRecorder();

    String tempDirectory = (await getApplicationCacheDirectory()).toString();
    if (await record.hasPermission()) {
      await record.start(const RecordConfig(), path: '$tempDirectory/myFile.m4a');
      return await record
          .startStream(const RecordConfig(encoder: AudioEncoder.pcm16bits))
          .whenComplete(record.dispose);
    }

    return null;
  }
}
