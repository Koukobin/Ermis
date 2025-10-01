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

import 'dart:convert';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:ermis_mobile/core/models/message.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../../core/data_sources/api_client.dart';
import '../../../../../core/event_bus/app_event_bus.dart';
import '../../../../../core/models/message_events.dart';
import '../../../../../core/util/file_utils.dart';
import '../../../../../core/widgets/dots_loading_screen.dart';
import '../../../../../mixins/event_bus_subscription_mixin.dart';
import '../../../../../theme/app_colors.dart';

enum VoiceMessageState {
  playing, paused, downloading;
}

class VoiceMessage extends StatefulWidget {
  final Message message;
  const VoiceMessage({super.key, required this.message});

  @override
  State<StatefulWidget> createState() => _VoiceMessageState();
}

class _VoiceMessageState extends State<VoiceMessage> with EventBusSubscriptionMixin {
  late final Message _message;
  VoiceMessageState state = VoiceMessageState.playing;

  PlayerController? _player;

  @override
  void initState() {
    _message = widget.message;

    subscribe(AppEventBus.instance.on<VoiceDownloadedEvent>(), (event) {
      if (event.messageID != _message.messageID) return;
      _message.setFileName(Uint8List.fromList(utf8.encode(event.file.fileName)));
      _message.fileBytes = event.file.fileBytes;

      playAudio();
    });
    super.initState();
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
        widgetAction = const SizedBox(height: 50, child: DotsLoadingScreen());
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
                Client.instance().commands?.downloadSound(
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
            icon: widgetAction,
          )
        ],
      ),
    );
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
