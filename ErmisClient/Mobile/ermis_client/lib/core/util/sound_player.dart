/* Copyright (C) 2026 Ilias Koukovinis <ilias.koukovinis@gmail.com>
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

import 'package:flutter/foundation.dart';
import 'package:flutter_ringtone_player_plus/flutter_ringtone_player.dart';
import 'package:flutter_ringtone_player_plus/flutter_ringtone_player_plus.dart';

class FlutterSoundPlayer {
  static Future<void> playNotification() {
    return FlutterRingtonePlayer().playNotification();
  }

  static void play({String? fromAsset}) {
    FlutterRingtonePlayer().play(fromAsset: fromAsset);
    const ringtonePlayer = RingtonePlayer();
    if (fromAsset == null) {
      ringtonePlayer.playNotification();
      return;
    }

    try {
      ringtonePlayer.play(RingtoneSource.file(fromAsset));
    } on RingtoneException catch (error) {
      if (kDebugMode) {
        debugPrint(error.toString());
        debugPrint(error.toString());
        debugPrint(error.toString());
        debugPrint(error.toString());
        debugPrint(error.toString());
      }

      // Fallback to default notification sound
      ringtonePlayer.playNotification();
    }
  }
}
