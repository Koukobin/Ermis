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

import 'dart:io';

class JavaInetSocketAddress {
  final InternetAddress address;
  final int port;

  const JavaInetSocketAddress(this.address, this.port);

  @override
  int get hashCode => address.hashCode * port.hashCode;

  // Very strange StackOverflow exception occurs in voice calls with this equals method
  @override
  bool operator ==(Object other) {
    if (this == other) {
      return true;
    }

    if (other is! JavaInetSocketAddress) {
      return false;
    }

    return address == other.address && port == other.port;
  }

  @override
  String toString() => '${address.address}:$port';
}
