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

import 'package:ermis_client/core/event_bus/app_event_bus.dart';
import 'package:ermis_client/core/models/message_events.dart';
import 'package:ermis_client/core/widgets/profile_photos/personal_profile_photo.dart';
import 'package:ermis_client/mixins/event_bus_subscription_mixin.dart';
import 'package:ermis_client/features/settings/options/account_settings.dart';
import 'package:ermis_client/features/settings/options/notification_settings.dart';
import 'package:ermis_client/theme/app_colors.dart';
import 'package:ermis_client/core/services/locale_provider.dart';
import 'package:ermis_client/core/util/transitions_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../generated/l10n.dart';
import '../../core/data_sources/api_client.dart';
import '../../core/widgets/scroll/custom_scroll_view.dart';
import '../../core/util/dialogs_utils.dart';
import '../../core/util/top_app_bar_utils.dart';
import 'options/help_settings.dart';
import 'options/language_settings.dart';
import 'options/linked_devices_settings.dart';
import 'options/profile_settings.dart';
import 'options/storage_data_settings.dart';
import 'options/theme_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final localeProvider = Provider.of<LocaleProvider>(context);

    return Scaffold(
      backgroundColor: appColors.secondaryColor,
      appBar: ErmisAppBar(
        titleText: S.current.settings,
      ),
      body: ScrollViewFixer.createScrollViewWithAppBarSafety(
        scrollView: ListView(
          children: [
            ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                leading: const PersonalProfilePhoto(radius: 25),
                title: const DisplayName(),
                subtitle: Text(S.current.profile_change_name_id),
                onTap: () {
                  navigateWithFade(context, const ProfileSettings());
                },
                trailing: IconButton(
                    onPressed: () async {
                      await AccountSettings.showOtherAccounts(context);
                    },
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: appColors.primaryColor,
                    ))),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.key),
              title: Text(S.current.account),
              subtitle: Text(S.current.privacy_security_change_number),
              onTap: () {
                pushSlideTransition(context, const AccountSettings());
              },
            ),
            // ListTile(
            //   leading: const Icon(Icons.lock),
            //   title: Text("S.current.account"),
            //   subtitle: Text("S.current.privacy_security_change_number"),
            //   onTap: () {
            //     pushSlideTransition(context, const PrivacySettingsPage());
            //   },
            // ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: Text(S.current.chats),
              subtitle: Text(S.current.theme_wallpapers_chat_history),
              onTap: () {
                pushSlideTransition(context, const ThemeSettingsPage());
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: Text(S.current.notifications),
              subtitle: Text(S.current.message_group_call_tones),
              onTap: () {
                pushSlideTransition(context, const NotificationSettings());
              },
            ),
            ListTile(
              leading: const Icon(Icons.data_usage),
              title: Text(S.current.storage_data),
              subtitle: Text(S.current.network_usage_auto_download),
              onTap: () {
                pushSlideTransition(context, const StorageAndDataScreen());
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(S.current.app_language),
              subtitle: Text(localeProvider.language ?? "Could not find language"),
              onTap: () {
                LanguageSettingsPage.showSheet(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: Text(S.current.help),
              subtitle: Text(S.current.faq_contact_terms_privacy),
              onTap: () {
                pushSlideTransition(context, const HelpSettings());
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.link),
              title: Text(S.current.linked_devices),
              onTap: () {
                pushSlideTransition(context, const LinkedDevicesScreen());
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.redAccent,
              ),
              title: Text(
                S.current.logout_from_this_device,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
              onTap: () {
                showLogoutConfirmationDialog(
                    context,
                    S.current.linked_devices_logout_confirm,
                    () => Client.instance().commands.logoutThisDevice());
              },
            )
          ],
        ),
      ),
    );
  }

}

class DisplayName extends StatefulWidget {
  const DisplayName({super.key});

  @override
  State<DisplayName> createState() => DisplayNameState();
}

class DisplayNameState extends State<DisplayName> with EventBusSubscriptionMixin {
  String _displayName = Client.instance().displayName ?? "";

  @override
  void initState() {
    super.initState();

    subscribe(AppEventBus.instance.on<UsernameReceivedEvent>(), (event) {
      if (!mounted) return;

      setState(() {
        _displayName = event.displayName;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayName,
      style: const TextStyle(fontSize: 18),
    );
  }
  
}

