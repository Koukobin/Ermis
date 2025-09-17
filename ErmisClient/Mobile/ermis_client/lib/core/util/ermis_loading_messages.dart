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

class ErmisLoadingMessages {
  static const _messages = [
    'Waiting for Ermis while he is sipping his ambrosia...',
    'Ermis is fetching your data from Olympus...',
    'Ermis is preparing your divine experience...',
    'Ermis is putting on his talaria... wait a sec',
    'Ermis is dusting his caduceus... just a moment',
  ];

  const ErmisLoadingMessages._();

  static String randomMessage() {
    return _messages[Random().nextInt(_messages.length)];
  }
}
