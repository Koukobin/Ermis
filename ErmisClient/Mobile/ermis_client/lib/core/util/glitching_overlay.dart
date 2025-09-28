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
import '../widgets/glitch_effect.dart';

import 'dart:math';

class GlitchingOverlay {
  static OverlayEntry? _overlayEntry;
  static bool isShowing = false;

  static void showOverlay(BuildContext context) {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => _buildGlitchOverlay(),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  static void removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  static Widget _buildGlitchOverlay() {
    return IgnorePointer(
      child: Stack(
        children: [
          BackdropFilter(
            filter: const ColorFilter.mode(
              Colors.black,
              BlendMode.saturation,
            ),
            child: Container(color: Colors.transparent),
          ),
          const _RandomlyAppearingNull(offset: Offset(65, 255)),
          //Transform.translate(
          //  offset: const Offset(0, 45),
          //  child: Center(
          //      child: Image.asset(
          //    AppConstants.disconnectedGlitchEffect,
          //    scale: 0.05,
          //  )),
          //),
          const _RandomlyAppearingNull(offset: Offset(300, 450)),
          Center(
            child: GlithEffect(
              child: const Text(
                "Disconnected",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          Transform.translate(
              offset: const Offset(-5, -35),
              child: GlithEffect(
                child: const Text(
                  "Disconnected",
                  style: TextStyle(fontSize: 32),
                ),
              )),
        ],
      ),
    );
  }
}

class _RandomlyAppearingNull extends StatefulWidget {
  final Offset offset;
  const _RandomlyAppearingNull({required this.offset});

  @override
  State<_RandomlyAppearingNull> createState() => _RandomlyAppearingNullState();
}

class _RandomlyAppearingNullState extends State<_RandomlyAppearingNull> {
  bool _visible = false;
  late Timer _timer;

  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_disposed) return;
      setState(() => _visible = !_visible);

      Future.delayed(const Duration(milliseconds: 800), () {
        if (_disposed) return;
        setState(() => _visible = !_visible);
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _disposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return !_visible
        ? const SizedBox.shrink()
        : Transform.translate(
            offset: widget.offset,
            child: ColorFiltered(
              colorFilter: const ColorFilter.matrix(<double>[
                0.2126, 0.7152, 0.0722, 0, 0, // R
                0.2126, 0.7152, 0.0722, 0, 0, // G
                0.2126, 0.7152, 0.0722, 0, 0, // B
                0, 0, 0, 1, 0, // A
              ]),
              child: GlithEffect(
                glitchDuration: const Duration(milliseconds: 100),
                repeatInterval: const Duration(microseconds: 0),
                child: Text(
                  ["NULL", "null"][Random().nextInt(2)],
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          );
  }
}
