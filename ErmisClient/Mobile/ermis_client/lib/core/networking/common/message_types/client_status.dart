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

import 'package:ermis_client/core/exceptions/EnumNotFoundException.dart';

enum ClientStatus {
  online(0),
  offline(1),
  doNotDisturb(2),
  invisible(3);

  final int id;
  const ClientStatus(this.id);

  static final Map<int, ClientStatus> _values = {
    for (final status in ClientStatus.values) status.id: status,
  };

  static ClientStatus fromId(int id) {
    return _values[id] ?? (throw EnumNotFoundException("Client status with given id not found: $id"));
  }
}
