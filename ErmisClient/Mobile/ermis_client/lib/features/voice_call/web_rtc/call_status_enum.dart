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

import 'package:ermis_mobile/core/exceptions/EnumNotFoundException.dart';
import 'package:ermis_mobile/generated/l10n.dart';

enum CallStatus {
  connecting(0),
  calling(1),
  active(2),
  ringing(3),
  ended(4);

  final int id;
  const CallStatus(this.id);

  String get text {
    return switch(CallStatus.fromId(id)) {
      CallStatus.active => S.current.active,
      CallStatus.connecting => S.current.Connecting,
      CallStatus.calling => S.current.Calling,
      CallStatus.ringing => "Ringing",
      CallStatus.ended => S.current.ended,
    };
  }

  static CallStatus fromId(int id) {
    try {
      return CallStatus.values.firstWhere((type) => type.id == id);
    } catch (e) {
      throw EnumNotFoundException('No $CallStatus found for id $id');
    }
  }
}
