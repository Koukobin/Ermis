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

// import 'dart:convert';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';

// class Signaling {
//   WebSocketChannel? _channel;
//   RTCPeerConnection? _peerConnection;
//   MediaStream? _localStream;
//   MediaStream? _remoteStream;
//   String _roomId = "defaultRoom"; // default room ID

//   static const String _serverUrl = "ws://localhost:8080"; // Replace with your server URL

//   // Signaling logic
//   Future<void> connect() async {
//     _channel = WebSocketChannel.connect(Uri.parse(_serverUrl));
//     _channel?.stream.listen((message) {
//       Map<String, dynamic> data = jsonDecode(message);
//       _handleSignalingMessage(data);
//     });
//   }

//   // Handle different types of signaling messages
//   void _handleSignalingMessage(Map<String, dynamic> data) {
//     switch (data['type']) {
//       case 'offer':
//         _handleOffer(data);
//         break;
//       case 'answer':
//         _handleAnswer(data);
//         break;
//       case 'ice-candidate':
//         _handleIceCandidate(data);
//         break;
//       default:
//         print("Unknown message type: ${data['type']}");
//     }
//   }

//   Future<void> _handleOffer(Map<String, dynamic> offerData) async {
//     var offer = RTCSessionDescription(offerData['sdp'], offerData['type']);
//     await _peerConnection?.setRemoteDescription(offer);
//     var answer = await _peerConnection!.createAnswer();
//     await _peerConnection!.setLocalDescription(answer);
//     _sendMessage({
//       'type': 'answer',
//       'sdp': answer.sdp,
//     });
//   }

//   Future<void> _handleAnswer(Map<String, dynamic> answerData) async {
//     var answer = RTCSessionDescription(answerData['sdp'], answerData['type']);
//     await _peerConnection?.setRemoteDescription(answer);
//   }

//   Future<void> _handleIceCandidate(Map<String, dynamic> candidateData) async {
//     var candidate = RTCIceCandidate(
//       candidateData['candidate'],
//       candidateData['sdpMid'],
//       candidateData['sdpMLineIndex'],
//     );
//     await _peerConnection?.addCandidate(candidate);
//   }

//   // Send signaling messages to the WebSocket server
//   void _sendMessage(Map<String, dynamic> message) {
//     _channel?.sink.add(jsonEncode(message));
//   }

//   // Create the WebRTC peer connection
//   Future<void> createPeerConnection0() async {
//     _peerConnection = await createPeerConnection({
//       'iceServers': [
//         {'urls': 'stun:stun.l.google.com:19302'}
//       ],
//     });

//     _peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
//       _sendMessage({
//         'type': 'ice-candidate',
//         'candidate': candidate.candidate,
//         'sdpMid': candidate.sdpMid,
//         'sdpMLineIndex': candidate.sdpMLineIndex,
//       });
//     };

//     _peerConnection?.onAddStream = (MediaStream stream) {
//       _remoteStream = stream;
//     };
//   }

//   // Start user media (camera and mic)
//   Future<void> openUserMedia(RTCVideoRenderer localRenderer) async {
//     var stream = await navigator.mediaDevices.getUserMedia({
//       'video': true,
//       'audio': true,
//     });
//     localRenderer.srcObject = stream;
//     _localStream = stream;
//   }

//   // Create an offer and send it to the server
//   Future<void> createOffer() async {
//     var offer = await _peerConnection!.createOffer();
//     await _peerConnection!.setLocalDescription(offer);
//     _sendMessage({
//       'type': 'offer',
//       'sdp': offer.sdp,
//     });
//   }

//   // Create an answer to an offer
//   Future<void> createAnswer() async {
//     var answer = await _peerConnection!.createAnswer();
//     await _peerConnection!.setLocalDescription(answer);
//     _sendMessage({
//       'type': 'answer',
//       'sdp': answer.sdp,
//     });
//   }

//   // Close the peer connection and stop media
//   Future<void> hangUp() async {
//     _localStream?.getTracks().forEach((track) {
//       track.stop();
//     });
//     _peerConnection?.close();
//     _localStream?.dispose();
//     _remoteStream?.dispose();
//   }
// }
