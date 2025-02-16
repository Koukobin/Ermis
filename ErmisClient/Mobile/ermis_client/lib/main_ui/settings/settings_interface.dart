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

import 'package:ermis_client/client/app_event_bus.dart';
import 'package:ermis_client/client/message_events.dart';
import 'package:ermis_client/main_ui/settings/account_settings.dart';
import 'package:ermis_client/main_ui/settings/notification_settings.dart';
import 'package:ermis_client/util/transitions_util.dart';
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../client/client.dart';
import '../../util/dialogs_utils.dart';
import '../../util/top_app_bar_utils.dart';
import '../user_profile.dart';
import 'help_settings.dart';
import 'linked_devices_settings.dart';
import 'profile_settings.dart';
import 'theme_settings.dart';

class SettingsScreen extends StatefulWidget {

  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      backgroundColor: appColors.secondaryColor,
      appBar: ErmisAppBar(
        titleText: 'Settings',
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const PersonalProfilePhoto(),
            title: const DisplayName(),
            subtitle: const Text('Profile, change name, ID'),
            onTap: () {
              pushHorizontalTransition(context, const ProfileSettings());
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Account'),
            subtitle: const Text('Privacy, security, change number'),
            onTap: () {
              pushHorizontalTransition(context, const AccountSettings());
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat),
            title: const Text('Chats'),
            subtitle: const Text('Theme, wallpapers, chat history'),
            onTap: () {
              pushHorizontalTransition(context, const ThemeSettingsPage());
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            subtitle: const Text('Message, group, and call tones'),
            onTap: () {
               pushHorizontalTransition(context, const NotificationSettings());
            },
          ),
          ListTile(
            leading: const Icon(Icons.data_usage),
            title: const Text('Storage and Data'),
            subtitle: const Text('Network usage, auto-download'),
            onTap: () {
              // Navigate to Storage and Data settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help'),
            subtitle: const Text('FAQ, contact us, terms and privacy policy'),
            onTap: () {
              pushHorizontalTransition(context, const HelpSettings());
            },
          ),
          Divider(),
          ListTile(
            leading: const Icon(Icons.link),
            title: const Text('Linked Devices'),
            onTap: () {
              pushHorizontalTransition(context, const LinkedDevicesScreen());
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Colors.redAccent,
            ),
            title: const Text(
              "Logout From Account",
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
                  "Are you sure you want to logout?",
                  () => Client.instance().commands.logoutThisDevice());
            },
          )
        ],
      ),
    );
  }

}

class DisplayName extends StatefulWidget {
  const DisplayName({super.key});

  @override
  State<DisplayName> createState() => DisplayNameState();
}

class DisplayNameState extends State<DisplayName> {
  static String _displayName = Client.instance().displayName ?? "";

  @override
  void initState() {
    super.initState();

    AppEventBus.instance.on<UsernameReceivedEvent>().listen((event) {
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
      style: TextStyle(fontSize: 18),
    );
  }
  
}

