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

import 'package:ermis_mobile/core/widgets/achievement_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

import '../../../constants/app_constants.dart';
import '../../../core/util/achievement_toast.dart';
import '../../../core/util/dialogs_utils.dart';

class FirstMessageSentAchievementPopup {
  static void show(BuildContext context) async {
    FlutterRingtonePlayer().play(fromAsset: AppConstants.firstMessageSentAchievementSoundEffect);
    await Future.delayed(const Duration(milliseconds: 100));

    const firstMessageSentAncientGreek = "Πρῶτον ἀγγελθὲν μῆνυμα";
    AchievementToast.show(context, firstMessageSentAncientGreek);
    await Future.delayed(const Duration(milliseconds: 200));

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (context, animation, secondaryAnimation) {
        Timer(const Duration(seconds: 3), Navigator.of(context).pop);

        return const WhatsAppPopupDialog(child: _FirstMessageSentAchievementWidget());
      },
    );
  }
}

class _FirstMessageSentAchievementWidget extends AchievementWidget {
  const _FirstMessageSentAchievementWidget() : super(achievementImage: AppConstants.firstMessageSentAchievement);
}
