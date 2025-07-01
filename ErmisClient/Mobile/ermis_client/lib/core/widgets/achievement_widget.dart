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
import 'package:shimmer/shimmer.dart';

class AchievementWidget extends StatefulWidget {
  final String achievementImage;
  const AchievementWidget({super.key, required this.achievementImage});

  @override
  State<AchievementWidget> createState() => AchievementWidgetState();
}

class AchievementWidgetState<T extends AchievementWidget> extends State<T> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  late Image achievementImage;

  @override
  void initState() {
    super.initState();

    achievementImage = Image.asset(
      widget.achievementImage,
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
