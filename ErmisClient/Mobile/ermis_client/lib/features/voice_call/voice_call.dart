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
import 'dart:math';
import 'dart:typed_data';

import 'package:ermis_client/core/extensions/iterable_extensions.dart';
import 'package:ermis_client/core/models/inet_socket_address.dart';
import 'package:ermis_client/core/models/member.dart';
import 'package:ermis_client/core/models/message_events.dart';
import 'package:ermis_client/core/networking/user_info_manager.dart';
import 'package:ermis_client/core/networking/voice_call_udp_socket.dart';
import 'package:ermis_client/core/widgets/user_profile.dart';
import 'package:ermis_client/core/util/dialogs_utils.dart';
import 'package:ermis_client/core/util/top_app_bar_utils.dart';
import 'package:ermis_client/mixins/event_bus_subscription_mixin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/event_bus/app_event_bus.dart';
import '../../core/data_sources/api_client.dart';
import '../../core/data/models/network/byte_buf.dart';
import '../../core/util/notifications_util.dart';
import '../../core/util/permissions.dart';
import '../../core/util/transitions_util.dart';

final VoiceCallUDPSocket _udpSocket = VoiceCallUDPSocket();

class VoiceCallThing {
  static void Function(VoiceCallIncomingEvent) startListeningForIncomingCalls(BuildContext context) {
    return (VoiceCallIncomingEvent event) {
      Member member = event.member;

      NotificationService.showVoiceCallNotification(
          icon: member.icon.profilePhoto,
          callerName: member.username,
          onAccept: () async {
            bool permission = await ligma(context);
            if (!permission) return;
            final int port = event.signallingPort;
            final Uint8List aesKey = event.aesKey;
            final int chatSessionID = event.chatSessionID;
            final int chatSessionIndex = event.chatSessionIndex;

            await _udpSocket.openSocket();

            navigateWithFade(
                context,
                VoiceCallScreen._(
                  chatSessionID: chatSessionID,
                  chatSessionIndex: chatSessionIndex,
                  otherIps: [],
                  member: member,
                  aesKey: aesKey,
                ));

            await Future.delayed(const Duration(seconds: 5));

            await _udpSocket.initialize(aesKey);
            _udpSocket.rawSecureSend(
              ByteBuf.smallBuffer()
                ..writeInt32(UserInfoManager.clientID)
                ..writeInt32(chatSessionID),
              UserInfoManager.serverInfo.address,
              port,
            );
          });
    };
  }

  static Future<bool> ligma(BuildContext context) async {
    (bool, List<Permission>?) result = await checkAndRequestPermissions([Permission.microphone, Permission.camera]);
    if (!result.$1) {
      for (Permission per in result.$2!) {
        showPermissionDeniedDialog(context, per);
      }
    }

    return result.$1;
  }

  static Future<void> initiateVoiceCall(
    BuildContext context, {
    required int chatSessionIndex,
    required int chatSessionID,
  }) async {
    bool permission = await ligma(context);
    if (!permission) return;

    Client.instance().commands.startVoiceCall(chatSessionIndex);

    final event = await AppEventBus.instance.on<StartVoiceCallResultEvent>().first;
    final int port = event.udpServerPort;
    final Uint8List aesKey = event.aesKey;

    await _udpSocket.openSocket();

    navigateWithFade(
        context,
        VoiceCallScreen._(
          chatSessionIndex: chatSessionIndex,
          chatSessionID: chatSessionID,
          otherIps: [],
          member: UserInfoManager.chatSessionIDSToChatSessions[chatSessionID]!.members[0],
          aesKey: aesKey,
        ));

    await Future.delayed(const Duration(seconds: 5));

    await _udpSocket.initialize(aesKey);
    _udpSocket.rawSecureSend(
      ByteBuf.smallBuffer()
        ..writeInt32(UserInfoManager.clientID)
        ..writeInt32(chatSessionID),
      UserInfoManager.serverInfo.address,
      port,
    );
  }
}

class VoiceCallScreen extends StatefulWidget {
  final int chatSessionID;
  final int chatSessionIndex;
  final List<JavaInetSocketAddress> otherIps;
  final Uint8List aesKey;
  final Member? member;
  const VoiceCallScreen._({
    super.key,
    required this.chatSessionID,
    required this.chatSessionIndex,
    required this.otherIps,
    required this.member,
    required this.aesKey,
  });

  @override
  State<VoiceCallScreen> createState() => VoiceCallScreenState();
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

class VoiceCallScreenState extends State<VoiceCallScreen> with EventBusSubscriptionMixin {
  final FlutterSoundPlayer _player = FlutterSoundPlayer()..openPlayer().then((player) {
  player!.startPlayerFromStream(
      codec: Codec.pcm16,
      sampleRate: 8000,
      numChannels: 1,
      bufferSize: 512,
      interleaved: true,
    );
  });

  final StreamController<Uint8List> _controller = StreamController<Uint8List>();
  
  double rms = 0.0;

  bool isMuted = false;
  bool isShowingVideo = false;

  CallStatus callStatus = CallStatus.calling;

  static const bool logInDetail = false && kDebugMode;

  Set<JavaInetSocketAddress> ips = {};

  @override
  void initState() {
    super.initState();

    ips.addAll(widget.otherIps);

    subscribe(AppEventBus.instance.on<MemberAddedToVoiceCalll>(), (event) async {
      // Ensure motherfucker added belongs to current chat session
      if (event.chatSessionID != widget.chatSessionID) return;

      if (logInDetail) {
        debugPrint("Received");
        debugPrint("Received");
        debugPrint("Received");
        debugPrint("Received");
        debugPrint("Received");
      }

      ips.add(event.socket);
    }, onDone: Navigator.of(context).pop);

    final FlutterSoundRecorder _recorder = FlutterSoundRecorder()..openRecorder().then((recorder) {
      recorder!.startRecorder(
        codec: Codec.pcm16,
        sampleRate: 8000,
        numChannels: 1,
        bufferSize: 512,
        toStream: _controller,
      );
    });

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (ips.isEmpty || !_udpSocket.isInitialized) return;

      _initiate();
      timer.cancel();
    });
  }

  Future<void> _initiate() async {
    subscribe(_udpSocket.stream, (Uint8List? data) async {
      if (data == null) return;

      if (logInDetail) {
        debugPrint("RETRIEVING DATA");
        debugPrint("RETRIEVING DATA");
        debugPrint("RETRIEVING DATA");
        debugPrint("RETRIEVING DATA");
        debugPrint("RETRIEVING DATA");
      }

      await _player.feedUint8FromStream(data);
      double rms = calculateRMS(data);
      if (logInDetail) debugPrint('RMS: $rms');
      setState(() {
        this.callStatus = CallStatus.active;
        this.rms = rms;
      });
    });

    _startAudioRecording();
  }

  double calculateRMS(Uint8List audioChunk) {
    if (audioChunk.isEmpty) {
      if (logInDetail) {
        debugPrint("Empty?");
      }

      return 0.0; // Return 0 for empty audio samples.
    }

    Int16List audioSamples = audioChunk.buffer.asInt16List();
    num sumOfSquares = audioSamples
        .map((int sample) => pow(sample, 2))
        .reduce((num a, num b) => a + b);
    return sqrt(sumOfSquares / audioSamples.length);
  }

  Future<void> _startAudioRecording() async {
    isMuted = false;
    _listenAndSendAudio();
  }

  // Listen to the audio file and send it to the server in chunks
  Future<void> _listenAndSendAudio() async {
    if (logInDetail) {
      debugPrint("LISTENING");
      debugPrint("LISTENING");
      debugPrint("LISTENING");
      debugPrint("LISTENING");
      debugPrint("LISTENING");
    }

    _controller.stream.listen((Uint8List data) {
      if (logInDetail) debugPrint(ips.hashCodeDistinct().toString());

      for (JavaInetSocketAddress socket in ips.hashCodeDistinct()) {
        // print("Audio data sent: $data");
        _udpSocket.sendSecureVoice(data, socket);
      }
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
                  UserProfilePhoto(
                    radius: 100,
                    profileBytes:
                        widget.member?.icon.profilePhoto ?? Uint8List(0),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 100,
                      child: ListView.builder(
                        itemCount: ips.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Text(ips.toList()[index].toString());
                        },
                      ),
                    ),
                  ),
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
    setState(() {
      callStatus = CallStatus.ended;
    });
    _udpSocket.close(ips);
    Navigator.pop(context);
  }
}
