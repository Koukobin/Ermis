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

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:ermis_client/client/client.dart';
import 'package:ermis_client/client/message_events.dart';
import 'package:ermis_client/main_ui/user_profile.dart';
import 'package:ermis_client/util/dialogs_utils.dart';
import 'package:ermis_client/util/top_app_bar_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:synchronized/synchronized.dart';

import '../../client/app_event_bus.dart';
import '../../util/permissions.dart';

class VoiceCallScreen extends StatefulWidget {
  final int chatSessionID;
  final int chatSessionIndex;
  final int voiceCallKey;
  // final VoiceCallIncomingEvent event;
  final VoiceCall callType;
  const VoiceCallScreen({
    super.key,
    required this.chatSessionID,
    required this.chatSessionIndex,
    this.voiceCallKey = 0,
    // this.event,
    required this.callType,
  });

  @override
  State<VoiceCallScreen> createState() => VoiceCallScreenState();
}

enum VoiceCall {
  accept, create;
}

enum CallStatus {
  connecting('Connecting...'),
  calling('Calling...'),
  ringing('Ringing...'), 
  ended('Ended');

  final String text;

  const CallStatus(this.text);
}

class VoiceCallScreenState extends State<VoiceCallScreen> {
  final AudioRecorder audioRecord = AudioRecorder();
  late final String audioFilePath;

  late final _udpSocket = UDPSocket();
  late final int voiceCallKey;

  double rms = 0.0;

  bool isMuted = false;
  bool isClosed = false;
  bool isShowingVideo = false;

  int lastReadPosition = 0;

  CallStatus callStatus = CallStatus.connecting;

  @override
  void initState() {
    super.initState();
    if (widget.voiceCallKey != 0) voiceCallKey = widget.voiceCallKey;

    void func() async {
      try {
        await _initiateCall();
      } catch (e) {
        showExceptionDialog(context, e.toString());
      }
    }

    func();
  }

  static int index = 0;

  Future<void> _initiateCall() async {
    await checkPermission(Permission.microphone);
    await checkPermission(Permission.camera);

    switch (widget.callType) {
      case VoiceCall.accept:
        // Client.getInstance().commands.acceptVoiceCall(widget.chatSessionID);
        break;
      case VoiceCall.create:
        Client.getInstance().commands.startVoiceCall(widget.chatSessionIndex);
        
        Completer<void> completer = Completer();
        AppEventBus.instance.on<StartVoiceCallResultEvent>().listen((event) {
          showExceptionDialog(context, "cheeks");
          this.voiceCallKey = event.key;
          completer.complete();
        });
        await completer.future;
        
        break;
    }


    final address = InternetAddress("192.168.10.103");
    final port = 9090;

    await showExceptionDialog(context, "cheeks0");

    await _udpSocket.initialize(address, port, widget.chatSessionIndex);

    _udpSocket.send(widget.chatSessionID, voiceCallKey, Uint8List(5));

    await showExceptionDialog(context, "cheeks1");

    FlutterSoundPlayer _player = FlutterSoundPlayer();
    await _player.openPlayer();
    await _player.startPlayerFromStream(
      codec: Codec.pcm16,
      sampleRate: 44100,
      numChannels: 2,
    );

    showExceptionDialog(context, "cheeks2");

    _udpSocket.listen((event) async {
      Datagram? datagram = _udpSocket.receive();
      if (datagram == null) {
        return;
      }

      _lock.synchronized(() async {
        print("listening");
        Uint8List data = datagram.data;
        await _player.feedFromStream(data);
        double rms = calculateRMS(data);
        print(rms);
        setState(() {
          this.rms = rms;
        });
        print(index++);
        // AudioPlayer audioPlayer = AudioPlayer();
        // await audioPlayer.play(
        //     BytesSource(await createWavFile(input.readBytes(readableBytes))));
        // audioPlayer.onPlayerComplete.listen((event) {
        //   print('Audio playback completed');
        // });
      });
    });

    await showExceptionDialog(context, "cheeks3");

    _startAudioRecording();
  }

  double calculateRMS(Uint8List audioChunk) {
    if (audioChunk.isEmpty) {
      print("Empty?");
      return 0.0; // Return 0 for empty audio samples.
    }
    Int16List audioSamples = audioChunk.buffer.asInt16List();
    num sumOfSquares = audioSamples
        .map((int sample) => pow(sample, 2))
        .reduce((num a, num b) => a + b);
    return sqrt(sumOfSquares / audioSamples.length);
  }


  Future<void> _startAudioRecording() async {
    await showExceptionDialog(context, "cheeks5");
    audioFilePath = '${(await getApplicationCacheDirectory()).path}/recording.wav';
    await audioRecord.start(
      RecordConfig(encoder: AudioEncoder.wav),
      path: audioFilePath,
    );

    await showExceptionDialog(context, "cheeks6");

    isMuted = false;
    _listenAndSendAudio();
  }

  static final _lock = Lock();

  // Listen to the audio file and send it to the server in chunks
  Future<void> _listenAndSendAudio() async {
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      _lock.synchronized(() async {
        if (isClosed) {
          timer.cancel();
          return;
        }

        if (isMuted) {
          print("Cancelled?");
          showExceptionDialog(context, "canceled?");
          return;
        }

        // Check if the file exists and has content
        File audioFile = File(audioFilePath);
        // Open the file and only read from the last read position
        final raf = await audioFile.open();
        final currentLength = await raf.length();

        if (currentLength > lastReadPosition) {
          // Read new data from the last read position
          await raf.setPosition(lastReadPosition);
          final audioData = await raf.read(currentLength);

          // Update the last read position
          lastReadPosition = currentLength;

          // Send the new audio data to the server
          _udpSocket.send(widget.chatSessionID, voiceCallKey, audioData);
        }

        await raf.close();
      });
    });
  }

  // Stop recording
  Future<void> stopRecording() async {
    await audioRecord.stop();
    isMuted = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ErmisAppBar(
        title: Text('Voice Call'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(
                    "ChatSession: ${widget.chatSessionID}",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(callStatus.text)
                ],
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedSize(
                    duration: Duration(milliseconds: 100),
                    child: CircleAvatar(
                      radius: (100 + rms) >= 200 ? 200 : 100 + rms,
                      backgroundColor: const Color.fromRGBO(158, 158, 158, 0.4),
                    ),
                  ),
                  UserProfilePhoto(radius: 100, profileBytes: Uint8List(0)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      isShowingVideo ? Icons.videocam : Icons.videocam_off,
                      size: 40,
                      color: isShowingVideo ? Colors.green : Colors.red,
                    ),
                    onPressed: () {
                      setState(() {
                        showToastDialog("Functionality not supported yet");
                        isShowingVideo = !isShowingVideo;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      isMuted ? Icons.mic_off : Icons.mic,
                      size: 40,
                      color: isMuted ? Colors.red : Colors.green,
                    ),
                    onPressed: _toggleMute,
                  ),
                  // End call button
                  GestureDetector(
                    onTap: _endCall,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(32.0)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Icon(
                          Icons.call,
                          size: 25,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _toggleMute() {
    setState(() {
      isMuted = !isMuted;
    });
  }

  void _endCall() {
    _udpSocket.close();
    setState(() {
      isClosed = false;
      callStatus = CallStatus.ended;
    });
  }
}
