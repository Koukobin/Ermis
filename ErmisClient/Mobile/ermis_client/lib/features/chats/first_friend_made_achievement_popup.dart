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

import '../../constants/app_constants.dart';
import '../../core/util/achievement_toast.dart';
import '../../core/util/dialogs_utils.dart';
import '../../core/widgets/achievement_widget.dart';

class FirstFriendMadeAchievementPopup {
  static void show(BuildContext context) async {
    FlutterRingtonePlayer().play(fromAsset: AppConstants.firstMessageSentAchievementSoundEffect);
    await Future.delayed(const Duration(milliseconds: 100));

    AchievementToast.show(context, "First Friend Made");
    await Future.delayed(const Duration(milliseconds: 200));

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (context, animation, secondaryAnimation) {
        Timer(const Duration(seconds: 3), Navigator.of(context).pop);

        return const WhatsAppPopupDialog(child: _FirstFriendMadeAchivementWidget());
      },
    );
  }
}

class _FirstFriendMadeAchivementWidget extends AchievementWidget {
  const _FirstFriendMadeAchivementWidget() : super(achievementImage: AppConstants.firstFriendMadeAchievement);
}

// I genuinely cannot believe that I coded this horrendous UI - and even thought it would be a 
// good idea to include it in the application. Regardless, though, I have kept it here for 
// future reference
//
// class _FirstFriendMadeAchivementWidgetState extends State<_FirstFriendMadeAchivementWidget> {
//   @override
//   Widget build(BuildContext context) {
//     final appColors = Theme.of(context).extension<AppColors>()!;
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       body: Center(
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
//           decoration: BoxDecoration(
//             color: appColors.secondaryColor,
//             borderRadius: BorderRadius.circular(24),
//             border: Border.all(color: Color.fromARGB(255, 0, 255, 0)),
//           ),
//           child: const Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(Icons.emoji_events, color: Color.fromARGB(255, 0, 255, 0), size: 80),
//               SizedBox(height: 20),
//               Text(
//                 'Congratulations!',
//                 style: TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               SizedBox(height: 10),
//               Text(
//                 'You made a friend 🎉',
//                 style: TextStyle(fontSize: 18),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
