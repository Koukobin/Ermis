
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dialogs_utils.dart';

class UrlLauncher {

  UrlLauncher._();

  static Future<void> launchURL(BuildContext context, String url0) async {
    final Uri url = Uri.parse(url0);

    if (!await launchUrl(url)) {
      showErrorDialog(context, "Unable to open the URL: $url");
    }
  }
}
