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

import '../../../exceptions/EnumNotFoundException.dart';

enum VoiceCallHistoryStatus {
  created(0),
  accepted(1),
  ignored(2);

  final int id;

  const VoiceCallHistoryStatus(this.id);

  static final Map<int, VoiceCallHistoryStatus> _valuesById = {
    for (var status in VoiceCallHistoryStatus.values) status.id: status,
  };

  static VoiceCallHistoryStatus fromId(int id) {
    final s = _valuesById[id];

    if (s == null) {
      throw EnumNotFoundException('No $VoiceCallHistoryStatus found for id $id');
    }
    
    return s;
  }
}
