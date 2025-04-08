/* Copyright (C) 2024 Ilias Koukovinis <ilias.koukovinis@gmail.com>
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
import 'dart:ui';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:ermis_client/core/data_sources/api_client.dart';
import 'package:ermis_client/client/common/message_types/content_type.dart';
import 'package:ermis_client/client/common/message_types/message_delivery_status.dart';
import 'package:ermis_client/core/models/message.dart';
import 'package:ermis_client/core/util/custom_date_formatter.dart';
import 'package:ermis_client/core/util/dialogs_utils.dart';
import 'package:ermis_client/core/util/file_utils.dart';
import 'package:ermis_client/features/dots_loading_screen.dart';
import 'package:ermis_client/generated/l10n.dart';
import 'package:ermis_client/theme/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/event_bus/app_event_bus.dart';
import '../../../core/models/message_events.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final Message? previousMessage;
  final AppColors appColors;

  const MessageBubble({
    super.key,
    required this.message,
    required this.previousMessage,
    required this.appColors,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMessageOwner = message.clientID == Client.instance().clientID;

    const int millisPerSecond = 1000;
    DateTime currentMessageDate = DateTime.fromMillisecondsSinceEpoch(
            message.epochSecond * millisPerSecond /* Convert seconds to millis */,
            isUtc: true)
        .toLocal();

    DateTime previousMessageDate = DateTime.fromMillisecondsSinceEpoch(
            (previousMessage?.epochSecond ?? 0) * millisPerSecond /* Convert seconds to millis */,
            isUtc: true)
        .toLocal();

    bool isNewDay = previousMessageDate.difference(currentMessageDate).inDays != 0;

    return Column(
      children: [
        if (isNewDay)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Center(
                child: !isNewDay
                    ? Text(S.current.today)
                    : Text(
                        CustomDateFormatter.formatDate(currentMessageDate, "yyyy-MM-dd"))),
          ),
        Align(
          alignment: isMessageOwner ? Alignment.centerRight : Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: 250, // Limit max width to prevent overly wide messages
                  minWidth: 100, // Ensure small messages don't shrink too much
                ),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  padding: const EdgeInsets.all(10),
                  constraints: const BoxConstraints(maxWidth: 225, maxHeight: 300),
                  decoration: BoxDecoration(
                    gradient: isMessageOwner
                        ? LinearGradient(
                            colors: [Color.fromARGB(255, 30, 155, 25), Color.fromARGB(255, 68, 136, 66)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isMessageOwner
                        ? null
                        : const Color.fromARGB(255, 50, 50, 50),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(isMessageOwner ? 10 : 2),
                        topRight: Radius.circular(isMessageOwner ? 2 : 10),
                        bottomLeft: const Radius.circular(10),
                        bottomRight: const  Radius.circular(10)),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none, // Enable positioning outside bounds
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _buildMessageContent(context, message),
                      ),
                      Positioned(
                        bottom: -10,
                        right: -10,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              CustomDateFormatter.formatDate(currentMessageDate, "HH:mm"),
                              style: TextStyle(
                                  color: appColors.inferiorColor, fontSize: 12),
                            ),
                            const SizedBox(width: 3), // Small spacing
                            if (isMessageOwner)
                              _buildDeliveryIcon(message.deliveryStatus),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryIcon(MessageDeliveryStatus status) {
    IconData icon;
    Color color = Colors.white;

    switch (status) {
      case MessageDeliveryStatus.sending:
        return SizedBox(
          height: 12,
          width: 12,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: appColors.inferiorColor,
          ),
        );
      case MessageDeliveryStatus.serverReceived:
        icon = Icons.check; // ✅ Single checkmark
        break;
      case MessageDeliveryStatus.delivered || MessageDeliveryStatus.lateDelivered:
        icon = Icons.done_all; // ✅✅ Double checkmarks
        color = Color(0xFF34B7F1); // Apparently the color used by WhatsApp for read messages (According to ChatGPT)
        break;
      case MessageDeliveryStatus.failed:
        icon = Icons.sms_failed_rounded;
        color = Colors.redAccent;
        break;
      case MessageDeliveryStatus.rejected:
        icon = Icons.block;
        color = Colors.redAccent;
    }

    return Icon(icon, size: 16, color: color);
  }

  Widget _buildMessageContent(BuildContext context, Message message) {
    switch (message.contentType) {
      case MessageContentType.text:
        return Text(
          message.text,
          softWrap: true, // Enable text wrapping
          overflow: TextOverflow.clip,
          maxLines: null,
        );
      case MessageContentType.file:
        return Row(
          // Occupy as little space as possible
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: appColors.secondaryColor.withAlpha(100),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Client.instance().commands.downloadFile(
                                message.messageID, message.chatSessionIndex);
                          },
                          child: const Icon(Icons.download),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                message.fileName,
                                softWrap: true, // Enable text wrapping
                                overflow: TextOverflow.clip,
                                maxLines: null,
                              ),
                              Text(S.current.unknown_size),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    message.fileName,
                    softWrap: true, // Enable text wrapping
                    overflow: TextOverflow.clip,
                    maxLines: null,
                  ),
                ],
              ),
            ),
          ],
        );
      case MessageContentType.image:
        final image = message.fileBytes == null
            ? null
            : Hero(
                tag: '${message.messageID}',
                child: Image.memory(message.fileBytes!),
              );
        bool isDownloading = false;
        return StatefulBuilder(
          builder: (context, setState) {
          return GestureDetector(
            onDoubleTap: () {
              if (image == null) {
                setState(() {
                  isDownloading = true;
                });
                Client.instance()
                    .commands
                    .downloadImage(message.messageID, message.chatSessionIndex);
              }
            },
            child: Container(
              color: appColors.secondaryColor,
              child: image == null
                  ? isDownloading
                      ? const LinearProgressIndicator()
                      : null
                  : GestureDetector(
                      onTap: () {
                        // Display image fullscreen
                        showImageDialog(context, image);
                      },
                      child: FittedBox(fit: BoxFit.contain, child: image)),
            ),
          );
        });
      case MessageContentType.voice:
        return VoiceMessage(
          key: Key(
              "${message.messageID}") /* CRITICAL FOR SOME REASON DO NOT REMOVE */,
          message: message,
        );
    }
  }

  void showImageDialog(BuildContext context, Widget image) {
    showHeroDialog(context,
        pageBuilder: (context, Animation<double> _, Animation<double> __) {
      return GestureDetector(
        onTap: Navigator.of(context).pop,
        child: Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: Container(
                color: Colors.transparent,
              ),
            ),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {
                        saveFileToDownloads(
                            message.fileName, message.fileBytes!);
                      },
                      icon: const Icon(Icons.download),
                    ),
                  ],
                ),
              ),
              body: InteractiveViewer(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: image,
                  ),
                ),
              ),
            ),
          ),
              ],
        ),
      );
    });
  }
}
class SimpleWaveform extends StatelessWidget {
  final List<double> samples;
  final Color color;
  final double strokeWidth;

  const SimpleWaveform({
    super.key,
    required this.samples,
    this.color = Colors.blue,
    this.strokeWidth = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _WaveformPainter(samples, color, strokeWidth),
        );
      },
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final List<double> samples;
  final Color color;
  final double strokeWidth;

  _WaveformPainter(this.samples, this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    if (samples.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final sampleCount = samples.length;
    final widthPerSample = size.width / (sampleCount - 1); // Adjust for the last point
    final centerY = size.height / 2;
    final maxHeight = size.height / 2; // Limit the wave amplitude

    for (int i = 0; i < sampleCount - 1; i++) {
      final x1 = i * widthPerSample;
      final y1 = centerY - samples[i] * maxHeight;
      final x2 = (i + 1) * widthPerSample;
      final y2 = centerY - samples[i + 1] * maxHeight;

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter oldDelegate) {
    return oldDelegate.samples != samples ||
           oldDelegate.color != color ||
           oldDelegate.strokeWidth != strokeWidth;
  }
}

enum VoiceMessageState {
  playing, paused, downloading;
}

class VoiceMessage extends StatefulWidget {
  final Message message;
  const VoiceMessage({super.key, required this.message});

  @override
  State<StatefulWidget> createState() => _VoiceMessageState();
}

class _VoiceMessageState extends State<VoiceMessage> {
  late final Message _message;
  VoiceMessageState state = VoiceMessageState.playing;

  PlayerController? _player;

  late final StreamSubscription<VoiceDownloadedEvent> _subcription;

  @override
  void initState() {
    _message = widget.message;

    _subcription = AppEventBus.instance.on<VoiceDownloadedEvent>().listen((event) {
      if (event.messageID != _message.messageID) return;
      _message.setFileName(Uint8List.fromList(utf8.encode(event.file.fileName)));
      _message.fileBytes = event.file.fileBytes;

      playAudio();
    });
    super.initState();
  }

  @override
  void dispose() {
    _subcription.cancel();
    super.dispose();
  }

  void playAudio() async {
    if (_player?.playerState.isPaused ?? false) {
      setState(() {
        state = VoiceMessageState.paused;
      });
      _startPlayer();
      return;
    }

    if (_player?.playerState.isPlaying ?? false) {
      setState(() {
        state = VoiceMessageState.playing;
      });
      _player?.pausePlayer();
      return;
    }

    Uint8List fileBytes = _message.fileBytes!;
    String fileName = _message.fileName;

    if (kDebugMode) {
      debugPrint("playing audio");
      debugPrint("playing audio");
      debugPrint("playing audio");
      debugPrint("playing audio");
      debugPrint("playing audio");
      debugPrint("playing audio");
      debugPrint("playing audio");
      debugPrint("playing audio");
      debugPrint("playing audio");
      debugPrint("playing audio");
      debugPrint("playing audio");
      debugPrint("playing audio");
      debugPrint("playing audio");
      debugPrint("playing audio");
      debugPrint("playing audio");
      debugPrint("playing audio");
      debugPrint("playing audio");
    }

    File file = await createTempFile(fileBytes, fileName);
    _player = PlayerController();
    await _player!.preparePlayer(path: file.path);

    _startPlayer();
  }

  void _startPlayer() {
    setState(() {
      state = VoiceMessageState.paused;
    });

    // Audioplayer will be automatically disposed once completed
    _player!.startPlayer();

    _player?.onCompletion.listen((void x /* What even is this? */) {
      _player = null;
      setState(() {
        state = VoiceMessageState.playing;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    Widget widgetAction;

    switch (state) {
      case VoiceMessageState.playing:
        widgetAction = const Icon(Icons.play_arrow);
        break;
      case VoiceMessageState.paused:
        widgetAction = const Icon(Icons.pause);
        break;
      case VoiceMessageState.downloading:
        widgetAction = SizedBox(height: 50, child: const DotsLoadingScreen());
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: appColors.secondaryColor.withAlpha(100),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        // Row expands and covers max space as dictated by box constraints
        children: [
          IconButton(
              onPressed: () {
                if (_message.fileBytes == null) {
                  // Audio will be played automatically once voice message is received
                  Client.instance().commands.downloadSound(
                        _message.messageID,
                        _message.chatSessionIndex,
                      );

                  setState(() {
                    state = VoiceMessageState.downloading;
                  });

                  return;
                }

                playAudio();
              },
              icon: widgetAction)
        ],
      ),
    );
  }
}
