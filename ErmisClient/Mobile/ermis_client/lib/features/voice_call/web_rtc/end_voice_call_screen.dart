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
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import '../../../theme/app_colors.dart';

class EndVoiceCallScreen extends StatefulWidget {
  final Member member;
  final String callDuration;

  const EndVoiceCallScreen({
    super.key,
    required this.member,
    required this.callDuration,
  });

  @override
  State<EndVoiceCallScreen> createState() => _EndVoiceCallScreenState();
}

class _EndVoiceCallScreenState extends State<EndVoiceCallScreen> {
  bool popped = false;

  void pop() async {
    if (popped) return;
    popped = true;

    Navigator.of(context).pop();

    if (await FlutterOverlayWindow.isActive()) {
      await FlutterOverlayWindow.closeOverlay();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    Future.delayed(const Duration(seconds: 3), pop);

    return Scaffold(
      backgroundColor: appColors.secondaryColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: pop,
          icon: const Icon(Icons.close),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 100),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Call ended icon
              // Icon(
              //   Icons.call_end,
              //   color: Colors.red[400],
              //   size: 80,
              // ),
              UserProfilePhoto(radius: 65, profileBytes: widget.member.icon.profilePhoto),
              const SizedBox(height: 20),
              // Call ended text
              Text(
                S.current.call_ended,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              // Call duration
              Text(
                widget.callDuration,
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}