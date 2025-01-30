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

import 'package:ermis_client/client/message_events.dart';
import 'package:ermis_client/client/voice_call_udp_socket.dart';
import 'package:ermis_client/main_ui/user_profile.dart';
import 'package:ermis_client/util/dialogs_utils.dart';
import 'package:ermis_client/util/top_app_bar_utils.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:synchronized/synchronized.dart';

import '../../client/app_event_bus.dart';
import '../../client/common/chat_session.dart';
import '../../util/notifications_util.dart';
import '../../util/permissions.dart';
import '../../util/transitions_util.dart';

class VoiceCallHandler {
  static void startListeningForIncomingCalls(BuildContext context) {
    AppEventBus.instance.on<VoiceCallIncomingEvent>().listen((event) {
      Member member = event.member;
      NotificationService.showVoiceCallNotification(
          icon: member.getIcon,
          callerName: member.getUsername,
          chatSessionIndex: event.chatSessionID,
          onAccept: () {
            navigateWithFade(
                context,
                VoiceCallScreen._(
                    chatSessionID: event.chatSessionID,
                    chatSessionIndex: event.chatSessionIndex,
                    voiceCallKey: event.voiceCallKey,
                    udpServerPort: event.udpServerPort,
                    member: member));
          });
    });
  }

  static Future<void> initiateVoiceCall(
    BuildContext context, {
    required int chatSessionIndex,
    required int chatSessionID,
  }) async {
    // WebRTCService.startCall(chatSessionID);

    late int voiceCallKey;
    late int port;
    Completer<void> completer = Completer();
    AppEventBus.instance.on<StartVoiceCallResultEvent>().listen((event) {
      voiceCallKey = event.key;
      port = event.udpServerPort;
      completer.complete();
    });
    await completer.future;
    navigateWithFade(
        context,
        VoiceCallScreen._(
          chatSessionIndex: chatSessionIndex,
          chatSessionID: chatSessionID,
          voiceCallKey: voiceCallKey,
          udpServerPort: port,
          member: null,
        ));
  }
}

class VoiceCallScreen extends StatefulWidget {
  final int chatSessionID;
  final int chatSessionIndex;
  final int voiceCallKey;
  final int udpServerPort;
  final Member? member;
  const VoiceCallScreen._({
    super.key,
    required this.chatSessionID,
    required this.chatSessionIndex,
    required this.voiceCallKey,
    required this.udpServerPort,
    required this.member,
  });

  @override
  State<VoiceCallScreen> createState() => VoiceCallScreenState();
}

enum VoiceCall {
  accept,
  create;
}

enum CallStatus {
  connecting('Connecting...'),
  calling('Calling...'),
  active('Active...'),
  ringing('Ringing...'),
  ended('Ended');

  final String text;
  const CallStatus(this.text);
}

class VoiceCallScreenState extends State<VoiceCallScreen> {
  // final AudioRecorder audioRecord = AudioRecorder();
  late final String audioFilePath;

  late final _udpSocket = VoiceCallUDPSocket();

  double rms = 0.0;

  bool isMuted = false;
  bool isShowingVideo = false;

  int lastReadPosition = 0;

  CallStatus callStatus = CallStatus.calling;

  @override
  void initState() {
    super.initState();
    _initiateCall();
  }

  static int index = 0;

  Future<void> _initiateCall() async {
    await checkPermission(Permission.microphone);
    await checkPermission(Permission.camera);

    // final address = Client.getInstance().serverInfo.address;

    // await _udpSocket.initialize(
    //     address, widget.udpServerPort, widget.chatSessionIndex);
    // _udpSocket.chatSessionID = widget.chatSessionID;
    // _udpSocket.key = widget.voiceCallKey;

    // _udpSocket.send(Uint8List(0)); // Test packet

    // FlutterSoundPlayer player = FlutterSoundPlayer();
    // await player.openPlayer();
    // await player.startPlayerFromStream(
    //   codec: Codec.pcm16,
    //   sampleRate: 44100,
    //   numChannels: 2,
    // );

    // _udpSocket.listen((datagram) async {
    //   Uint8List data = datagram.data;
    //   VoiceCallServerMessage type =
    //       VoiceCallServerMessage.fromId(ByteBuf.wrap(data).readInt32());

    //   switch (type) {
    //     case VoiceCallServerMessage.voice:
    //       callStatus = CallStatus.active;
    //       _lock.synchronized(() async {
    //         await player.feedFromStream(data);
    //         double rms = calculateRMS(data);
    //         if (kDebugMode) debugPrint('RMS: $rms');
    //         setState(() {
    //           this.rms = rms;
    //         });
    //       });
    //       break;
    //     case VoiceCallServerMessage.userAdded:
    //       setState(() => callStatus = CallStatus.connecting);
    //       break;
    //     case VoiceCallServerMessage.callEnded:
    //       _endCall();
    //       break;
    //   }
    // });

    // _startAudioRecording();
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
    // audioFilePath =
    //     '${(await getApplicationCacheDirectory()).path}/recording.wav';
    // await audioRecord.start(
    //   RecordConfig(encoder: AudioEncoder.wav),
    //   path: audioFilePath,
    // );

    // isMuted = false;
    // _listenAndSendAudio();
  }

  static final _lock = Lock();

  // Listen to the audio file and send it to the server in chunks
  Future<void> _listenAndSendAudio() async {
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      _lock.synchronized(() async {
        if (callStatus == CallStatus.ended) {
          timer.cancel();
          return;
        }

        if (isMuted) {
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
          _udpSocket.send(audioData);
        }

        await raf.close();
      });
    });
  }

  // Stop recording
  Future<void> stopRecording() async {
    // await audioRecord.stop();
    isMuted = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ErmisAppBar(
        title: Text('Voice Call'),
        actions: [],
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

  Future<void> _endCall() async {
    _udpSocket.close();
    setState(() {
      callStatus = CallStatus.ended;
    });
    Navigator.pop(context);
  }
}


// class _WebRTCExampleState extends State<WebRTCExample> {
//   late CallState _callState;
//   late Call call;
//   bool microphoneEnabled = false;

//   @override
//   void initState() {
//     super.initState();

//     StreamVideo(
//       'mmhfdzb5evj2',
//       user: const User(
//         info: UserInfo(
//           name: 'John Doe',
//           id: 'Ki-Adi-Mundi',
//         ),
//       ),
//       userToken:
//           'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL3Byb250by5nZXRzdHJlYW0uaW8iLCJzdWIiOiJ1c2VyL0tpLUFkaS1NdW5kaSIsInVzZXJfaWQiOiJLaS1BZGktTXVuZGkiLCJ2YWxpZGl0eV9pbl9zZWNvbmRzIjo2MDQ4MDAsImlhdCI6MTczNzE0NjgxMSwiZXhwIjoxNzM3NzUxNjExfQ.qHYZyMyFjkgJaKWsjcqn8igtlJzMmK195YHWxs22DD4',
//     );

//     _createAudioRoom();
//   }

//   Future<void> _createAudioRoom() async {
//     // Set up our call object
//     call = StreamVideo.instance.makeCall(
//       callType: StreamCallType.audioRoom(),
//       id: 'REPLACE_WITH_CALL_ID',
//     );

//     final result = await call.getOrCreate(); // Call object is created

//     if (result.isSuccess) {
//       await call.join(); // Our local app user can join and receive events
//       await call
//           .goLive(); // Allow others to see and join the call (exit backstage mode)
//     }

//     call.onPermissionRequest = (permissionRequest) {
//       call.grantPermissions(
//         userId: permissionRequest.user.id,
//         permissions: permissionRequest.permissions.toList(),
//       );
//     };

//     _callState = call.state.value;
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Audio Room: ${_callState.callId}'),
//         leading: IconButton(
//           onPressed: () async {
//             await call.leave();
//             Navigator.of(context).pop();
//           },
//           icon: const Icon(
//             Icons.close,
//           ),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         child: microphoneEnabled
//             ? const Icon(Icons.mic)
//             : const Icon(Icons.mic_off),
//         onPressed: () {
//           if (microphoneEnabled) {
//             call.setMicrophoneEnabled(enabled: false);
//             setState(() {
//               microphoneEnabled = false;
//             });
//           } else {
//             if (!call.hasPermission(CallPermission.sendAudio)) {
//               call.requestPermissions(
//                 [CallPermission.sendAudio],
//               );
//             }
//             call.setMicrophoneEnabled(enabled: true);
//             setState(() {
//               microphoneEnabled = true;
//             });
//           }
//         },
//       ),
//       body: StreamBuilder<CallState>(
//         initialData: _callState,
//         stream: call.state.valueStream,
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             return const Center(
//               child: Text('Cannot fetch call state.'),
//             );
//           }
//           if (snapshot.hasData && !snapshot.hasError) {
//             var callState = snapshot.data!;

//             return GridView.builder(
//               itemBuilder: (BuildContext context, int index) {
//                 return Align(
//                   widthFactor: 0.8,
//                   child: StreamCallParticipant(
//                     call: call,
//                     backgroundColor: Colors.transparent,
//                     participant: callState.callParticipants[index],
//                     showParticipantLabel: true,
//                     showConnectionQualityIndicator: false,
//                     userAvatarTheme: const StreamUserAvatarThemeData(
//                       constraints: BoxConstraints.expand(
//                         height: 100,
//                         width: 100,
//                       ),
//                     ),
//                   ),
//                 );
//               },
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 3,
//               ),
//               itemCount: callState.callParticipants.length,
//             );
//           }

//           return const Center(
//             child: CircularProgressIndicator(),
//           );
//         },
//       ),
//     );
//   }
// }
