
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:ermis_client/core/models/member.dart';
import 'package:ermis_client/mixins/event_bus_subscription_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/io.dart';

import '../../core/data_sources/api_client.dart';
import '../../core/event_bus/app_event_bus.dart';
import '../../core/models/message_events.dart';
import '../../core/networking/user_info_manager.dart';
import '../../core/util/dialogs_utils.dart';
import '../../core/util/top_app_bar_utils.dart';
import '../../core/widgets/profile_photos/user_profile_photo.dart';

enum CallStatus {
  connecting('Connecting...'),
  calling('Calling...'),
  active('Active...'),
  ringing('Ringing...'),
  ended('Ended');

  final String text;
  const CallStatus(this.text);
}

class VoiceCallWebrtc extends StatefulWidget {
  final int chatSessionID;
  final int chatSessionIndex;
  final Member member;
  final bool isInitiator;

  const VoiceCallWebrtc({
    super.key,
    required this.chatSessionID,
    required this.chatSessionIndex,
    required this.member,
    required this.isInitiator,
  });

  @override
  State<StatefulWidget> createState() => VoiceCallWebrtcState();
}

class VoiceCallWebrtcState extends State<VoiceCallWebrtc> with EventBusSubscriptionMixin {
  /// STUN configuration for ICE candidates.
  static const Map<String, dynamic> configuration = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'}
    ]
  };

  IOWebSocketChannel? channel;
  MediaStream? localStream;
  RTCPeerConnection? peerConnection;

  bool isShowingVideo = false;
  bool isMuted = false;

  CallStatus callStatus = CallStatus.calling;
  double rms = 0.0;

  @override
  void initState() {
    super.initState();
    
    Future(() async {
      final client = HttpClient(context: SecurityContext(withTrustedRoots: false));
      client.badCertificateCallback =  (X509Certificate cert, String host, int port) => true;

      Client.instance().commands.fetchSignallingServerPort();
      SignallingServerPortEvent e = await AppEventBus.instance.on<SignallingServerPortEvent>().first;

      // Create a WebSocket to your signaling server.
      channel = IOWebSocketChannel.connect(
        Uri.parse('wss://${UserInfoManager.serverInfo.address.host}:${e.port}/ws'),
        customClient: client,
      );

      listen();
    });

    _bruh();
  }

  /// Helper function to send JSON messages over the WebSocket.
  void sendChannelMessage(Map<String, dynamic> message) {
    channel!.sink.add(jsonEncode(message));
  }

  void listen() async {
    // Listen for incoming signaling messages.
    channel!.stream.listen((data) async {
      final message = jsonDecode(data);
      print("Received message: $message");
      switch (message['type']) {
        case "offer":
          {
            // When an offer is received, create a peer connection if one doesn't exist.
            if (peerConnection == null) {
              peerConnection = await createPeerConnection(configuration);
              // If a local stream already exists, add all its tracks to the connection.
              if (localStream != null) {
                localStream!.getTracks().forEach((track) {
                  peerConnection!.addTrack(track, localStream!);
                });
              }
              // Listen for ICE candidates and send them.
              peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
                if (candidate.candidate != null &&
                    candidate.candidate!.isNotEmpty) {
                  sendChannelMessage({
                    'type': 'candidate',
                    'data': candidate.toMap(),
                  });
                }
              };
              // Handle remote tracks.
              peerConnection!.onTrack = (RTCTrackEvent event) {
                if (event.streams.isNotEmpty) {
                  print("Remote stream received: ${event.streams[0].id}");
                }
              };
            }
            // Set the offer as remote description.
            RTCSessionDescription remoteOffer = RTCSessionDescription(
              message['data']['sdp'],
              message['data']['type'],
            );
            await peerConnection!.setRemoteDescription(remoteOffer);
            // Create, set, and send the answer.
            RTCSessionDescription answer = await peerConnection!.createAnswer();
            await peerConnection!.setLocalDescription(answer);
            sendChannelMessage({
              'type': 'answer',
              'data': answer.toMap(),
            });
            break;
          }
        case "answer":
          {
            if (peerConnection != null) {
              RTCSessionDescription remoteAnswer = RTCSessionDescription(
                message['data']['sdp'],
                message['data']['type'],
              );
              await peerConnection!.setRemoteDescription(remoteAnswer);
            }
            break;
          }
        case "candidate":
          {
            if (peerConnection != null) {
              final candidateMap = message['data'];
              RTCIceCandidate candidate = RTCIceCandidate(
                candidateMap['candidate'],
                candidateMap['sdpMid'],
                candidateMap['sdpMLineIndex'],
              );
              await peerConnection!.addCandidate(candidate);
            }
            break;
          }
        default:
          {
            print("Unknown message type: ${message['type']}");
          }
      }
    });

    // Wait until the WebSocket connection opens.
    await Future.delayed(const Duration(seconds: 1)); // Give a brief delay to ensure connection is open.
    print("Signaling WebSocket connected.");

    // Obtain the local media stream (audio and video).
    localStream = await navigator.mediaDevices.getUserMedia({
      'video': false,
      'audio': true,
    });
    print("Local media stream obtained: ${localStream!.id}");
  }

  Future<void> _bruh() async {
    if (!widget.isInitiator) {
      Client.instance().commands.acceptVoiceCall(widget.chatSessionIndex);
      return;
    }

    Client.instance().commands.startVoiceCall(widget.chatSessionIndex);

    subscribe(AppEventBus.instance.on<VoiceCallAcceptedEvent>(), (event) async {
      peerConnection = await createPeerConnection(configuration);

      // Add local media tracks.
      localStream!.getTracks().forEach((track) {
        peerConnection!.addTrack(track, localStream!);
      });

      // Set up ICE candidates and track handling.
      peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        if (candidate.candidate != null && candidate.candidate!.isNotEmpty) {
          sendChannelMessage({
            'type': 'candidate',
            'data': candidate.toMap(),
          });
        }
      };

      peerConnection!.onTrack = (RTCTrackEvent event) {
        if (event.streams.isNotEmpty) {
          print("Remote stream received: ${event.streams[0].id}");
        }
      };

      peerConnection!.onRenegotiationNeeded = () async {
        try {
          RTCSessionDescription newOffer = await peerConnection!.createOffer();
          await peerConnection!.setLocalDescription(newOffer);
          sendChannelMessage({'type': 'offer', 'data': newOffer.toMap()});
        } catch (err) {
          print("Renegotiation failed: $err");
        }
      };

      // Create the offer and send it over the signaling channel.
      RTCSessionDescription offer = await peerConnection!.createOffer();
      await peerConnection!.setLocalDescription(offer);
      sendChannelMessage({
        'type': 'offer',
        'data': offer.toMap(),
      });
      print("Offer sent: ${offer.sdp}");

      Timer.periodic(const Duration(seconds: 1), (timer) async {
        if (!mounted) timer.cancel();
        if (localStream == null) return;

        double totalRMS = 0;

        for (final track in localStream!.getAudioTracks()) {
          callStatus = CallStatus.active;
          // ByteBuffer currentFrame = await track.captureFrame();
          // totalRMS += calculateRMS(currentFrame.asUint8List());
        }

        setState(() {
          rms = totalRMS;
        });
      });
    });
  }

  double calculateRMS(Uint8List audioChunk) {
    if (audioChunk.isEmpty) {
      return 0.0; // Return 0 for empty audio samples.
    }

    Int16List audioSamples = audioChunk.buffer.asInt16List();
    num sumOfSquares = audioSamples
        .map((int sample) => pow(sample, 2))
        .reduce((num a, num b) => a + b);
    return sqrt(sumOfSquares / audioSamples.length);
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
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(callStatus.text)
                ],
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedSize(
                    duration: const Duration(milliseconds: 100),
                    child: CircleAvatar(
                      radius: (100 + rms) >= 200 ? 200 : 100 + rms,
                      backgroundColor: const Color.fromRGBO(158, 158, 158, 0.4),
                    ),
                  ),
                  UserProfilePhoto(
                    radius: 100,
                    profileBytes: widget.member.icon.profilePhoto,
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

    Navigator.pop(context);

    await channel?.innerWebSocket?.close();
    await peerConnection?.close();

    channel = null;
    localStream = null;
    peerConnection = null;
  }
}
