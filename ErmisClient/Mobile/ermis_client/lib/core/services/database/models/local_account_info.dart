/* Copyright (C) 2024 Ilias Koukovinis <ilias.koukovinis@gmail.com>
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

class LocalAccountInfo {
  final String email;
  final String passwordHash;
  final DateTime lastUsed;

  factory LocalAccountInfo.fuck({
    required String email,
    required String passwordHash,
  }) {
    return LocalAccountInfo(
      email: email,
      passwordHash: passwordHash,
      lastUsed: DateTime.now(),
    );
  }

  const LocalAccountInfo({
    required this.email,
    required this.passwordHash,
    required this.lastUsed,
  });

  Map<String, Object?> toMap() {
    return {
      'email': email,
      'password_hash': passwordHash,
      'last_used': lastUsed.toIso8601String()
    };
  }
}
