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

// import 'package:ermis_client/client/client.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:permission_handler/permission_handler.dart';

// import 'dart:async';

// class WebRTCService {
//   static final apeerConnection = <int, RTCPeerConnection>{};
//   static final alocalStream = <int, MediaStream>{};

//   static Future<void> startCall(int chatSessionID) async {
//     // Request microphone and camera permissions
//     await _requestPermissions();

//     // Create local media stream
//     MediaStream localStream = await navigator.mediaDevices.getUserMedia({
//       'audio': true,
//       'video': false, // Start with voice only
//     });

//     // Save the local stream
//     alocalStream[chatSessionID] = localStream;

//     // Create peer connection for the call
//     RTCPeerConnection peerConnection = await createPeerConnection({
//       'iceServers': [
//         {'urls': 'stun:stun.l.google.com:19302'}
//       ]
//     });

//     // Add tracks to the peer connection
//     localStream.getTracks().forEach((track) {
//       peerConnection.addTrack(track, localStream);
//     });

//     // Save peer connection
//     apeerConnection[chatSessionID] = peerConnection;

//     // Handle incoming ICE candidates (for connection setup)
//     peerConnection.onIceCandidate = (candidate) {
//       if (candidate != null) {
//         // Send candidate to signaling server
//         print('New ICE candidate: ${candidate.candidate}');
//       }
//     };

//     // Handle stream events (incoming remote stream)
//     peerConnection.onAddStream = (stream) {
//       print('New stream added: ${stream.id}');
//       // Handle the remote stream (display video/audio)
//     };

//     // Offer creation or signaling logic (you need signaling to connect peers)
//     RTCSessionDescription description = await peerConnection.createOffer();
//     await peerConnection.setLocalDescription(description);

//     // Send offer to signaling server
//     SignalingClient.
//   }

//   static Future<void> endCall(int chatSessionID) async {
//     RTCPeerConnection? peerConnection = apeerConnection[chatSessionID];
//     if (peerConnection != null) {
//       await peerConnection.close();
//     }

//     MediaStream? localStream = alocalStream[chatSessionID];
//     localStream?.getTracks().forEach((track) {
//       track.stop();
//     });

//     apeerConnection.remove(chatSessionID);
//     alocalStream.remove(chatSessionID);
//   }

  

//   static Future<void> _requestPermissions() async {
//     // Request microphone permissions
//     await Permission.microphone.request();
//     // Optionally, request camera permissions if you plan to support video
//     await Permission.camera.request();
//   }
// }

// class SignalingClient {
//   static final WebSocketChannel channel;

//   static void sendOffer(String chatSessionID, RTCSessionDescription offer) {
//     final message = {
//       'type': 'offer',
//       'chatSessionID': chatSessionID,
//       'sdp': offer.sdp,
//     };
//     channel.sink.add(message);
//   }

//  static  void sendAnswer(String chatSessionID, RTCSessionDescription answer) {
//     final message = {
//       'type': 'answer',
//       'chatSessionID': chatSessionID,
//       'sdp': answer.sdp,
//     };
//     channel.sink.add(message);
//   }

//   static void sendCandidate(String chatSessionID, RTCIceCandidate candidate) {
//     final message = {
//       'type': 'candidate',
//       'chatSessionID': chatSessionID,
//       'candidate': candidate.candidate,
//     };
//     channel.sink.add(message);
//   }

//   static void setupSignalingListener() {
//   messages.listen((message) {
//     final data = message as Map<String, dynamic>;
//     final chatSessionID = data['chatSessionID'];

//     if (data['type'] == 'offer') {
//       // Handle received offer
//       RTCSessionDescription offer = RTCSessionDescription(data['sdp'], 'offer');
//       _handleOffer(chatSessionID, offer);
//     } else if (data['type'] == 'answer') {
//       // Handle received answer
//       RTCSessionDescription answer = RTCSessionDescription(data['sdp'], 'answer');
//       _handleAnswer(chatSessionID, answer);
//     } else if (data['type'] == 'candidate') {
//       // Handle received ICE candidate
//       RTCIceCandidate candidate = RTCIceCandidate(data['candidate'], '', 0);
//       _handleCandidate(chatSessionID, candidate);
//     }
//   });
// }

//   static  Stream<dynamic> get messages => channel.stream;
// }
