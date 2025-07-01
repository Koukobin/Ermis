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

import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:shimmer/shimmer.dart';

import '../../../constants/app_constants.dart';
import '../../../core/util/achievement_toast.dart';
import '../../../core/util/dialogs_utils.dart';

class FirstMessageSentAchievementPopup {
  static void show(BuildContext context) async {
    FlutterRingtonePlayer().play(fromAsset: AppConstants.firstMessageSentAchievementSoundEffect);
    await Future.delayed(const Duration(milliseconds: 100));

    AchievementToast.show(context, "First Message Sent");
    await Future.delayed(const Duration(milliseconds: 200));

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (context, animation, secondaryAnimation) {
        Timer(const Duration(seconds: 3), Navigator.of(context).pop);

        return const WhatsAppPopupDialog(child: _FirstMessageSentAchievementWidget());
      },
    );
  }
}

class _FirstMessageSentAchievementWidget extends StatefulWidget {
  const _FirstMessageSentAchievementWidget();

  @override
  State<_FirstMessageSentAchievementWidget> createState() => _FirstMessageSentAchievementWidgetState();
}

class _FirstMessageSentAchievementWidgetState
    extends State<_FirstMessageSentAchievementWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  late Image achievementImage;

  @override
  void initState() {
    super.initState();

    achievementImage = Image.asset(
      AppConstants.firstMessageSentAchievement,
      height: 400,
      fit: BoxFit.contain,
    );

    _controller = AnimationController(
      duration: const Duration(seconds: 35),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.fastEaseInToSlowEaseOut),
    );

    Future.delayed(const Duration(milliseconds: 100), _controller.forward);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Center(
        child: Stack(
          children: [
            achievementImage,

            // Shimmer Overlay
            Positioned.fill(
              child: Shimmer.fromColors(
                baseColor: Colors.transparent,
                highlightColor: Colors.white.withAlpha(102),
                direction: ShimmerDirection.ltr,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

