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

import 'dart:async';

import 'package:ermis_mobile/core/event_bus/app_event_bus.dart';
import 'package:ermis_mobile/core/models/account.dart';
import 'package:ermis_mobile/core/models/message_events.dart';
import 'package:ermis_mobile/core/services/database/extensions/accounts_extension.dart';
import 'package:ermis_mobile/core/services/database/models/local_account_info.dart';
import 'package:ermis_mobile/core/services/database/models/server_info.dart';
import 'package:ermis_mobile/core/widgets/profile_photos/personal_profile_photo.dart';
import 'package:ermis_mobile/core/widgets/profile_photos/user_profile_photo.dart';
import 'package:ermis_mobile/mixins/event_bus_subscription_mixin.dart';
import 'package:ermis_mobile/theme/app_colors.dart';
import 'package:ermis_mobile/core/util/transitions_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../constants/app_constants.dart';
import '../../../core/networking/user_info_manager.dart';
import '../../../core/widgets/custom_textfield.dart';
import '../../../generated/l10n.dart';
import '../../../core/data_sources/api_client.dart';
import '../../../core/services/database/database_service.dart';
import '../../../core/util/dialogs_utils.dart';
import '../../../core/util/top_app_bar_utils.dart';
import '../../authentication/register_interface.dart';
import '../../authentication/domain/entities/client_session_setup.dart';
import 'package:ermis_mobile/features/authentication/verification_mixin.dart';

import '../../authentication/utils/entry_buttons.dart';

List<Account>? get _accounts {
  return Client.instance().otherAccounts;
}

class AccountSettings extends StatefulWidget {
  const AccountSettings({super.key});

  @override
  State<AccountSettings> createState() => _AccountSettingsState();

  static Future<void> showOtherAccounts(BuildContext context) async {
    // Fetch other accounts before displaying sheet
    if (_accounts == null) {
      Client.instance().commands?.fetchOtherAccountsAssociatedWithDevice();
      await AppEventBus.instance.on<OtherAccountsEvent>().first;
    }

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
              Center(
                child: Text(
                  S.current.profile,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const PersonalProfilePhoto(),
                title: Text(Client.instance().displayName ?? "",
                    style: const TextStyle(fontSize: 18)),
                trailing:
                    const Icon(Icons.check_circle, color: Colors.greenAccent),
              ),
              for (final Account serverAccount in _accounts ?? [])
                ListTile(
                  leading: UserProfilePhoto(
                      profileBytes: serverAccount.profilePhoto),
                  title: Text(serverAccount.name(),
                      style: const TextStyle(fontSize: 18)),
                  onTap: () {
                    showConfirmationDialog(context,
                        S.current.are_you_sure_you_want_to_switch_to(serverAccount.name()),
                        () async {
                      ServerInfo serverDetails = UserInfoManager.serverInfo;
                      final DBConnection conn = ErmisDB.getConnection();
                      List<LocalAccountInfo> localAccounts =
                          await conn.getUserAccounts(serverDetails);
                      LocalAccountInfo? matchingAccount;

                      for (LocalAccountInfo localAccount in localAccounts) {
                        if (localAccount.email == serverAccount.email) {
                          matchingAccount = localAccount;
                        }
                      }

                      if (matchingAccount != null) {
                        await conn.updateLastUsedAccount(
                          serverDetails,
                          matchingAccount.email,
                        );
                      }

                      // Pick arbitrary parameters in case of no match
                      matchingAccount ??= LocalAccountInfo(
                        email: serverAccount.email,
                        passwordHash: "",
                        deviceUUID: "",
                        lastUsed: DateTime.now(),
                      );

                      Client.instance().commands?.switchAccount();
                      setupClientSession(context,
                          accountInfo: matchingAccount,
                          keepPreviousRoutes: true);
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
                      child: Text(S.current.close)),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Client.instance().commands?.addNewAccount();
                        pushSlideTransition(
                            context, const CreateAccountInterface());
                      },
                      child: Text(S.current.account_add))
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AccountSettingsState extends State<AccountSettings>
    with EventBusSubscriptionMixin {
  @override
  void initState() {
    super.initState();

    subscribe(AppEventBus.instance.on<OtherAccountsEvent>(), (event) {
      if (!mounted) return;
      setState(() {
        // _accounts will be automatically updated
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: appColors.secondaryColor,
      appBar: ErmisAppBar(titleText: S.current.account_settings),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.password),
              title: Text(S.current.change_password),
              onTap: () async {
                pushSlideTransition(context, const ChangePasswordSettings());
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add_alt),
              title: Text(S.current.account_add),
              onTap: () async {
                await AccountSettings.showOtherAccounts(context);
              },
            ),
            ListTile(
              leading: const Icon(FontAwesomeIcons.solidTrashCan,
                  color: Colors.redAccent),
              title: Text(S.current.account_delete),
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

class ChangePasswordSettings extends StatefulWidget {
  const ChangePasswordSettings({super.key});

  @override
  State<ChangePasswordSettings> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordSettings>
    with Verification, EntryButtons {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _changePassword() async {
    Client.instance().commands?.changePassword(_emailController.text, _passwordController.text);
    await performChangePasswordVerification(context, _emailController.text);
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      appBar: ErmisAppBar(titleText: S.current.change_password),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 60.0, 16.0, 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // App icon display
            Image.asset(
              AppConstants.appIconPath,
              width: 100,
              height: 100,
            ),
            
            KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
              if (isKeyboardVisible) {
                return const SizedBox.shrink();
              }
              return Container(margin: const EdgeInsets.only(top: 32));
            }),

            // Input field for email address
            Padding(
              padding: const EdgeInsets.only(top: 48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    hint: S.current.email,
                  ),
              
                  // Add space below the email input field
                  const SizedBox(height: 10),
              
                  // Input field for password
                  CustomTextField(
                    keyboardType: TextInputType.text,
                    controller: _passwordController,
                    hint: S.current.password,
                    obscureText: true,
                  ),
              
                  // Add space below the password input field
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Button to change password
            buildButton(
              label: S.current.change_password,
              backgroundColor: appColors.secondaryColor,
              icon: Icons.password,
              onPressed: _changePassword,
              textColor: appColors.primaryColor,
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

class _DeleteAccountSettingsState extends State<DeleteAccountSettings>
    with Verification {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

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
      appBar: ErmisAppBar(titleText: S.current.account_delete),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Display a warning icon in red
                const Icon(Icons.warning_amber_rounded, color: Colors.red),

                // Add space between the icon and text
                const SizedBox(width: 20),

                // Display the warning text about account deletion
                Text(S.current.account_delete_confirmation,
                    style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16))
              ],
            ),

            // Add space below the warning text
            const SizedBox(height: 16),

            // Display bullet points explaining what will happen if the account is deleted
            buildBullet(S.current.account_delete_bullet1),
            buildBullet(S.current.account_delete_bullet2),
            buildBullet(S.current.account_delete_bullet3),

            // Add space below the bullet points
            const SizedBox(height: 30),

            // Text
            Text(
              S.current.account_confirm_proceed,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.red,
                letterSpacing: 1.7,
              ),
            ),

            // Add space
            const SizedBox(height: 35),

            // Input field for email address
            CustomTextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              hint: S.current.email,
            ),

            // Add space below the email input field
            const SizedBox(height: 10),

            // Input field for password
            CustomTextField(
              keyboardType: TextInputType.text,
              controller: _passwordController,
              hint: S.current.password,
              obscureText: true,
            ),

            // Add space below the password input field
            const SizedBox(height: 20),

            // Button to delete the account
            ElevatedButton(
              onPressed: () async {
                Client.instance().commands?.deleteAccount(
                    _emailController.text, _passwordController.text);
                final isSuccessful = await performDeleteAccountVerification(
                    context, _emailController.text);

                if (isSuccessful) {
                  SystemNavigator.pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size.fromHeight(50),
              ),
              child: Text(
                S.current.account_delete,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
        const SizedBox(width: 45),
        const Icon(Icons.circle, size: 10, color: Colors.grey),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            softWrap: true,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
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
      shape: const RoundedRectangleBorder(
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
                S.current.name_enter,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Flexible(
                      child: TextField(
                    decoration: InputDecoration(
                      hintText: S.current.name_enter,
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
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(S.current.cancel)),
                  TextButton(
                      onPressed: () {
                        String newDisplayName = displayNameController.text;
                        Client.instance()
                            .commands
                            ?.changeDisplayName(newDisplayName);
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        S.current.save,
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
