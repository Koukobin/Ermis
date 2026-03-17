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

import 'dart:typed_data';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:ermis_mobile/core/networking/common/message_types/content_type.dart';
import 'package:ermis_mobile/core/util/file_utils.dart';
import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:vibration/vibration.dart';

import '../../../core/util/image_utils.dart';
import '../../../generated/l10n.dart';
import '../../../theme/app_colors.dart';

Future<void> _showEditImageDialog(
  BuildContext context, {
  required String fileName,
  required Uint8List fileBytes,
  required ImageCallBack sendImageFile,
}) {
  return showDialog(
    context: context,
    builder: (context) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: ProImageEditor.memory(
          fileBytes,
          callbacks: ProImageEditorCallbacks(
            onImageEditingComplete: (Uint8List modifiedBytes) async {
              sendImageFile(fileName, modifiedBytes);
              Navigator.pop(context);
            },
            mainEditorCallbacks: MainEditorCallbacks(
              helperLines: HelperLinesCallbacks(onLineHit: () {
                Vibration.vibrate(duration: 3);
              }),
            ),
          ),
        ),
      );
    },
  );
}

class SendFilePopupMenu extends StatefulWidget {
  final int chatSessionIndex;
  final FileCallBack fileCallBack;
  final ImageCallBack imageCallBack;
  final AudioCallBack audioCallBack;
  final VideoCallBack videoCallBack;

  const SendFilePopupMenu({
    required this.chatSessionIndex,
    required this.fileCallBack,
    required this.imageCallBack,
    required this.audioCallBack,
    required this.videoCallBack,
    super.key,
  });

  @override
  State<SendFilePopupMenu> createState() => SendFilePopupMenuState();
}

class SendFilePopupMenuState extends State<SendFilePopupMenu> {
  @override
  void initState() {
    super.initState();
  }

  void _sendFile(String fileName, Uint8List fileBytes) {
    widget.fileCallBack(fileName, fileBytes);
  }

  void _sendImage(String fileName, Uint8List fileBytes) {
    widget.imageCallBack(fileName, fileBytes);
  }

  void _sendAudio(String fileName, Uint8List fileBytes) {
    widget.audioCallBack(fileName, fileBytes);
  }

  void _sendVideo(String fileName, Uint8List fileBytes) {
    widget.videoCallBack(fileName, fileBytes);
  }

  MessageContentType? acquireContentType(Uint8List data) {
    final imageType = ImageUtils.detectImageType(data);
    switch (imageType) {
      case ImageType.png ||
            ImageType.jpeg ||
            ImageType.bmp ||
            ImageType.tiff ||
            ImageType.ico ||
            ImageType.cur ||
            ImageType.pvr ||
            ImageType.webp ||
            ImageType.psd ||
            ImageType.exr ||
            ImageType.pnm:
        return MessageContentType.image;
      default:
        {
          // Do nothing.
        }
    }

    final mediaType = detectFromBytes(data);
    switch (mediaType) {
      case MediaFormat.mp4 ||
            MediaFormat.mkv ||
            MediaFormat.webm ||
            MediaFormat.flv ||
            MediaFormat.mpegTs ||
            MediaFormat.mpegPs ||
            MediaFormat.avi:
        return MessageContentType.video;
      case MediaFormat.mp3 ||
            MediaFormat.aac ||
            MediaFormat.ogg ||
            MediaFormat.flac ||
            MediaFormat.wav:
        return MessageContentType.voice;
      default:
        {
          // Do nothing.
        }
    }

    return MessageContentType.file;
  }

  Widget _buildPopupOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: appColors.inferiorColor.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: CircleAvatar(
              radius: 27,
              backgroundColor: appColors.tertiaryColor,
              child: Icon(icon, size: 28, color: appColors.primaryColor),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (BuildContext context) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      S.current.choose_option,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildPopupOption(
                          context,
                          icon: Icons.image,
                          label: S.current.gallery,
                          onTap: () {
                            attachSingleFile(context, (
                              String fileName,
                              Uint8List fileBytes,
                            ) {
                              final contentType = acquireContentType(fileBytes);

                              switch (contentType) {
                                case MessageContentType.file:
                                  {
                                    _sendFile(fileName, fileBytes);
                                  }
                                case MessageContentType.image:
                                  _showEditImageDialog(
                                    context,
                                    fileName: fileName,
                                    fileBytes: fileBytes,
                                    sendImageFile: _sendImage,
                                  ).whenComplete(() => Navigator.pop(context));
                                case MessageContentType.voice:
                                  _sendAudio(fileName, fileBytes);
                                case MessageContentType.video:
                                  _sendVideo(fileName, fileBytes);
                                case null:
                                  print("Content type not recognized");
                                default:
                                  {
                                    // Do nothing.
                                  }
                              }
                            });
                          },
                        ),
                        const SizedBox(width: 5),
                        _buildPopupOption(
                          context,
                          icon: Icons.camera_alt,
                          label: S.current.camera,
                          onTap: () async {
                            XFile? file = await MyCamera.capturePhoto();

                            if (file == null) {
                              return;
                            }

                            String fileName = file.name;
                            Uint8List fileBytes = await file.readAsBytes();

                            await _showEditImageDialog(
                              context,
                              fileName: fileName,
                              fileBytes: fileBytes,
                              sendImageFile: _sendImage,
                            );

                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(width: 5),
                        _buildPopupOption(
                          context,
                          icon: Icons.insert_drive_file,
                          label: S.current.documents,
                          onTap: () {
                            Navigator.pop(context);
                            attachSingleFile(context,
                                (String fileName, Uint8List fileBytes) {
                              _sendFile(fileName, fileBytes);
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
        icon: const Icon(Icons.attach_file));
  }
}
