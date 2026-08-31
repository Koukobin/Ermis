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
import 'package:ermis_mobile/core/models/member_icon.dart';
import 'package:ermis_mobile/core/models/message_events.dart';
import 'package:ermis_mobile/core/services/database/extensions/accounts_extension.dart';
import 'package:ermis_mobile/core/services/database/models/local_account_info.dart';
import 'package:ermis_mobile/core/services/database/models/server_info.dart';
import 'package:ermis_mobile/core/widgets/profile_photos/personal_profile_photo.dart';
import 'package:ermis_mobile/core/widgets/profile_photos/user_profile_photo.dart';
import 'package:ermis_mobile/features/settings/options/account_settings/change_password_settings.dart';
import 'package:ermis_mobile/features/settings/options/account_settings/delete_account_settings.dart';
import 'package:ermis_mobile/mixins/event_bus_subscription_mixin.dart';
import 'package:ermis_mobile/theme/app_colors.dart';
import 'package:ermis_mobile/core/util/transitions_util.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/networking/user_info_manager.dart';
import '../../../../core/util/screen_reset.dart';
import '../../../../generated/l10n.dart';
import '../../../../core/data_sources/api_client.dart';
import '../../../../core/services/database/database_service.dart';
import '../../../../core/util/dialogs_utils.dart';
import '../../../../core/util/top_app_bar_utils.dart';
import '../../../authentication/choose_entry_type.dart';
import '../../../authentication/domain/entities/client_session_setup.dart';

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
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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
                      icon: MemberIcon(
                    profilePhotoID: "dummy-id",
                    profilePhoto: serverAccount.profilePhoto,
                  )),
                  title: Text(serverAccount.name(),
                      style: const TextStyle(fontSize: 18)),
                  onTap: () {
                    showConfirmationDialog(context,
                        S.current.areYouSureYouWantToSwitchTo(serverAccount.name()),
                        () async {
                      ServerInfo serverDetails = UserInfoManager.serverInfo;
                      final DBConnection conn = ErmisDB.getConnection();

                      List<LocalAccountInfo> localAccounts = await conn.getUserAccounts(serverDetails);
                      LocalAccountInfo? matchingAccount;

                      for (LocalAccountInfo localAccount in localAccounts) {
                        if (localAccount.email == serverAccount.email) {
                          matchingAccount = localAccount;
                        }
                      }

                      // Pick arbitrary parameters in case of no match
                      matchingAccount ??= LocalAccountInfo(
                        email: serverAccount.email,
                        passwordHash: "",
                        deviceUUID: "",
                        lastUsed: DateTime.now(),
                      );

                      Client.instance().commands?.switchAccount();
                      setupClientSession(
                        context,
                        accountInfo: matchingAccount,
                        keepPreviousRoutes: true,
                      );
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
                        pushSlideTransition(context, const AuthLandingScreen());
                      },
                      child: Text(S.current.accountAdd))
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AccountSettingsState extends State<AccountSettings> with EventBusSubscriptionMixin {
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
      appBar: ErmisAppBar(
        titleText: S.current.accountSettings,
        actions: [
          PopupMenuButton<VoidCallback>(
            position: PopupMenuPosition.under,
            onSelected: (VoidCallback callback) {
              callback();
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: () => pushSlideTransition(context, const DeleteAccountSettings()),
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Icon(
                      FontAwesomeIcons.solidTrashCan.data,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      S().accountDelete,
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.person_add_alt),
              title: Text(S.current.accountAdd),
              onTap: () async {
                await AccountSettings.showOtherAccounts(context);
              },
            ),
            Divider(),
            ListTile(
              leading: const Icon(Icons.password),
              title: Text(S.current.changePassword),
              onTap: () async {
                pushSlideTransition(context, const ChangePasswordSettings());
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.lock,
                color: Colors.redAccent,
              ),
              title: Text("Lock account"),
              onTap: () {
                showConfirmationDialog(
                  context,
                  S().areYouSure,
                  () {
                    Client.instance().commands!.logoutAllDevices();
                    resetToStartingScreen(context);
                  },
                  includeTitle: true,
                );
              },
            ),
            ListTile(
              leading: Icon(
                FontAwesomeIcons.solidTrashCan.data,
                color: Colors.redAccent,
              ),
              title: Text(S.current.accountDelete),
              onTap: () {
                pushSlideTransition(context, const DeleteAccountSettings());
              },
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
}
