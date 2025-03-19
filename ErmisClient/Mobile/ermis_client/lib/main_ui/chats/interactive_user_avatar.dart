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
import 'package:ermis_client/client/common/chat_session.dart';
import 'package:ermis_client/theme/app_colors.dart';
import 'package:ermis_client/util/dialogs_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

typedef AvatarClicked = List<Widget> Function(BuildContext context, VoidCallback popContext);
List<Widget> _defaultAvatarClickedAction(BuildContext _, VoidCallback __) => const [];

class InteractiveUserAvatar extends StatelessWidget {
  final Uint8List imageBytes;
  final bool isOnline;

  final ChatSession chatSession;
  final int avatarID;

  final AvatarClicked onAvatarClicked;

  InteractiveUserAvatar({
    super.key,
    required this.imageBytes,
    required this.isOnline,
    required this.chatSession,
    this.onAvatarClicked = _defaultAvatarClickedAction,
  }) : avatarID = chatSession.getMembers[0].clientID;

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => _showAvatarDialog(context),
      child: Stack(
        children: [
          Hero(
            tag: "avarar-hero-$avatarID",
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[200],
              backgroundImage: imageBytes.isEmpty ? null : MemoryImage(imageBytes),
              child: imageBytes.isEmpty
                  ? Icon(
                      Icons.person,
                      color: Colors.grey,
                    )
                  : null,
            ),
          ),
          // Online/Offline Indicator
          Positioned(
            bottom: 0,
            left: 30,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: isOnline
                    ? Colors.green
                    : Colors.red, // Online or offline color
                shape: BoxShape.circle,
                border: Border.all(
                  color: appColors.secondaryColor, // Border to separate the indicator from the avatar
                  width: 1,
                ),
              ),
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
                          tag: "avarar-hero-$avatarID",
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
                      duration: Duration(milliseconds: 250),
                      curve: Curves.easeIn,
                      child: AnimatedSlide(
                        offset: isVisible ? Offset.zero : Offset(0, 1),
                        duration: Duration(milliseconds: 350),
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
