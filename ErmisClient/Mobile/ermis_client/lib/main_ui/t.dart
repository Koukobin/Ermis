
import 'package:flutter/material.dart';

import '../client/client.dart';
import '../main.dart';
import '../util/database_service.dart';
import '../util/dialogs_utils.dart';
import 'entry/entry_interface.dart';

Future<void> setupClientSession(BuildContext context, UserAccount? userInfo) async {

  if (userInfo == null) {
    // Navigate to the Registration interface
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => CreateAccountInterface()),
      (route) => false, // Removes all previous routes.
    );
    return;
  }

  await Client.getInstance().syncWithServer();

  bool success = await showLoadingDialog(context, Client.getInstance().attemptShallowLogin(userInfo));

  if (!success) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => CreateAccountInterface()),
      (route) => false, // Removes all previous routes.
    );
    return;
  }

  Client.getInstance().startMessageHandler();
  await showLoadingDialog(context, Client.getInstance().fetchUserInformation());
  // Navigate to the main interface
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => MainInterface()),
    (route) => false, // Removes all previous routes.
  );
}
