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

class _WaveformData {
  final List<double> fullRes;
  final List<double> downSampled;

  _WaveformData({required this.fullRes}) : downSampled = _downSample(fullRes);

  static List<double> _downSample(List<double> fullResolution) {
    List<double> sampled = List.filled((fullResolution.length / 2).toInt(), 0);

    // Alternative way to write ensuing while loop (idk which is clearer)
    /*
    * for (int i = 0, j = 1; i < sampled.length; i++, j += 2) {
    *   sampled[i] = fullResolution[j] + fullResolution[j - 1];
    * }
    */

    {
      int i = 0;
      int j = 1;
      while (i < sampled.length) {
        sampled[i] = fullResolution[j] + fullResolution[j - 1];
        i++;
        j += 2;
      }
    }

    return sampled;
  }
}

class VoiceMessage extends StatefulWidget {
  final Message message;
  const VoiceMessage({super.key, required this.message});

  @override
  State<StatefulWidget> createState() => _VoiceMessageState();
}

class _VoiceMessageState extends State<VoiceMessage> with EventBusSubscriptionMixin {
  static Map<Message, _WaveformData> waveformCache = {};

  late final Message _message;

  bool isDownloading = false;
  PlayerController? _player;
  _WaveformData? waveformData;

  /// Dummy key used to force rebuild when [_player] state mutates
  Key _widgetKey = UniqueKey();

  @override
  void initState() {
    _message = widget.message;
    waveformData = waveformCache[_message];

    subscribe(AppEventBus.instance.on<VoiceDownloadedEvent>(), (event) {
      isDownloading = false;

      if (event.messageID != _message.messageID) return;
      _message.setFileName(Uint8List.fromList(utf8.encode(event.file.fileName)));
      _message.fileBytes = event.file.fileBytes;

      togglePlayer();
    });
    super.initState();
  }

  void togglePlayer() async {
    if (_player?.playerState.isPaused ?? false) {
      setState(() => _widgetKey = UniqueKey());
      startPlayer();
      return;
    }

    if (_player?.playerState.isPlaying ?? false) {
      setState(() => _widgetKey = UniqueKey());
      _player?.pausePlayer();
      return;
    }

    Uint8List fileBytes = _message.fileBytes!;
    String fileName = _message.fileName;

    File file = await createTempFile(fileBytes, fileName);
    _player = PlayerController();
    await _player!.preparePlayer(path: file.path);

    if (waveformData == null) {
      List<double> waveform = await _player!.extractWaveformData(path: file.path);
      waveformData = _WaveformData(fullRes: waveform);
      waveformCache[_message] = waveformData!;
    }

    startPlayer();
  }

  void startPlayer() {
    setState(() => _widgetKey = UniqueKey());

    // Audioplayer will be automatically disposed once completed
    _player!.startPlayer();

    _player!.onCompletion.listen((void x /* What even is this? */) {
      _player!.release();
      _player = null;
      setState(() => _widgetKey = UniqueKey());
    });
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    Widget widgetAction;

    if (isDownloading) {
      widgetAction = const SizedBox(height: 50, child: DotsLoadingScreen());
    } else {
      if (_player?.playerState.isPlaying ?? false) {
        widgetAction = const Icon(Icons.pause);
      } else {
        widgetAction = const Icon(Icons.play_arrow);
      }
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
            key: _widgetKey,
            onPressed: () {
              if (_message.fileBytes == null) {
                // Audio will be played automatically once voice message is received
                Client.instance().commands?.downloadSound(
                      _message.messageID,
                      _message.chatSessionIndex,
                    );

                setState(() {
                  isDownloading = true;
                });

                return;
              }

              togglePlayer();
            },
            icon: widgetAction,
          ),
          if (_message.fileBytes != null)
            Expanded(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.07,
                ),
                child: _player == null
                    ? Transform.translate(
                        offset: const Offset(0, 20),
                        child: _SimpleWaveform(
                          samples: waveformData?.downSampled ?? [],
                        ),
                      )
                    : AudioFileWaveforms(
                        waveformData: waveformData?.downSampled ?? [],
                        size: Size(
                          MediaQuery.of(context).size.width,
                          50,
                        ),
                        playerWaveStyle: PlayerWaveStyle(
                          liveWaveColor: Colors.greenAccent,
                          spacing: 3,
                          waveThickness: 1.5,
                          scaleFactor: 50,
                        ),
                        waveformType: WaveformType.fitWidth,
                        playerController: _player!,
                      ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SimpleWaveform extends StatelessWidget {
  final List<double> samples;
  const _SimpleWaveform({required this.samples});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _WaveformPainter(samples),
        );
      },
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final List<double> peaks;
  _WaveformPainter(this.peaks);

  @override
  void paint(Canvas canvas, Size size) {
    if (peaks.isEmpty) return;

    final paint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final double centerY = size.height / 5;
    final double maxBarHeight = size.height;

    final double spacing = size.width / peaks.length;

    for (int i = 0; i < peaks.length; i++) {
      final double x = i * spacing;
      final double barHeight = peaks[i] * maxBarHeight;

      canvas.drawLine(
        Offset(x, centerY - barHeight),
        Offset(x, centerY + barHeight),
        paint,
      );
    }

    /*
    * final whitePaint = Paint()
    *  ..color = Colors.white
    *  ..strokeWidth = strokeWidth
    *  ..strokeCap = StrokeCap.square;
    *
    * canvas.saveLayer(Offset.zero & size, Paint());
    * final double x = (animation!.value * 100) * spacing;
    * final double barHeight = peaks[(animation!.value * 100).floor().clamp(0, 99)] * maxBarHeight * 2;
    *
    * canvas.restore();
    * canvas.drawLine(
    *   Offset(x, centerY - barHeight),
    *   Offset(x, centerY + barHeight),
    *   whitePaint,
    * );
    */
  }

  @override
  bool shouldRepaint(_WaveformPainter oldDelegate) {
    return oldDelegate.peaks != peaks;
  }
}
