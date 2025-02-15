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


import 'package:flutter/material.dart';

import '../client/client.dart';
import '../main.dart';
import '../util/database_service.dart';
import '../util/dialogs_utils.dart';
import 'entry/entry_interface.dart';

Future<void> setupClientSession(BuildContext context, LocalAccountInfo? userInfo) async {
  await Client.instance().syncWithServer();
  
  if (userInfo == null) {
    // Navigate to the Registration interface
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => CreateAccountInterface()),
      (route) => false, // Removes all previous routes.
    );
    return;
  }
  bool success = await showLoadingDialog(context, Client.instance().attemptHashedLogin(userInfo));

  if (!success) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => CreateAccountInterface()),
      (route) => false, // Removes all previous routes.
    );
    return;
  }

  Client.instance().startMessageHandler();
  await showLoadingDialog(context, Client.instance().fetchUserInformation());
  // Navigate to the main interface
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => MainInterface()),
    (route) => false, // Removes all previous routes.
  );
}
