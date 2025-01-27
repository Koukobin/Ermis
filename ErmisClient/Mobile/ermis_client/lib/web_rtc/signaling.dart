import 'dart:convert';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// typedef StreamStateCallback = void Function(MediaStream stream);

class Signaling {
  // late WebSocketChannel channel;
  // Map<String, dynamic> configuration = {
  //   'iceServers': [
  //     {
  //       'urls': [
  //         'stun:stun1.l.google.com:19302',
  //         'stun:stun2.l.google.com:19302'
  //       ]
  //     }
  //   ]
  // };

  // RTCPeerConnection? peerConnection;
  // MediaStream? localStream;
  // MediaStream? remoteStream;
  // String? roomId;
  // StreamStateCallback? onAddRemoteStream;

  // Signaling() {
  //   // Initialize the WebSocket connection
  //   connectToSignalingServer();
  // }

  // void connectToSignalingServer() {
  //   channel = WebSocketChannel.connect(Uri.parse('ws://localhost:8085/ws'));
  //   channel.stream.listen((message) {
  //     final data = jsonDecode(message);
  //     print("DATA");
  //     if (data['type'] == 'offer') {
  //       // Received offer
  //       handleOffer(data);
  //       print("Offer");
  //     } else if (data['type'] == 'answer') {
  //       // Received answer
  //       handleAnswer(data);
  //       print("Answer");
  //     } else if (data['type'] == 'candidate') {
  //       // Received ICE candidate
  //       handleCandidate(data);
  //       print("Candidate");
  //     }
  //   });
  // }

  // Future<String> createRoom() async {
  //   peerConnection = await createPeerConnection(configuration);
  //   registerPeerConnectionListeners();

  //   localStream = await navigator.mediaDevices.getUserMedia({
  //     'video': true,
  //     'audio': true,
  //   });
  //   localStream?.getTracks().forEach((track) {
  //     peerConnection?.addTrack(track, localStream!);
  //   });

  //   // var roomRef = {
  //   //   'type': 'createRoom',
  //   // };
  //   // channel.sink.add(jsonEncode(roomRef));

  //   RTCSessionDescription offer = await peerConnection!.createOffer();
  //   await peerConnection!.setLocalDescription(offer);
  //   // roomId = offer.sdp; // Set a unique room ID
  //   roomId = "5";

  //   // Send the offer to the signaling server
  //   channel.sink.add(jsonEncode({
  //     'type': 'offer',
  //     'sdp': offer.sdp,
  //     'roomId': roomId,
  //   }));

  //   return roomId!;
  // }

  // Future<void> joinRoom(String roomId) async {
  //   this.roomId = roomId;
  //   peerConnection = await createPeerConnection(configuration);
  //   registerPeerConnectionListeners();

  //   localStream = await navigator.mediaDevices.getUserMedia({
  //     'video': true,
  //     'audio': true,
  //   });
  //   localStream?.getTracks().forEach((track) {
  //     peerConnection?.addTrack(track, localStream!);
  //   });

  //   channel.sink.add(jsonEncode({
  //     'type': 'joinRoom',
  //     'roomId': roomId,
  //   }));

  //   // Handle the offer from the signaling server
  //   channel.stream.listen((message) {
  //     final data = jsonDecode(message);
  //     if (data['type'] == 'offer') {
  //       handleOffer(data);
  //     }
  //   });
  // }

  // Future<void> handleOffer(Map<String, dynamic> data) async {
  //   RTCSessionDescription offer = RTCSessionDescription(data['sdp'], 'offer');
  //   await peerConnection?.setRemoteDescription(offer);

  //   RTCSessionDescription answer = await peerConnection!.createAnswer();
  //   await peerConnection!.setLocalDescription(answer);

  //   channel.sink.add(jsonEncode({
  //     'type': 'answer',
  //     'sdp': answer.sdp,
  //     'roomId': roomId,
  //   }));
  // }

  // Future<void> handleAnswer(Map<String, dynamic> data) async {
  //   RTCSessionDescription answer = RTCSessionDescription(data['sdp'], 'answer');
  //   await peerConnection?.setRemoteDescription(answer);
  // }

  // Future<void> handleCandidate(Map<String, dynamic> data) async {
  //   RTCIceCandidate candidate = RTCIceCandidate(
  //       data['candidate'], data['sdpMid'], data['sdpMLineIndex']);
  //   peerConnection?.addCandidate(candidate);
  // }

  // Future<void> openUserMedia(
  //     RTCVideoRenderer localVideo, RTCVideoRenderer remoteVideo) async {
  //   localStream = await navigator.mediaDevices
  //       .getUserMedia({'video': true, 'audio': true});
  //   localVideo.srcObject = localStream;

  //   remoteStream = await createLocalMediaStream('remote');
  //   remoteVideo.srcObject = remoteStream;
  // }

  // Future<void> hangUp(RTCVideoRenderer localVideo) async {
  //   localStream?.getTracks().forEach((track) {
  //     track.stop();
  //   });
  //   peerConnection?.close();
  //   localStream?.dispose();
  //   remoteStream?.dispose();
  // }

  // void registerPeerConnectionListeners() {
  //   peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
  //     print('ICE gathering state changed: $state');
  //   };

  //   peerConnection?.onConnectionState = (RTCPeerConnectionState state) {
  //     print('Connection state change: $state');
  //   };

  //   peerConnection?.onSignalingState = (RTCSignalingState state) {
  //     print('Signaling state change: $state');
  //   };

  //   peerConnection?.onIceConnectionState = (RTCIceConnectionState state) {
  //     print('ICE connection state change: $state');
  //   };

  //   peerConnection?.onAddStream = (MediaStream stream) {
  //     print('Add remote stream');
  //     onAddRemoteStream?.call(stream);
  //     remoteStream = stream;
  //   };
  // }

  // void sendMessage(Map<String, dynamic> message) {
  //   channel.sink.add(jsonEncode(message));
  // }
}
