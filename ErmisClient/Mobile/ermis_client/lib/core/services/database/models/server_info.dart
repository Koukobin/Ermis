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

import 'dart:io';

class ServerInfo {
  final Uri _serverUrl;
  final InternetAddress? _address;
  final int? _port;
  DateTime lastUsed;

  ServerInfo.empty()
      : _serverUrl = Uri(),
        _address = null,
        _port = -1,
        lastUsed = DateTime.fromMillisecondsSinceEpoch(0);

  factory ServerInfo(Uri serverUrl, [DateTime? lastUsed]) {
    if (!serverUrl.toString().startsWith("https://")) {
      serverUrl = Uri.parse("https://${serverUrl.toString()}");
    }

    // Check if url is valid
    if (!(serverUrl.hasScheme && serverUrl.hasAuthority)) {
      throw InvalidServerUrlException("Invalid server URL: $serverUrl");
    }

    InternetAddress address = InternetAddress(serverUrl.host);
    int port = serverUrl.port;

    return ServerInfo._(serverUrl, address, port, lastUsed ?? DateTime.now());
  }

  ServerInfo._(this._serverUrl, this._address, this._port, this.lastUsed);

  Uri get serverUrl => _serverUrl;
  InternetAddress? get address => _address;
  int? get port => _port;

  Map<String, Object?> toMap() {
    return {
      'server_url': _serverUrl.toString(),
      'last_used': lastUsed.toIso8601String()
    };
  }

  @override
  bool operator ==(Object other) =>
      other is ServerInfo &&
      other.runtimeType == runtimeType &&
      other.serverUrl == serverUrl;

  @override
  int get hashCode => serverUrl.hashCode;

  @override
  String toString() {
    return serverUrl.toString();
  }
}

class InvalidServerUrlException implements Exception {
  final String message;

  const InvalidServerUrlException(this.message);

  @override
  String toString() {
    return message;
  }
}