// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'signaling.dart';

// class VoiceCallApp extends StatefulWidget {
//   @override
//   _VoiceCallAppState createState() => _VoiceCallAppState();
// }

// class _VoiceCallAppState extends State<VoiceCallApp> {
//   RTCPeerConnection? _peerConnection;
//   MediaStream? _localStream;
//   final _localRenderer = RTCVideoRenderer();

//   @override
//   void initState() {
//     super.initState();
//     _initialize();
//   }

//   // Initialize WebRTC and media stream
//   Future<void> _initialize() async {
//     await _localRenderer.initialize();
//     await _setupPeerConnection();
//     await _startLocalAudio();
//   }

//   // Setup the peer connection with STUN server
//   Future<void> _setupPeerConnection() async {
//     final Map<String, dynamic> configuration = {
//       'iceServers': [
//         {'url': 'stun:stun.l.google.com:19302'},
//       ],
//       'sdpSemantics': 'unified-plan',
//     };

//     try {
//       _peerConnection = await createPeerConnection(configuration);
//       _peerConnection!.onIceCandidate = (candidate) async {
//         print("ICE Candidate: ${jsonEncode(candidate.toMap())}");
//         // await _sendSignal({'candidate': candidate.toMap()});
//       };
//       _peerConnection!.onAddStream = (stream) {
//         setState(() {
//           _localStream = stream;
//         });
//       };
//     } catch (e) {
//       print("Error setting up peer connection: $e");
//     }
//   }

//   // Start capturing local audio
//   Future<void> _startLocalAudio() async {
//     try {
//       final stream = await navigator.mediaDevices.getUserMedia({'audio': true, 'video': false});
//       _localStream = stream;

//       for (var track in _localStream!.getTracks()) {
//         _peerConnection!.addTrack(track, _localStream!);
//       }
//     } catch (e) {
//       print("Error accessing media devices: $e");
//     }
//   }

//   // Create an offer to start the call
//   Future<void> _createOffer() async {
//     try {
//       RTCSessionDescription offer = await _peerConnection!.createOffer();
//       await _peerConnection!.setLocalDescription(offer);
//       // await _sendSignal({'offer': offer.toMap()});
//     } catch (e) {
//       print("Error creating offer: $e");
//     }
//   }

//   // Set remote session description (offer, answer, or candidate)
//   // Future<void> _setRemoteDescription(Map<String, dynamic> session) async {
//   //   try {
//   //     if (session['offer'] != null) {
//   //       await _peerConnection!.setRemoteDescription(RTCSessionDescription(session['offer']['sdp'], session['offer']['type']));
//   //       RTCSessionDescription answer = await _peerConnection!.createAnswer();
//   //       await _peerConnection!.setLocalDescription(answer);
//   //       await _sendSignal({'answer': answer.toMap()});
//   //     } else if (session['answer'] != null) {
//   //       await _peerConnection!.setRemoteDescription(RTCSessionDescription(session['answer']['sdp'], session['answer']['type']));
//   //     } else if (session['candidate'] != null) {
//   //       _peerConnection!.addCandidate(RTCIceCandidate(
//   //           session['candidate']['candidate'], session['candidate']['sdpMid'], session['candidate']['sdpMLineIndex']));
//   //     }
//   //   } catch (e) {
//   //     print("Error setting remote description: $e");
//   //   }
//   // }

//   // // Send signaling data (offer, answer, candidate) to the server
//   // Future<void> _sendSignal(Map<String, dynamic> data) async {
//   //   try {
//   //     final response = await http.post(
//   //       Uri.parse('ws://192.168.10.103:8085/ws'),
//   //       headers: {'Content-Type': 'application/json'},
//   //       body: jsonEncode(data),
//   //     );

//   //     if (response.statusCode == 200) {
//   //       final responseData = jsonDecode(response.body);
//   //       await _setRemoteDescription(responseData);
//   //     } else {
//   //       print("Error sending signal: ${response.statusCode}");
//   //     }
//   //   } catch (e) {
//   //     print("Error during signaling: $e");
//   //   }
//   // }

//   @override
//   void dispose() {
//     _peerConnection?.close();
//     _localStream?.dispose();
//     _localRenderer.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('WebRTC Voice Call')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             _localStream != null
//                 ? RTCVideoView(_localRenderer)
//                 : Text("No local video stream"),
//             ElevatedButton(
//               onPressed: _createOffer,
//               child: Text('Start Call'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// class VoiceMyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: VideoCallPage(),
//     );
//   }
// }

// class VideoCallPage extends StatefulWidget {
//   @override
//   _VideoCallPageState createState() => _VideoCallPageState();
// }

// class _VideoCallPageState extends State<VideoCallPage> {
//   RTCVideoRenderer _localRenderer = RTCVideoRenderer();
//   RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
//   Signaling _signaling = Signaling();

//   @override
//   void initState() {
//     super.initState();
//     _localRenderer.initialize();
//     _remoteRenderer.initialize();

//     _signaling.connect();
//   }

//   @override
//   void dispose() {
//     _localRenderer.dispose();
//     _remoteRenderer.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Flutter WebRTC Demo'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: Row(
//               children: [
//                 Expanded(child: RTCVideoView(_localRenderer)),
//                 Expanded(child: RTCVideoView(_remoteRenderer)),
//               ],
//             ),
//           ),
//           SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: () async {
//               await _signaling.openUserMedia(_localRenderer);
//               await _signaling.createPeerConnection0();
//               await _signaling.createOffer();
//             },
//             child: Text('Start Call'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               await _signaling.createAnswer();
//             },
//             child: Text('Answer Call'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               await _signaling.hangUp();
//             },
//             child: Text('Hang Up'),
//           ),
//         ],
//       ),
//     );
//   }
// }









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
