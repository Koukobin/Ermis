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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../util/dialogs_utils.dart';

class UrlLauncher {
  UrlLauncher._();

  static Future<void> launchURL(BuildContext context, String url0) async {
    final Uri url = Uri.parse(url0);

    try {
      final success = await launchUrl(url);
      if (success) return;
    } on PlatformException catch (pe) {
      if (kDebugMode) debugPrint("Launch URL error: $pe");
    }

    if (context.mounted) {
      showErrorDialog(context, "Unable to open the URL: $url");
      return;
    }

    showToastDialog("Unable to open the URL: $url");
  }
}
