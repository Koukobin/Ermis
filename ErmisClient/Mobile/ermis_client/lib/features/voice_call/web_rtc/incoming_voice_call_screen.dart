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

import 'package:ermis_mobile/core/models/member.dart';
import 'package:ermis_mobile/core/widgets/profile_photos/user_profile_photo.dart';
import 'package:ermis_mobile/generated/l10n.dart';
import 'package:flutter/material.dart';

class IncomingCallScreen extends StatefulWidget {
  final Member member;

  const IncomingCallScreen({super.key, required this.member});

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen> with TickerProviderStateMixin {
  late AnimationController acceptButtonAnimationController;
  late Animation<double> acceptButtonAnimation;

  late AnimationController declineButtonAnimationController;
  late Animation<double> declineButtonAnimation;

  @override
  void initState() {
    super.initState();

    // Accept button animation
    acceptButtonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    acceptButtonAnimation = Tween<double>(begin: 0, end: -25).animate(
      CurvedAnimation(
        parent: acceptButtonAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Decline button animation
    declineButtonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    declineButtonAnimation = Tween<double>(begin: 0, end: 25).animate(
      CurvedAnimation(
        parent: declineButtonAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    acceptButtonAnimationController.dispose();
    declineButtonAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey, // Grey because why not
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image: self-explanatory
          if (widget.member.icon.profilePhoto.isNotEmpty)
            Image.memory(
              widget.member.icon.profilePhoto,
              fit: BoxFit.cover,
            )
          else
            FittedBox(
              fit: BoxFit.contain,
              child: Text(widget.member.username[0].toUpperCase()),
            ),
          // A semi-transparent overlay to darken background
          Container(
            color: Colors.black.withValues(alpha: 0.5),
          ),
          // Caller info positioned in the center
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Caller Avatar
                UserProfilePhoto(
                  radius: 60,
                  profileBytes: widget.member.icon.profilePhoto,
                ),
                const SizedBox(height: 20),
                // Caller name
                Text(
                  widget.member.username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Incoming Voice Call", // TODO: ADD MULTIPLE LANGUAGES
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          // Bottom action buttons (decline and accept).
          Positioned(
            bottom: 50,
            left: 50,
            right: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Decline call button
                AnimatedBuilder(
                  animation: declineButtonAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, declineButtonAnimation.value),
                      child: child,
                    );
                  },
                  child: Column(
                    spacing: 10,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 70,
                        height: 125,
                        child: Stack(
                          children: [
                            DraggableYAxis(
                              left: 0,
                              initialYOffset: 50,
                              minY: 0,
                              maxY: 50, // Equal to initialYOffset
                              onLongPress: () {
                                declineButtonAnimationController.stop(canceled: false);
                              },
                              onLongPressEnd: (details) {
                                acceptButtonAnimationController.repeat(reverse: true);
                              },
                              onTap: () {
                                Navigator.pop(context, false);
                              },
                              onDragEndOnMinY: () {
                                Navigator.pop(context, false);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.call_end,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // ElevatedButton(
                      //   onPressed: () {
                      //     Navigator.pop(context, false);
                      //   },
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: Colors.red,
                      //     shape: const CircleBorder(),
                      //     padding: const EdgeInsets.all(20),
                      //   ),
                      //   child: const Icon(
                      //     Icons.call_end,
                      //     color: Colors.white,
                      //     size: 30,
                      //   ),
                      // ),
                      Text(S.current.decline),
                    ],
                  ),
                ),
                // Accept call button
                AnimatedBuilder(
                  animation: acceptButtonAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, acceptButtonAnimation.value),
                      child: child,
                    );
                  },
                  child: Column(
                    spacing: 10,
                    children: [
                      SizedBox(
                        width: 70,
                        height: 125,
                        child: Stack(
                          children: [
                            DraggableYAxis(
                              left: 0,
                              initialYOffset: 50,
                              minY: 0,
                              maxY: 50, // Equal to initialYOffset
                              onLongPress: () {
                                acceptButtonAnimationController.stop(
                                    canceled: false);
                              },
                              onLongPressEnd: (details) {
                                acceptButtonAnimationController.repeat(
                                    reverse: true);
                              },
                              onTap: () {
                                Navigator.pop(context, true);
                              },
                              onDragEndOnMinY: () {
                                Navigator.pop(context, true);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.call,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // ElevatedButton(
                      //   onLongPress: () {
                      //     controller.stop(canceled: true);
                      //   },
                      //   onPressed: () {
                      //     Navigator.pop(context, true);
                      //     controller.repeat(reverse: true);
                      //   },
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: Colors.green,
                      //     shape: const CircleBorder(),
                      //     padding: const EdgeInsets.all(20),
                      //   ),
                      //   child: const Icon(
                      //     Icons.call,
                      //     color: Colors.white,
                      //     size: 30,
                      //   ),
                      // ),
                      Text(S.current.accept),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DraggableYAxis extends StatefulWidget {
  /// The widget that will be made draggable
  final Widget child;

  /// The initial vertical offset (in pixels).
  final double initialYOffset;

  /// The minimum allowed y-offset
  final double minY;

  /// The maximum allowed y-offset
  final double maxY;

  /// The left position (in pixels) in the parent [Stack]
  final double left;

  final VoidCallback? onDragEndOnMinY;
  
  final GestureLongPressCallback? onLongPress;
  final GestureLongPressEndCallback? onLongPressEnd;

  final VoidCallback? onTap;

  const DraggableYAxis({
    super.key,
    required this.child,
    this.initialYOffset = 0,
    this.minY = 0,
    this.maxY = 300,
    required this.left,
    this.onDragEndOnMinY,
    this.onLongPress,
    this.onLongPressEnd,
    this.onTap,
  });

  @override
  State<DraggableYAxis> createState() => _DraggableYAxisState();
}

class _DraggableYAxisState extends State<DraggableYAxis> {
  late double yOffset;
  final GlobalKey _dragKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    yOffset = widget.initialYOffset;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: yOffset,
      left: widget.left,
      child: GestureDetector(
        key: _dragKey,
        onVerticalDragUpdate: (details) {
          setState(() {
            // Update and clamp the yOffset so that the widget remains within bounds
            yOffset = (yOffset + details.delta.dy).clamp(widget.minY, widget.maxY);
          });
        },
        onVerticalDragEnd: (details) {
          // Get the final global position of the widget using the GlobalKey
          final RenderBox box = _dragKey.currentContext?.findRenderObject() as RenderBox;
          final Offset globalOffset = box.localToGlobal(Offset.zero);
          debugPrint("Final global position: $globalOffset");

          if (yOffset == widget.minY) {
            widget.onDragEndOnMinY?.call();
          }
        },
        onLongPress: widget.onLongPress,
        onLongPressEnd: widget.onLongPressEnd,
        onTap: widget.onTap,
        child: widget.child,
      ),
    );
  }
}