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

// import 'package:flutter/foundation.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';

// typedef void StreamStateCallback(MediaStream stream);

// class Signaling {
//   Map<String, dynamic> configuration = {
//     'iceServers': [
//       {
//         'urls': [
//           'stun:stun1.l.google.com:19302',
//           'stun:stun2.l.google.com:19302'
//         ]
//       }
//     ]
//   };

//   RTCPeerConnection? peerConnection;
//   MediaStream? localStream;
//   MediaStream? remoteStream;
//   String? roomId;
//   String? currentRoomText;
//   StreamStateCallback? onAddRemoteStream;
//   WebSocketChannel channel = WebSocketChannel.connect(Uri.parse("ws://localhost:8080"));
//   String myClientId = kIsWeb ? "web" : "mobile"; // Generate unique client ID

//   Future<String> createRoom(RTCVideoRenderer remoteRenderer) async {
//   print('Create PeerConnection with configuration: $configuration');

//   peerConnection = await createPeerConnection(configuration); // Initialize peerConnection
//   registerPeerConnectionListeners();

//   localStream?.getTracks().forEach((track) {
//     peerConnection?.addTrack(track, localStream!);
//   });

//   // Generate a unique room ID (e.g., using UUID)
//   String roomId = DateTime.now().second.toString(); // For simplicity

//   // Collect ICE candidates
//   peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
//     print('Got candidate: ${candidate.toMap()}');
//     channel.sink.add(jsonEncode({
//       'type': 'candidate',
//       'candidate': candidate.toMap(),
//       'from': kIsWeb ? "web" : "mobile", // Replace with your client ID
//       'to': kIsWeb ? "web" : "mobile" // Will be the other client's ID once known.
//     }));
//   };

//   // Create offer
//   RTCSessionDescription offer = await peerConnection!.createOffer();
//   await peerConnection!.setLocalDescription(offer);
//   print('Created offer: $offer');

//   // Send offer to the server
//   channel.sink.add(jsonEncode({
//     'type': 'offer',
//     'offer': offer.toMap(),
//     'from': kIsWeb ? "web" : "mobile", // Replace with your client ID
//     'to': kIsWeb ? "web" : "mobile", //Will be the other client's id once known.
//     'roomId': roomId,
//   }));

//   peerConnection?.onTrack = (RTCTrackEvent event) {
//     print('Got remote track: ${event.streams[0]}');

//     event.streams[0].getTracks().forEach((track) {
//       print('Add a track to the remoteStream $track');
//       remoteStream?.addTrack(track);
//     });
//   };

//   // Listen for messages from the server
//   channel.stream.listen((message) {
//     final data = jsonDecode(message);
//     switch (data['type']) {
//       case 'answer':
//         final answer = RTCSessionDescription(
//           data['answer']['sdp'],
//           data['answer']['type'],
//         );
//         peerConnection?.setRemoteDescription(answer);
//         break;
//       case 'candidate':
//         final candidate = RTCIceCandidate(
//           data['candidate']['candidate'],
//           data['candidate']['sdpMid'],
//           data['candidate']['sdpMLineIndex'],
//         );
//         peerConnection?.addCandidate(candidate);
//         break;
//       default:
//         print('Received unknown message type: ${data['type']}');
//     }
//   });

//   return roomId;
//   }

//   Future<void> joinRoom(String roomId, RTCVideoRenderer remoteVideo) async {
//     print('Create PeerConnection with configuration: $configuration');

//     registerPeerConnectionListeners();

//     localStream?.getTracks().forEach((track) {
//       peerConnection?.addTrack(track, localStream!);
//     });

//     // Collect ICE candidates
//     peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
//       print('Got candidate: ${candidate.toMap()}');
//       channel.sink.add(jsonEncode({
//         'type': 'candidate',
//         'candidate': candidate.toMap(),
//         'from': kIsWeb ? "web" : "mobile", // Replace with your client ID
//         'to': kIsWeb ? "web" : "mobile" //Will be the other client's id once known.
//       }));
//     };

//     // Listen for messages from the server
//     channel.stream.listen((message) async {
//         final data = jsonDecode(message);
//         switch (data['type']) {
//             case 'offer':
//                 final offer = RTCSessionDescription(
//                     data['offer']['sdp'],
//                     data['offer']['type'],
//                 );
//                 peerConnection?.setRemoteDescription(offer);
//                 RTCSessionDescription answer = await peerConnection!.createAnswer();
//                 await peerConnection!.setLocalDescription(answer);
//                 channel.sink.add(jsonEncode({
//                     'type': 'answer',
//                     'answer': answer.toMap(),
//                     'from': kIsWeb ? "web" : "mobile",
//                     'to': kIsWeb ? "web" : "mobile",
//                     'roomId': roomId,
//                 }));
//                 break;
//             case 'candidate':
//                 final candidate = RTCIceCandidate(
//                     data['candidate']['candidate'],
//                     data['candidate']['sdpMid'],
//                     data['candidate']['sdpMLineIndex'],
//                 );
//                 peerConnection?.addCandidate(candidate);
//                 break;
//             default:
//                 print('Received unknown message type: ${data['type']}');
//         }
//     });
//   }

//   Future<void> openUserMedia(
//     RTCVideoRenderer localVideo,
//     RTCVideoRenderer remoteVideo,
//   ) async {
//     var stream = await navigator.mediaDevices
//         .getUserMedia({'video': true, 'audio': false});

//     localVideo.srcObject = stream;
//     localStream = stream;

//     remoteVideo.srcObject = await createLocalMediaStream('key');
//   }

//   void registerPeerConnectionListeners() {
//     peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
//       print('ICE gathering state changed: $state');
//     };

//     peerConnection?.onConnectionState = (RTCPeerConnectionState state) {
//       print('Connection state change: $state');
//     };

//     peerConnection?.onSignalingState = (RTCSignalingState state) {
//       print('Signaling state change: $state');
//     };

//     peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
//       print('ICE connection state change: $state');
//     };

//     peerConnection?.onAddStream = (MediaStream stream) {
//       print("Add remote stream");
//       onAddRemoteStream?.call(stream);
//       remoteStream = stream;
//     };
//   }
// }