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

import 'package:ermis_client/main_ui/settings/account_settings.dart';
import 'package:ermis_client/main_ui/settings/notification_settings.dart';
import 'package:ermis_client/util/transitions_util.dart';
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../client/client.dart';
import '../../util/top_app_bar_utils.dart';
import '../user_profile.dart';
import 'profile_settings.dart';
import 'help_settings.dart';
import 'linked_devices_settings.dart';
import 'theme_settings.dart';

class Settings extends StatefulWidget {

  const Settings({super.key});

  @override
  State<Settings> createState() => SettingsState();
}

class SettingsState extends State<Settings> {

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      backgroundColor: appColors.tertiaryColor,
      appBar: ErmisAppBar(
        title: Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const PersonalProfilePhoto(),
            title: const DisplayName(),
            subtitle: Text('Profile, change name, ID'),
            onTap: () {
              pushHorizontalTransition(context, const ProfileSettings());
            },
          ),
          ListTile(
            leading: Icon(Icons.lock),
            title: Text('Account'),
            subtitle: Text('Privacy, security, change number'),
            onTap: () {
              pushHorizontalTransition(context, const AccountSettings());
            },
          ),
          ListTile(
            leading: Icon(Icons.chat),
            title: Text('Chats'),
            subtitle: Text('Theme, wallpapers, chat history'),
            onTap: () {
              pushHorizontalTransition(context, const ThemeSettingsPage());
            },
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notifications'),
            subtitle: Text('Message, group, and call tones'),
            onTap: () {
               pushHorizontalTransition(context, const NotificationSettings());
            },
          ),
          ListTile(
            leading: Icon(Icons.data_usage),
            title: Text('Storage and Data'),
            subtitle: Text('Network usage, auto-download'),
            onTap: () {
              // Navigate to Storage and Data settings
            },
          ),
          ListTile(
            leading: Icon(Icons.help),
            title: Text('Help'),
            subtitle: Text('FAQ, contact us, terms and privacy policy'),
            onTap: () {
              pushHorizontalTransition(context, const HelpSettings());
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.link),
            title: Text('Linked Devices'),
            onTap: () {
              pushHorizontalTransition(context, const LinkedDevices());
            },
          ),
          ListTile(
            leading: Icon(
              Icons.logout,
              color: Colors.redAccent,
            ),
            title: Text(
              "Logout From Account",
              style: const TextStyle(
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
                  () => Client.getInstance().commands.logoutThisDevice());
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
  static String _displayName = Client.getInstance().displayName ?? "";

  @override
  void initState() {
    super.initState();

    Client.getInstance().whenUsernameReceived((String displayName) {
      setState(() {
        _displayName = displayName;
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

void showLogoutConfirmationDialog(
    BuildContext context, String content, VoidCallback onYes) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Logout?'),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onYes();
              Navigator.of(context).pop();
            },
            child: Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
}

// class LoadingTestName extends StatefulWidget {
//   const LoadingTestName({super.key});

//   @override
//   State<LoadingTestName> createState() => LoadingTestNameState();
// }

// class LoadingTestNameState extends State<LoadingTestName> {


//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final appColors = Theme.of(context).extension<AppColors>()!;
//     return Scaffold(
//       backgroundColor: appColors.secondaryColor,
//       appBar: const ErmisAppBar(
//           title: Text(
//         "Account Settings",
//         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
//       )),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Expanded(
//               child: TextButton.icon(
//                 onPressed: () {
//                   print("Tapped TextButton");
//                 },
//                 icon:
//                     Icon(Icons.person), // This is the equivalent of the "leading"
//                 label: Text(
//                     "Title"), // This is the text displayed alongside the icon
//               ),
//             ),

//             Card(
//               color: appColors.tertiaryColor,
//               elevation: 3,
//               margin: EdgeInsets.symmetric(vertical: 10),
//               child: Padding(
//                 padding: const EdgeInsets.all(15.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "ID: 123",
//                       style: TextStyle(
//                         fontSize: 18,
//                         color: appColors.primaryColor,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     SizedBox(height: 10),
//                     Text(
//                       "Your Name:",
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                     SizedBox(height: 5),
//                     DisplayName()
//                   ],
//                 ),
//               ),
//             ),

//             // Expanded(
//             //   child: ListView(children: [
//             //     ListTile(
//             //       leading: Icon(Icons.person),
//             //       title: Text("Title"),
//             //       subtitle: Text("Subtitle"),
//             //       onTap: () {
//             //         print("Tapped ListTile");
//             //       },
//             //     ),
//             //     ListTile(
//             //       leading: Icon(Icons.person),
//             //       title: Text("Title"),
//             //       subtitle: Text("Subtitle"),
//             //       onTap: () {
//             //         print("Tapped ListTile");
//             //       },
//             //     ),
//             //   ]),
//             // ),

//           ],
//         ),
//       ),
//     );
//   }

// }