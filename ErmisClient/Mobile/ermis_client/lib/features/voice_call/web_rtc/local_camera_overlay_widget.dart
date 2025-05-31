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
import 'package:flutter/scheduler.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../../theme/app_colors.dart';

class LocalCameraOverlayWidget extends StatefulWidget {
  final RTCVideoRenderer localRenderer;
  final MediaStream localStream;

  const LocalCameraOverlayWidget({
    super.key,
    required this.localRenderer,
    required this.localStream,
  });

  @override
  State<LocalCameraOverlayWidget> createState() => _LocalCameraOverlayWidgetState();
}

class _LocalCameraOverlayWidgetState extends State<LocalCameraOverlayWidget> {
  double _top = Random().nextDouble() * 600;
  double _left = Random().nextDouble() * 200;
  OverlayEntry? _overlayEntry;

  double width = 150;
  double height = 200;

  @override
  void initState() {
    super.initState();

    // You generally can't modify the widget tree (like inserting an overlay entry)
    // during the build process of another widget in Flutter. Hence, to fix this,
    // we insert the overlay only after the widget tree has been built using the
    // SchedulerBinding.instance.addPostFrameCallback. This callback is executed once
    // after the current frame has been built and rendered.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _insertOverlay();
    });
  }

  void _insertOverlay() {
    final AppColors appColors = Theme.of(context).extension<AppColors>()!;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: _top,
        left: _left,
        child: InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(20.0),
          minScale: 0.5,
          maxScale: 4.0,
          child: GestureDetector(
            onPanUpdate: (details) {
              _left += details.delta.dx;
              _top += details.delta.dy;
              _overlayEntry?.markNeedsBuild();
            },
            child: Align(
              alignment: Alignment.bottomRight,
              child: Container(
                width: width,
                height: height,
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  child: Stack(
                    children: [
                      RTCVideoView(
                        widget.localRenderer,
                        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                        mirror: true,
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton.filled(
                          onPressed: () {
                            widget.localStream.getVideoTracks().forEach((track) {
                              Helper.switchCamera(track);
                            });
                          },
                          icon: const Icon(Icons.switch_camera_outlined),
                          color: appColors.secondaryColor,
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all<Color>(appColors.primaryColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // Get the OverlayState and insert the OverlayEntry
    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // Dummy object associated with widget
  }
}

/*
  // Normalize x and y to 0-1 range based on screen size
  double normalizedX = details.localPosition.dx / screenSize.width;
  double normalizedY = details.localPosition.dy / screenSize.height;

  setState(() {
    // Convert normalized values into RGB color
    switchCameraButtonBackgroundColor = Color.fromARGB(
      255,
      (normalizedX * 255).toInt(),
      (normalizedY * 255).toInt(),
      150,
    );
    switchCameraButtonForegroundColor = Color.fromARGB(
      255,
      (switchCameraButtonBackgroundColor.red.toInt() - 255).abs(),
      (switchCameraButtonBackgroundColor.green.toInt() - 255).abs(),
      (switchCameraButtonBackgroundColor.blue.toInt() - 255).abs(),
    );
  });
*/
