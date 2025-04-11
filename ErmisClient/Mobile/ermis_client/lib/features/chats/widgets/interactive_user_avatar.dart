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
import 'package:ermis_client/core/models/chat_session.dart';
import 'package:ermis_client/core/networking/common/message_types/client_status.dart';
import 'package:ermis_client/theme/app_colors.dart';
import 'package:ermis_client/core/util/dialogs_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

typedef AvatarClicked = List<Widget> Function(BuildContext context, VoidCallback popContext);
List<Widget> _defaultAvatarClickedAction(BuildContext _, VoidCallback __) => const [];

class InteractiveUserAvatar extends StatelessWidget {
  final Uint8List imageBytes;
  final ClientStatus status;

  final ChatSession chatSession;

  final Member member;
  final String avatarID;

  final AvatarClicked onAvatarClicked;

  InteractiveUserAvatar({
    super.key,
    required this.member,
    required this.chatSession,
    this.onAvatarClicked = _defaultAvatarClickedAction,
  })  : imageBytes = member.icon.profilePhoto,
        status = member.status,
        avatarID = "avarar-hero-${chatSession.chatSessionID}-${member.clientID}";

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => _showAvatarDialog(context),
      child: Stack(
        children: [
          Hero(
            tag: avatarID,
            child: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey[200],
              backgroundImage: imageBytes.isEmpty ? null : MemoryImage(imageBytes),
              child: imageBytes.isEmpty
                  ? const Icon(
                      Icons.person,
                      color: Colors.grey,
                    )
                  : null,
            ),
          ),
          // Online/Offline Indicator
          Positioned(
            bottom: 0,
            left: 38,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: switch (status) {
                  ClientStatus.online => Colors.green,
                  ClientStatus.offline => Colors.red,
                  ClientStatus.doNotDisturb => Colors.amber,
                  ClientStatus.invisible => Colors.blueGrey,
                },
                shape: BoxShape.circle,
                border: Border.all(
                  color: appColors.secondaryColor, // Border to separate the indicator from the avatar
                  width: 2.5,
                ),
              ),
              // Do not disturb icon
              // child: const Icon(
              //         Icons.do_not_disturb_on_rounded,
              //         color: Colors.red,
              //         size: 13,
              //       ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAvatarDialog(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    Image? image;
    if (imageBytes.isNotEmpty) {
      Size imageDimensions = Size(550, 300);

      image = Image.memory(
        imageBytes,
        width: imageDimensions.width,
        height: imageDimensions.height,
        fit: BoxFit.cover,
      );
    }

    showHeroDialog(context, pageBuilder: (context, _, __) {
      bool isVisible = false;
      bool isInitialized = false;
      return StatefulBuilder(
        builder: (context, void Function(VoidCallback) setState) {
          if (!isInitialized) {
            isInitialized = true;
            Future.delayed(Duration(milliseconds: 50), () {
              setState(() {
                isVisible = true; // Trigger the animation after build
              });
            });
          }

          void popContext() {
            setState(() {
              isVisible = false;
              Future.delayed(
                Duration(milliseconds: 300),
                Navigator.of(context).pop,
              );
            });
          }

          return GestureDetector(
            onTap: popContext,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 48.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: InteractiveViewer(
                        boundaryMargin: EdgeInsets.all(20),
                        minScale: 1.0,
                        maxScale: 8.0,
                        child: Hero(
                          tag: avatarID,
                          child: Container(
                            color: appColors.tertiaryColor,
                            child: imageBytes.isEmpty
                                ? CircleAvatar(
                                    radius: 180,
                                    backgroundColor: Colors.grey[200],
                                    backgroundImage: null,
                                    child: Icon(
                                      Icons.person,
                                      size: 180,
                                      color: Colors.grey,
                                    ))
                                : image,
                          ),
                        ),
                      ),
                    ),
                    AnimatedOpacity(
                      opacity: isVisible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeIn,
                      child: AnimatedSlide(
                        offset: isVisible ? Offset.zero : Offset(0, 1),
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeIn,
                        child: Container(
                          color: appColors.tertiaryColor,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: onAvatarClicked(context, popContext),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }
}
