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

import 'package:ermis_mobile/core/data_sources/api_client.dart';
import 'package:ermis_mobile/mixins/event_bus_subscription_mixin.dart';
import 'package:ermis_mobile/generated/l10n.dart';
import 'package:ermis_mobile/theme/app_colors.dart';
import 'package:ermis_mobile/core/util/dialogs_utils.dart';
import 'package:ermis_mobile/core/util/transitions_util.dart';
import 'package:ermis_mobile/core/services/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../core/event_bus/app_event_bus.dart';
import '../../../core/models/message_events.dart';
import '../../../constants/app_constants.dart';
import '../../../core/util/file_utils.dart';
import '../../../core/util/top_app_bar_utils.dart';
import '../../../core/widgets/scroll/custom_scroll_view.dart';

class HelpSettings extends StatefulWidget {
  const HelpSettings({super.key});

  @override
  State<HelpSettings> createState() => HelpSettingsState();
}

class HelpSettingsState extends State<HelpSettings> with EventBusSubscriptionMixin {

  @override
  void initState() {
    super.initState();

    subscribe(AppEventBus.instance.on<DonationPageEvent>(), (event) {
      if (!mounted) return;
      UrlLauncher.launchURL(context, event.donationPageURL);
    });

    subscribe(AppEventBus.instance.on<SourceCodePageEvent>(), (event) {
      if (!mounted) return;
      UrlLauncher.launchURL(context, event.sourceCodePageURL);
    });
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      backgroundColor: appColors.secondaryColor,
      appBar: ErmisAppBar(titleText: S.current.help_settings),
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ScrollViewFixer.createScrollViewWithAppBarSafety(
              scrollView: ListView(
            children: [
              // Section 1: Source Code
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(S.current.source_code,
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ListTile(
                leading: const Icon(FontAwesomeIcons.github),
                title: Text(S.current.server_source_code, style: const TextStyle(fontSize: 16)),
                onTap: () {
                  UrlLauncher.launchURL(context, AppConstants.sourceCodeURL);
                },
              ),
              ListTile(
                leading: const Icon(Icons.code),
                title:
                    Text(S.current.server_source_code, style: const TextStyle(fontSize: 16)),
                onTap: () {
                  Client.instance().commands?.requestServerSourceCodeHTMLPage();
                },
              ),

              const Divider(thickness: 2),

              // Section 2: Donations
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(S.current.donations,
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ListTile(
                leading: const Icon(Icons.favorite),
                title:
                    Text(S.current.donate_to_hoster, style: TextStyle(fontSize: 16)),
                onTap: () {
                  Client.instance().commands?.requestDonationHTMLPage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.favorite),
                title: Text(S.current.donate_to_ermis_project,
                    style: TextStyle(fontSize: 16)),
                onTap: () {
                  showSnackBarDialog(
                    context: context,
                    content: S.current.functionality_not_implemented,
                  );
                },
              ),

              const Divider(thickness: 2),

              // Section 3: Other
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(S.current.other,
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ListTile(
                leading: const Icon(FontAwesomeIcons.shieldHalved),
                title: Text(S.current.license_crux, style: const TextStyle(fontSize: 16)),
                onTap: () async {
                  UrlLauncher.launchURL(context, AppConstants.licenceURL);
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(S.current.app_info, style: const TextStyle(fontSize: 16)),
                onTap: () async {
                  pushSlideTransition(context, const AppInfo());
                },
              ),
            ],
          ))),
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
                "${S.current.version_capitalized}: ${AppConstants.applicationVersion}",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF9E9E9E),
                ),
              ),
              const SizedBox(height: 25),
              Image.asset(
                AppConstants.appIconPath,
                width: 125,
                height: 125,
              ),
              const SizedBox(height: 25),
              const Text(
                "Ⓒ 2023-2025 Ilias Koukovinis",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF9E9E9E),
                ),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () =>
                    {pushSlideTransition(context, const LicenceInfo())},
                style: ElevatedButton.styleFrom(
                  foregroundColor: appColors.inferiorColor, // Splash color
                  backgroundColor: appColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 32),
                ),
                child: Text(
                  S.current.license_capitalized,
                  style: TextStyle(fontSize: 18, color: appColors.secondaryColor),
                ),
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
    String content = await loadAssetFile(AppConstants.licencePath);
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