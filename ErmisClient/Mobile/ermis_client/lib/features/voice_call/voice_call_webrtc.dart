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
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:ermis_client/core/models/member.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/io.dart';

import '../../core/data_sources/api_client.dart';
import '../../core/event_bus/app_event_bus.dart';
import '../../core/models/message_events.dart';
import '../../core/networking/user_info_manager.dart';
import '../../core/util/top_app_bar_utils.dart';
import '../../core/widgets/profile_photos/user_profile_photo.dart';
import '../../theme/app_colors.dart';

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
  State<StatefulWidget> createState() => _VoiceCallWebrtcState();
}

class _VoiceCallWebrtcState extends State<VoiceCallWebrtc> {
  /// STUN configuration for ICE candidates.
  static const Map<String, dynamic> configuration = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'}
    ]
  };

  IOWebSocketChannel? channel;
  MediaStream? localStream;
  RTCPeerConnection? peerConnection;

  RTCVideoRenderer? remoteRenderer;
  RTCVideoRenderer? localRenderer;

  bool isSpeakerPhoneEnabled = false;
  bool isShowingVideo = false;
  bool isMuted = false;
  bool showEndToEndEncryptedIndicator = false;

  CallStatus callStatus = CallStatus.connecting;
  double rms = 0.0;

  @override
  void initState() {
    super.initState();
    
    Future(() async {
      final client = HttpClient(context: SecurityContext(withTrustedRoots: false));
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;

      Client.instance().commands.fetchSignallingServerPort();
      SignallingServerPortEvent e = await AppEventBus.instance.on<SignallingServerPortEvent>().first;

      // Create a WebSocket to your signaling server.
      channel = IOWebSocketChannel.connect(
        Uri.parse('wss://${UserInfoManager.serverInfo.address!.host}:${e.port}/ws'),
        customClient: client,
      );

      await _startListeningForCalls();
      _startOrAcceptVoiceCall();
    });

    Timer.periodic(const Duration(seconds: 5), (timer) async {
      // Show end-to-end encrypted indicator for only five seconds,
      // whereas call status for 10 seconds.
      if (!showEndToEndEncryptedIndicator) {
        await Future.delayed(const Duration(seconds: 5));
      }

      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        showEndToEndEncryptedIndicator = !showEndToEndEncryptedIndicator;
      });
    });
  }

  /// Helper function to send JSON messages over the WebSocket.
  void sendChannelMessage(Map<String, dynamic> message) {
    channel!.sink.add(jsonEncode(message));
  }

  Future<void> _startListeningForCalls() async {
    remoteRenderer = RTCVideoRenderer();
    await remoteRenderer!.initialize();

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
                if (event.track.kind == 'video') {
                  // event.streams might contain the remote stream
                  if (event.streams.isNotEmpty) {
                    setState(() {
                      remoteRenderer!.srcObject = event.streams[0];
                    });
                  }
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
      'video': true,
      'audio': true,
    });

    localRenderer = RTCVideoRenderer();
    await localRenderer!.initialize();
    localRenderer!.srcObject = localStream;

    localStream!.getVideoTracks()[0].enabled = isShowingVideo;

    print("Local media stream obtained: ${localStream!.id}");

    Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (localStream == null) return;

      // Ensure local stream audio tracks are up to date
      localStream!.getAudioTracks().forEach((track) {
        track.enableSpeakerphone(isSpeakerPhoneEnabled);
      });

      double totalRMS = 0;

      if (localStream!.getAudioTracks().length > 1) {
        setState(() {
          callStatus = CallStatus.active;
        });
      }

      for (final track in localStream!.getAudioTracks()) {
        // ByteBuffer currentFrame = await track.captureFrame();
        // totalRMS += calculateRMS(currentFrame.asUint8List());
      }

      setState(() {
        rms = totalRMS;
      });
    });
  }

  Future<void> _startOrAcceptVoiceCall() async {
    if (!widget.isInitiator) {
      Client.instance().commands.acceptVoiceCall(widget.chatSessionIndex);
      return;
    }

    Client.instance().commands.startVoiceCall(widget.chatSessionIndex);

    setState(() {
      callStatus = CallStatus.calling;
    });

    VoiceCallAcceptedEvent event = await AppEventBus.instance.on<VoiceCallAcceptedEvent>().first;
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
      if (event.track.kind == 'video') {
        // event.streams might contain the remote stream
        if (event.streams.isNotEmpty) {
          setState(() {
            remoteRenderer!.srcObject = event.streams[0];
          });
        }
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

  AnimatedSwitcher buildCallStatusAndEndToEndEncryptedIndicator() {
    return AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        child: showEndToEndEncryptedIndicator
            ? const EndToEndEncryptedIndicator(
                key: ValueKey<bool>(false),
              )
            : Text(
                key: const ValueKey<bool>(true),
                callStatus.text,
              ),
        transitionBuilder: (Widget child, Animation<double> animation) {
          final Animation<double> fadeOutAnimation = Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
            ),
          );

          // Slide in animation for the incoming widget
          final Animation<Offset> slideInAnimation = Tween<Offset>(
            begin: const Offset(0.0, 1.0), // Start from the bottom
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
            ),
          );

          if (showEndToEndEncryptedIndicator ==
              (child.key as ValueKey<bool>).value) {
            return FadeTransition(
              opacity: fadeOutAnimation,
              child: child,
            );
          }
          return SlideTransition(
            position: slideInAnimation,
            child: FadeTransition(
              // Apply fade in for smoothness
              opacity: animation,
              child: child,
            ),
          );
        });
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
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(
                    "ChatSession: ${widget.chatSessionID}",
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  buildCallStatusAndEndToEndEncryptedIndicator(),
                ],
              ),
              // Stack(
              //   alignment: Alignment.center,
              //   children: [
              //     AnimatedSize(
              //       duration: const Duration(milliseconds: 100),
              //       child: CircleAvatar(
              //         radius: (100 + rms) >= 200 ? 200 : 100 + rms,
              //         backgroundColor: const Color.fromRGBO(158, 158, 158, 0.4),
              //       ),
              //     ),
              //   ],
              // ),
              Expanded(
                child: Stack(
                  children: [
                    remoteRenderer?.srcObject != null && (remoteRenderer?.muted ?? false)
                        ? Center(
                            child: Container(
                              width: 375,
                              height: 425,
                              padding: const EdgeInsets.all(8.0),
                              child: ClipRRect(
                                borderRadius: const BorderRadius.all(Radius.circular(12)),
                                child: RTCVideoView(
                                  remoteRenderer!,
                                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                                  mirror: true, // Enable if you are using the front-facing camera.
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: UserProfilePhoto(
                              radius: 100,
                              profileBytes: widget.member.icon.profilePhoto,
                            ),
                          ),
                    localRenderer?.srcObject != null && isShowingVideo ? Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        width: 150,
                        height: 200,
                        padding: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(12)),
                          child: RTCVideoView(
                            localRenderer!,
                            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                            mirror: true, // Enable if you are using the front-facing camera.
                          ),
                        ),
                      ),
                    ) : const SizedBox.shrink(),
                  ],
                ),
              ),
              Container(
                height: 120.0,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20.0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: Icon(
                        isSpeakerPhoneEnabled ? Icons.volume_up : Icons.volume_off,
                        size: 40,
                        color: isSpeakerPhoneEnabled ? Colors.green : Colors.red,
                      ),
                      onPressed: () {
                        setState(() {
                          isSpeakerPhoneEnabled = !isSpeakerPhoneEnabled;
                        });
                
                        void updateEnabled(MediaStreamTrack track) {
                          track.enableSpeakerphone(isSpeakerPhoneEnabled);
                        }
                
                        localStream!.getAudioTracks().forEach(updateEnabled);
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        isShowingVideo ? Icons.videocam : Icons.videocam_off,
                        size: 40,
                        color: isShowingVideo ? Colors.green : Colors.red,
                      ),
                      onPressed: () {
                        setState(() {
                          isShowingVideo = !isShowingVideo;
                        });
                
                        localStream!.getVideoTracks()[0].enabled = isShowingVideo;
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        isMuted ? Icons.mic_off : Icons.mic,
                        size: 40,
                        color: isMuted ? Colors.red : Colors.green,
                      ),
                      onPressed: () {
                        setState(() {
                          isMuted = !isMuted;
                        });
                
                        localStream!.getAudioTracks()[0].enabled = !isMuted;
                      },
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
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _endCall();
    super.dispose();
  }

  Future<void> _endCall() async {
    setState(() {
      callStatus = CallStatus.ended;
    });

    Navigator.pop(context);

    await channel?.innerWebSocket?.close();
    await localStream?.dispose();
    await peerConnection?.close();
    await remoteRenderer?.dispose();
    await localRenderer?.dispose();

    channel = null;
    localStream = null;
    peerConnection = null;
    remoteRenderer = null;
    localRenderer = null;
  }
}

class EndToEndEncryptedIndicator extends StatelessWidget {
  const EndToEndEncryptedIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.lock,
          size: 16,
          color: appColors.primaryColor,
        ),
        const SizedBox(width: 4.0),
        Text(
          'End-to-end encrypted',
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
