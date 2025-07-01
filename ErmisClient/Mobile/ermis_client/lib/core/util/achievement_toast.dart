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
import '../../../theme/app_colors.dart';

class AchievementToast {
  static void show(BuildContext context, String message) {
    final animationController = ValueNotifier<AnimationController?>(null);
    final achievementWidget = _AchievementToastWidget(
      message: message,
      animationController: animationController,
    );

    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(builder: (context) => achievementWidget);

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3, milliseconds: 500), () {
      animationController.value!.reverse().whenComplete(overlayEntry.remove);
    });
  }
}


class _AchievementToastWidget extends StatefulWidget {
  final String message;
  final ValueNotifier<AnimationController?> animationController;

  const _AchievementToastWidget({
    required this.message,
    required this.animationController,
  });

  @override
  State<_AchievementToastWidget> createState() => _AchievementToastWidgetState();
}

class _AchievementToastWidgetState extends State<_AchievementToastWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.0),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    widget.animationController.value = _controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Positioned(
      top: 50,
      left: 20,
      right: 20,
      child: SlideTransition(
        position: _offsetAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            color: appColors.primaryColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.emoji_events, color: appColors.secondaryColor),
                  const SizedBox(width: 12),
                  Text(
                    widget.message,
                    style: TextStyle(color: appColors.secondaryColor, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
