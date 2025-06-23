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

import 'package:ermis_client/core/networking/user_info_manager.dart';
import 'package:ermis_client/core/services/database/extensions/accounts_extension.dart';
import 'package:ermis_client/core/services/database/models/local_account_info.dart';
import 'package:flutter/foundation.dart';

import '../../../../constants/app_constants.dart';
import '../../../../generated/l10n.dart';
import 'package:flutter/material.dart';

import '../../../../core/data_sources/api_client.dart';
import '../../../../main.dart';
import '../../../../core/services/database/database_service.dart';
import '../../../../core/util/dialogs_utils.dart';
import '../../register_interface.dart';

/// Setups client session in accordance to the most recently used accounts associated with server
Future<void> setupClientSession(BuildContext context, {LocalAccountInfo? accountInfo, bool keepPreviousRoutes = false}) async {
  String serverVersion = await Client.instance().readServerVersion();

  // Check if the first digit of the application version - which is also the most significant -
  // matches the server version. For instance, app version 1.x.x should be compatible
  // (theoretically at least) with server version 1.y.z; but not
  // with server version 2.0.0! (Using "!" to avoid ambiguity with version dots)
  if (AppConstants.applicationVersion.codeUnitAt(0) != serverVersion.codeUnitAt(0)) {
    showToastDialog(S.current.incompatible_server_version_warning);
  }

  Client.instance().startMessageDispatcher();

  bool authenticationSuccess = false;
  if (accountInfo == null) {
    final DBConnection conn = ErmisDB.getConnection();
    List<LocalAccountInfo> userAccounts = await conn.getUserAccounts(UserInfoManager.serverInfo);

    for (LocalAccountInfo userInfo in userAccounts) {
      if (kDebugMode) {
        debugPrint(userInfo.email);
        debugPrint(userInfo.passwordHash);
      }

      authenticationSuccess = await showLoadingDialog(
        context,
        Client.instance().attemptHashedLogin(userInfo),
      );

      if (authenticationSuccess) break;
    }
  } else {
    authenticationSuccess = await showLoadingDialog(
      context,
      Client.instance().attemptHashedLogin(accountInfo),
    );
  }

  if (!authenticationSuccess) {
    // Navigate to the Registration interface
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const CreateAccountInterface()),
      (route) => keepPreviousRoutes, // Removes all previous routes.
    );
    return;
  }

  await showLoadingDialog(context, Client.instance().fetchUserInformation());
  // Navigate to the main interface
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const MainInterface()),
    (route) => false, // Removes all previous routes.
  );
}
