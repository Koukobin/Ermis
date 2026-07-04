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

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class CustomHttpClient {
  static final _httpClient = _initHttpClient();

  static http.Client _initHttpClient() {
    final httpClient = HttpClient();

    // Disable certificate validation
    httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) => true;

    return IOClient(httpClient);
  }

  const CustomHttpClient();

  Future<Uint8List?> fetchUint8ListFromUrl(String url) async {
    try {
      final response = await _httpClient.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Convert the response body (List<int>) to Uint8List
        return Uint8List.fromList(response.bodyBytes);
      } else {
        if (kDebugMode) debugPrint('Failed to fetch data: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error fetching data: $e');
      return null;
    }
  }
}
