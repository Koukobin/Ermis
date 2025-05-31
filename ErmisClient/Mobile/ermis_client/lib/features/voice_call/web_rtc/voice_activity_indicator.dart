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

import 'package:flutter/material.dart';

class IndicatorDenotingVoiceActivity extends StatefulWidget {
  const IndicatorDenotingVoiceActivity({super.key});

  @override
  State<IndicatorDenotingVoiceActivity> createState() => _IndicatorDenotingVoiceActivityState();
}

class _IndicatorDenotingVoiceActivityState extends State<IndicatorDenotingVoiceActivity> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500), // Duration for one complete cycle
      vsync: this,
    )..repeat(reverse: true); // Repeat animation, reversing at the end

    _animation = Tween<double>(begin: 200.0, end: 225.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut, 
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // AnimatedSize(
    // duration: const Duration(milliseconds: 100),
    // child: CircleAvatar(
    // radius: (100 + rms) >= 200 ? 200 : 100 + rms,
    // backgroundColor: const Color.fromRGBO(158, 158, 158, 0.4),
    // ),
    // );

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: _animation.value,
          height: _animation.value,
          decoration: const BoxDecoration(
            color: Color.fromRGBO(158, 158, 158, 0.4),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}