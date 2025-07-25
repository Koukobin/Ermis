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
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:ermis_mobile/core/services/settings_json.dart';
import 'package:ermis_mobile/features/messaging/presentation/first_message_sent_achievement_popup.dart';
import 'package:flutter/material.dart';

import '../../../core/data_sources/api_client.dart';
import '../../../core/models/message.dart';
import '../../../generated/l10n.dart';
import '../../../theme/app_colors.dart';
import 'send_file_popup_menu.dart';

class InputField extends StatefulWidget {
  final int chatSessionIndex;
  final List<Message> messages;
  const InputField({
    super.key,
    required this.chatSessionIndex,
    required this.messages,
  });

  @override
  State<StatefulWidget> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  bool _isMakingVoiceMessage = false;

  final TextEditingController _inputController = TextEditingController();
  final RecorderController recorderController = RecorderController();

  @override
  void initState() {
    super.initState();
    recorderController.checkPermission();
  }

  void _sendTextMessage(String text) {
    Message pendingMessage =
        Client.instance().sendMessageToClient(text, widget.chatSessionIndex);
    _addMessage(pendingMessage);
  }

  Future<void> _sendVoiceCallMessage() async {
    setState(() {
      _isMakingVoiceMessage = false;
    });

    if (recorderController.isRecording) {
      String? recordedFilePath = await recorderController.stop();
      if (recordedFilePath == null) return;

      Uint8List fileBytes = await File(recordedFilePath).readAsBytes();

      String generateRandomString(int len) {
        final r = Random();
        const chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
        return List.generate(len, (index) => chars[r.nextInt(chars.length)]).join();
      }

      String fileName = generateRandomString(6);

      Message pendingMessage = Client.instance().sendVoiceMessageToClient(
        fileName,
        fileBytes,
        widget.chatSessionIndex,
      );
      _addMessage(pendingMessage);
    }
  }

  void _addMessage(Message msg) {
    if (!SettingsJson().hasUserSentFirstMessage) {
      FirstMessageSentAchievementPopup.show(context);
      SettingsJson().setHasUserSentFirstMessage(true);
    }

    widget.messages.add(msg);
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return AnimatedSwitcher(
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(
          scale: animation,
          child: child,
        );
      },
      duration: const Duration(milliseconds: 500),
      child: _isMakingVoiceMessage
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              decoration: BoxDecoration(
                color: appColors.primaryColor,
                borderRadius: BorderRadius.circular(32),
              ),
              width: double.infinity,
              key: ValueKey("Heisenberg-${widget.chatSessionIndex}"),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: appColors.inferiorColor,
                    child: IconButton(
                      onPressed: () async /* async is necessary (idk why) */ {
                        setState(() {
                          _isMakingVoiceMessage = false;
                        });
                        recorderController.stop(true);
                      },
                      icon: Icon(
                        Icons.delete_outline,
                        color: appColors.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: AudioWaveforms(
                      size: const Size(
                        double.infinity,
                        50,
                      ),
                      waveStyle: const WaveStyle(
                        extendWaveform: true,
                        showMiddleLine: false,
                        // middleLineColor: appColors.inferiorColor,
                      ),
                      recorderController: recorderController,
                    ),
                  ),
                  RecordingTimer(controller: recorderController),
                  IconButton(
                    onPressed: _sendVoiceCallMessage,
                    icon: Icon(
                      Icons.arrow_forward_ios_outlined,
                      color: appColors.inferiorColor,
                    ),
                  ),
                ],
              ),
            )
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                children: [
                  const SizedBox(width: 5),
                  SendFilePopupMenu(
                    chatSessionIndex: widget.chatSessionIndex,
                    fileCallBack: (String fileName, Uint8List fileContent) {
                      Message pendingMessage =
                          Client.instance().sendFileToClient(
                        fileName,
                        fileContent,
                        widget.chatSessionIndex,
                      );
                      _addMessage(pendingMessage);
                    },
                    imageCallBack: (String fileName, Uint8List fileContent) {
                      Message pendingMessage =
                          Client.instance().sendImageToClient(
                        fileName,
                        fileContent,
                        widget.chatSessionIndex,
                      );
                      _addMessage(pendingMessage);
                    },
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextField(
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      controller: _inputController,
                      decoration: InputDecoration(
                        hintText: S.current.type_message,
                        filled: true,
                        fillColor: appColors.secondaryColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _inputController,
                      builder: (context, value, child) {
                        final isEmpty = value.text.trim().isEmpty;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: CircleAvatar(
                            backgroundColor: isEmpty
                                ? appColors.primaryColor
                                : Colors.transparent,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 150),
                              transitionBuilder: (Widget child, Animation<double> animation) {
                                return ScaleTransition(
                                  scale: animation,
                                  child: child,
                                );
                              },
                              child: isEmpty
                                  ? IconButton(
                                      key: ValueKey('selected_send_voice_button${widget.chatSessionIndex}'), // Unique key for the selected state)
                                      onPressed: () async {
                                        setState(() {
                                          _isMakingVoiceMessage = true;
                                        });
                                        if (recorderController.hasPermission) {
                                          recorderController.record(
                                            sampleRate: 48000, // High sample rate for high quality audio
                                            bitRate: 1000, // High bit rate for high quality audio
                                          );
                                        }
                                      },
                                      icon: Icon(
                                        Icons.mic,
                                        color: appColors.secondaryColor,
                                      ),
                                    )
                                  : IconButton(
                                      key: ValueKey('selected_send_text_button_${widget.chatSessionIndex}'),
                                      onPressed: () async /* async is necessary (idk why) */ {
                                        _sendTextMessage(_inputController.text);
                                        _inputController.clear();
                                      },
                                      icon: Icon(
                                        Icons.send,
                                        color: appColors.inferiorColor,
                                      ),
                                    ),
                            ),
                          ),
                        );
                      }),
                ],
              ),
            ),
    );
  }
}

class RecordingTimer extends StatefulWidget {
  final RecorderController controller;

  const RecordingTimer({super.key, required this.controller});

  @override
  State<RecordingTimer> createState() => _RecordingTimerState();
}

class _RecordingTimerState extends State<RecordingTimer> {
  late StreamSubscription<Duration> _subscription;
  late int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();

    _subscription =
        widget.controller.onCurrentDuration.listen((Duration duration) {
      setState(() {
        _elapsedSeconds = widget.controller.elapsedDuration.inSeconds;
      });
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '$_elapsedSeconds',
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }
}


