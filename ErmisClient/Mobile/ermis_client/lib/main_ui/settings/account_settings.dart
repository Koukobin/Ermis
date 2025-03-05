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
import 'package:ermis_client/client/common/account.dart';
import 'package:ermis_client/client/message_events.dart';
import 'package:ermis_client/main_ui/user_profile.dart';
import 'package:ermis_client/util/transitions_util.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../theme/app_theme.dart';
import '../../client/client.dart';
import '../../util/database_service.dart';
import '../../util/dialogs_utils.dart';
import '../../util/top_app_bar_utils.dart';
import '../entry/entry_interface.dart';
import '../client_session_setup.dart';

List<Account> _accounts = Client.instance().otherAccounts ?? [];


class AccountSettings extends StatefulWidget {
  const AccountSettings({super.key});

  @override
  State<AccountSettings> createState() => _AccountSettingsState();

  static Future showOtherAccounts(BuildContext context) async {
    return await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: Text(
                  "Profiles",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const PersonalProfilePhoto(),
                title: Text(Client.instance().displayName!, style: TextStyle(fontSize: 18)),
                trailing: const Icon(Icons.check_circle, color: Colors.greenAccent),
              ),
              for (final Account account in _accounts)
                ListTile(
                  leading: UserProfilePhoto(profileBytes: account.profilePhoto),
                  title: Text(account.name(), style: TextStyle(fontSize: 18)),
                  onTap: () {
                    showConfirmationDialog(context, "Are you sure you want to switch to ${account.name()}?", () async {
                      ServerInfo serverDetails = Client.instance().serverInfo;
                      final DBConnection conn = ErmisDB.getConnection();
                      List<LocalAccountInfo> allUserAccounts = await conn.getUserAccounts(serverDetails);
                      LocalAccountInfo? matchingAccount;

                      for (LocalAccountInfo userAccount in allUserAccounts) {
                        if (userAccount.email == account.email) {
                          matchingAccount = userAccount;
                        }
                      }

                      Client.instance().commands.switchAccount();
                      setupClientSession(context, matchingAccount, keepPreviousRoutes: true);
                    });
                  },
                ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("Close")),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Client.instance().commands.addNewAccount();
                        pushSlideTransition(context, const CreateAccountInterface());
                      },
                      child: const Text("Add new account"))
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AccountSettingsState extends State<AccountSettings> {

  @override
  void initState() {
    super.initState();

    AppEventBus.instance.on<OtherAccountsEvent>().listen((event) async {
      if (!mounted) return;
      setState(() {
        _accounts = event.accounts;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: appColors.secondaryColor,
      appBar: ErmisAppBar(titleText: "Account Settings"),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.person_add_alt),
              title: const Text('Add account'),
              onTap: () async {
                await AccountSettings.showOtherAccounts(context);
              },
            ),
            ListTile(
              leading: const Icon(FontAwesomeIcons.solidTrashCan, color: Colors.redAccent),
              title: const Text('Delete account'),
              onTap: () {
                pushSlideTransition(context, const DeleteAccountSettings());
              },
            ),
          ],
        ),
      ),
    );
  }

}


class DeleteAccountSettings extends StatefulWidget {
  const DeleteAccountSettings({super.key});

  @override
  State<DeleteAccountSettings> createState() => _DeleteAccountSettingsState();
}

class _DeleteAccountSettingsState extends State<DeleteAccountSettings> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: appColors.secondaryColor,
      appBar: ErmisAppBar(titleText: "Delete Account"),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Display a warning icon in red
                Icon(Icons.warning_amber_rounded, color: Colors.red),

                // Add space between the icon and text
                SizedBox(width: 20),

                // Display the warning text about account deletion
                Text('Deleting this account will:',
                    style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16))
              ],
            ),

            // Add space below the warning text
            SizedBox(height: 16),

            // Display bullet points explaining what will happen if the account is deleted
            buildBullet("Delete your account with no way to recover"),
            buildBullet("Erase your message history"),
            buildBullet("Delete all your chats"),

            // Add space below the bullet points            
            const SizedBox(height: 30),

            // Text
            Text(
              "Are you certain you want to proceed?",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.red,
                letterSpacing: 1.7,
              ),
            ),            

            // Add space
            const SizedBox(height: 35),

            // Input field for email address
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Email address",
                border: OutlineInputBorder(),
              ),
            ),

            // Add space below the email input field
            const SizedBox(height: 10),

            // Input field for password
            TextField(
              controller: passwordController,
              keyboardType: TextInputType.visiblePassword,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),

            // Add space below the password input field
            const SizedBox(height: 20),

            // Button to delete the account
            ElevatedButton(
              onPressed: () {
                Client.instance().commands.deleteAccount(emailController.text, passwordController.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text(
                "Delete My Account",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBullet(String text) {
    return Row(
      children: [
        SizedBox(width: 45),
        Icon(Icons.circle,
            size: 10, color: Colors.grey), // Larger, styled icon
        SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            softWrap: true,
            style: TextStyle(
              fontSize: 14,
              fontWeight:
                  FontWeight.w500,
              color: Colors.grey,
              fontFamily: 'Roboto',
            ),
          ),
        ),
      ],
    );

  }

  Future createModalBottomSheet() {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final TextEditingController displayNameController = TextEditingController();
    displayNameController.text = Client.instance().displayName!;
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
              top: 16.0,
              right: 16.0,
              left: 16.0,
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Enter your name",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Flexible(
                      child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Enter your name',
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: appColors.primaryColor), // Bottom line color
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: appColors.primaryColor,
                            width: 2), // Highlight color
                      ),
                    ),
                    autofocus: true,
                    controller: displayNameController,
                  )),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text("Cancel")),
                  TextButton(
                      onPressed: () {
                        String newDisplayName = displayNameController.text;
                        Client.instance().commands.changeDisplayName(newDisplayName);
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Save",
                        style: TextStyle(),
                      ))
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}