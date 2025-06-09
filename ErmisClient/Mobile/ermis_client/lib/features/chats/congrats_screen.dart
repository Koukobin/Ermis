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

import '../../core/util/dialogs_utils.dart';
import '../../theme/app_colors.dart';

void showCongratulationsForNewFriendScreen(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'Congrats',
    pageBuilder: (context, animation, secondaryAnimation) {
      Timer(const Duration(seconds: 3), Navigator.of(context).pop);

      return const WhatsAppPopupDialog(child: _CongratsScreen());
    },
  );
}

class _CongratsScreen extends StatefulWidget {
  const _CongratsScreen();

  @override
  State<_CongratsScreen> createState() => _CongratsScreenState();
}

class _CongratsScreenState extends State<_CongratsScreen> {
  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
          decoration: BoxDecoration(
            color: appColors.secondaryColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Color.fromARGB(255, 0, 255, 0)),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.emoji_events, color: Color.fromARGB(255, 0, 255, 0), size: 80),
              SizedBox(height: 20),
              Text(
                'Congratulations!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'You made a friend 🎉',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
