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

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vector_graphics/vector_graphics_compat.dart';

final Random _random = Random();

class _DoodleAssets {
  static final List<PictureInfo> _cache = [];

  static bool _isInitialized = false;

  static void init() async {
    if (_isInitialized) return;
    _isInitialized = true;

    for (var i = 0; i < 25; i++) {
      final info = await vg.loadPicture(
        AssetBytesLoader('assets/chat_backgrounds/doodle_icons/vg/${_random.nextInt(439)}.vg'),
        null,
      );
      _cache.add(info);
    }
  }

  static bool get isNotEmpty => _cache.isNotEmpty;

  static PictureInfo chooseRandomly() {
    return _cache[_random.nextInt(_cache.length)];
  }
}

class ErmisDoodlePainter extends CustomPainter {
  ErmisDoodlePainter() {
    _DoodleAssets.init();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.4) // Subtle doodle color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw Circles
    for (double x = 0; x < size.width; x += 50) {
      for (double y = 0, i = 0; y < size.height; y += 50, i++) {
        canvas.drawCircle(Offset(x, y), 15, paint);

        if (_DoodleAssets.isNotEmpty) {
          final scale = 0.2;
          final radians = _random.nextDouble() * 0.3;
          final pictureInfo = _DoodleAssets.chooseRandomly();

          canvas.saveLayer(
            null,
            Paint()
              ..colorFilter = ColorFilter.mode(
                const Color.fromARGB(255, 75, 150, 80).withValues(alpha: 0.8),
                BlendMode.srcIn,
              ),
          );

          canvas.translate(x, y);
          canvas.scale(scale);
          canvas.rotate(radians);

          canvas.drawPicture(pictureInfo.picture);

          canvas.restore();
        }
      }
    }

    // Draw Wavy Lines
    for (double y = 20; y < size.height; y += 100) {
      final path = Path();
      path.moveTo(0, y);
      for (double x = 0; x < size.width; x += 50) {
        path.quadraticBezierTo(x + 25, y + 20, x + 50, y);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
