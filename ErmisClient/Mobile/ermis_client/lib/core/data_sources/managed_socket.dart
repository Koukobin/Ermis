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
import 'dart:io';

class ManagedSocket {
  final Socket socket;
  bool _active = true;

  ManagedSocket(this.socket) {
    // Mark inactive when done or error
    socket.done.whenComplete(() => _active = false);
  }

  bool get isActive => _active;

  FutureOr<void> ifActive(FutureOr<void> Function (Socket socket) callback) {
    if (_active) return callback(socket);
  }
}
