import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:ermis_client/client/client.dart';
import 'package:ermis_client/main_ui/user_profile.dart';
import 'package:ermis_client/util/dialogs_utils.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:synchronized/synchronized.dart';

class VoiceCallScreen extends StatefulWidget {
  final int chatSessionID;
  final int chatSessionIndex;
  const VoiceCallScreen({
    super.key,
    required this.chatSessionID,
    required this.chatSessionIndex,
  });

  @override
  State<VoiceCallScreen> createState() => VoiceCallScreenState();
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

  late final socket = UDPSocket();

  bool isMuted = false;
  bool isAudioRecording = false;
  bool isCallActive = false;

  int lastReadPosition = 0;

  CallStatus callStatus = CallStatus.connecting;

  @override
  void initState() {
    super.initState();
    _initializeCall();
  }

  void _initializeCall() async {
    final address = InternetAddress("192.168.10.103");
    final port = 8081;

    await socket.initialize(address, port, widget.chatSessionIndex);

    _startRecording();
  }

  Future<void> _startRecording() async {
    audioFilePath = '${(await getApplicationCacheDirectory()).path}/recording2.wav';
    await audioRecord.start(
      RecordConfig(encoder: AudioEncoder.wav),
      path: audioFilePath,
    );

    isAudioRecording = true;
    _listenAndSendAudio();
  }

  static final _lock = Lock();

  // Listen to the audio file and send it to the server in chunks
  Future<void> _listenAndSendAudio() async {
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      _lock.synchronized(() async {
        if (isAudioRecording) {
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
            _sendAudioToServer(audioData);
          }

          await raf.close();
        } else {
          print("Cancelled?");
          timer.cancel(); // Stop the timer when recording stops
        }
      });
    });
  }

  // Send the audio data to the server
  void _sendAudioToServer(Uint8List audioData) {
    try {
      socket.send(widget.chatSessionID, audioData);
    } catch (e) {
      print('Error sending audio: $e');
    }
  }

  // Stop recording
  Future<void> stopRecording() async {
    await audioRecord.stop();
    isAudioRecording = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
              UserProfilePhoto(radius: 100, profileBytes: Uint8List(0)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      isAudioRecording ? Icons.videocam_off : Icons.videocam,
                      size: 40,
                      color: isAudioRecording ? Colors.red : Colors.green,
                    ),
                    onPressed: () {
                      setState(() {
                        showToastDialog("Functionality not supported yet");
                        isAudioRecording = !isAudioRecording;
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
    setState(() {
      isCallActive = false;
      callStatus = CallStatus.ended;
    });
  }
}
