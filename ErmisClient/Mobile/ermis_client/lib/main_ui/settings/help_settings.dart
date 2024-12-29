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

import 'package:ermis_client/util/transitions_util.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/app_constants.dart';
import '../../theme/app_theme.dart';
import '../../util/dialogs_utils.dart';
import '../../util/file_utils.dart';
import '../../util/top_app_bar_utils.dart';

class HelpSettings extends StatefulWidget {

  const HelpSettings({super.key});

  @override
  State<HelpSettings> createState() => HelpSettingsState();
}

class HelpSettingsState extends State<HelpSettings> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      backgroundColor: appColors.secondaryColor,
      appBar: const GoBackBar(title: "Help & Settings"),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            ListTile(
                leading: Icon(FontAwesomeIcons.github),
                title: Text(
                  "Source Code",
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                onTap: () async {
                  final Uri url = Uri.parse(sourceCodeURL);
                  if (!await launchUrl(url)) {
                    showErrorDialog(context, "Unable to open the URL: $url");
                  }
                }),
            ListTile(
                leading: Icon(Icons.attach_money_outlined),
                title: Text(
                  "Donation Page",
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                onTap: () async {
                  showSnackBarDialog(
                      context: context,
                      content: "Functionality not implemented yet!");
                }),
            ListTile(
                leading: Icon(FontAwesomeIcons.shieldHalved),
                title: Text(
                  "License Crux",
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                onTap: () async {
                  final Uri url = Uri.parse(licenceURL);
                  if (!await launchUrl(url)) {
                    showErrorDialog(context, "Unable to open the URL: $url");
                  }
                }),
            ListTile(
                leading: Icon(Icons.info_outline),
                title: Text(
                  "App info",
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                onTap: () async {
                  pushHorizontalTransition(context, const AppInfo());
                }),
          ],
        ),
      ),
    );
  }
}

class AppInfo extends StatelessWidget {
  const AppInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 96.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Ermis Messenger",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Version: $applicationVersion",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF9E9E9E),
                ),
              ),
              SizedBox(height: 25),
              Image.asset(
                appIconPath,
                width: 125,
                height: 125,
              ),
              SizedBox(height: 25),
              Text(
                "Ⓒ 2023-2024 Ilias Koukovinis",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF9E9E9E),
                ),
              ),
              SizedBox(height: 25),
              ElevatedButton(
                onPressed: () {
                  pushHorizontalTransition(context, const LicenceInfo());
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: appColors.inferiorColor, // Splash color
                  backgroundColor: appColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 32),
                ),
                child: Text("Licence",
                    style:
                        TextStyle(fontSize: 18, color: appColors.secondaryColor)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LicenceInfo extends StatefulWidget {
  const LicenceInfo({super.key});

  @override
  State<LicenceInfo> createState() => _LicenceInfoState();
}

class _LicenceInfoState extends State<LicenceInfo> {

  String _licenceContent = "";

  @override
  void initState() {
    super.initState();
    _readLicenceFile();
  }

  void _readLicenceFile() async{
    String content = await loadAssetFile(licencePath);
    setState(() {
      _licenceContent = content;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      appBar: AppBar(title: Text("Licence"), backgroundColor: appColors.secondaryColor,),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 5.0),
        child: SingleChildScrollView(
          child: Text(
            _licenceContent,
            style: TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
          ),
        ),
      ),
    );
  }
}