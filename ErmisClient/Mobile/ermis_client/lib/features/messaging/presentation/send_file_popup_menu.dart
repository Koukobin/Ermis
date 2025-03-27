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

import 'package:camera/camera.dart';
import 'package:ermis_client/core/util/file_utils.dart';
import 'package:flutter/material.dart';

import '../../../languages/generated/l10n.dart';
import '../../../theme/app_colors.dart';

class SendFilePopupMenu extends StatefulWidget {
  final int chatSessionIndex;
  final FileCallBack fileCallBack;
  final ImageCallBack imageCallBack;

  const SendFilePopupMenu({
    required this.chatSessionIndex,
    required this.fileCallBack,
    required this.imageCallBack,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => SendFilePopupMenuState();
}

class SendFilePopupMenuState extends State<SendFilePopupMenu> {
  @override
  void initState() {
    super.initState();
  }

  void _sendFile(String fileName, Uint8List fileBytes) {
    widget.fileCallBack(fileName, fileBytes);
  }

  void _sendImageFile(String fileName, Uint8List fileBytes) {
    widget.imageCallBack(fileName, fileBytes);
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
                color: appColors.inferiorColor.withOpacity(0.4),
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
          Text(label, style: TextStyle(fontSize: 14)),
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
            shape: RoundedRectangleBorder(
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
                          onTap: () async {
                            Navigator.pop(context);
                            attachSingleFile(context, (String fileName, Uint8List fileBytes) {
                              _sendImageFile(fileName, fileBytes);
                            });
                          },
                        ),
                        const SizedBox(width: 5),
                        _buildPopupOption(
                          context,
                          icon: Icons.camera_alt,
                          label: S.current.camera,
                          onTap: () async {
                            Navigator.pop(context);
                            XFile? file = await MyCamera.capturePhoto();

                            if (file == null) {
                              return;
                            }

                            String fileName = file.name;
                            Uint8List fileBytes = await file.readAsBytes();

                            _sendImageFile(fileName, fileBytes);
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