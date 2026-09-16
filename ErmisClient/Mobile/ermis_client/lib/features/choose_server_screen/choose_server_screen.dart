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
import 'dart:io';

import 'package:ermis_mobile/core/networking/user_info_manager.dart';
import 'package:ermis_mobile/core/services/database/extensions/servers_extension.dart';
import 'package:ermis_mobile/core/services/database/models/server_info.dart';
import 'package:ermis_mobile/generated/l10n.dart';
import 'package:ermis_mobile/theme/app_colors.dart';
import 'package:ermis_mobile/core/services/database/database_service.dart';
import 'package:ermis_mobile/core/util/dialogs_utils.dart';
import 'package:ermis_mobile/core/services/settings_json.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/data_sources/api_client.dart';
import '../../constants/app_constants.dart';
import '../../core/models/app_state/whats_new_status.dart';
import '../../main.dart';
import '../authentication/domain/entities/client_session_setup.dart';
import 'configure_own_server_button.dart';
import 'servers_dropdown_menu.dart';
import 'whats_new_screen.dart';

final ValueNotifier<String?> selectedServerUrl = ValueNotifier<String?>(null);

class ChooseServerScreen extends StatefulWidget {
  final Set<ServerInfo> cachedServerUrls;

  ChooseServerScreen(this.cachedServerUrls, {super.key}) {
    selectedServerUrl.value = cachedServerUrls.firstOrNull?.toString();
    // Above one-liner is equivalent to:
    // `if (cachedServerUrls.isEmpty) {
    //   return;
    // }
    // serverUrl = cachedServerUrls.first.serverUrl.toString();`
  }

  @override
  State<ChooseServerScreen> createState() => ChooseServerScreenState();
}

class ChooseServerScreenState extends State<ChooseServerScreen> {
  Set<ServerInfo> cachedServerUrls = {};
  bool _checkServerCertificate = false;
  bool _isConnectingToServer = false;

  @override
  void initState() {
    super.initState();
    cachedServerUrls = widget.cachedServerUrls;

    WhatsNewStatus status = SettingsJson().whatsNewStatus;
    if (status.hasSeen && status.lastSeenVersion == AppConstants.applicationVersion) {
      if (kReleaseMode) return;

      // Many prints to ensure message is visible on terminal
      debugPrint("NewFeaturesPage would not have been shown in production built!");
      debugPrint("NewFeaturesPage would not have been shown in production built!");
      debugPrint("NewFeaturesPage would not have been shown in production built!");
      debugPrint("NewFeaturesPage would not have been shown in production built!");
      debugPrint("NewFeaturesPage would not have been shown in production built!");
      debugPrint("NewFeaturesPage would not have been shown in production built!");
      debugPrint("NewFeaturesPage would not have been shown in production built!");
      debugPrint("NewFeaturesPage would not have been shown in production built!");
    }

    status.hasSeen = true;
    status.lastSeenVersion = AppConstants.applicationVersion;

    SettingsJson()
      ..setWhatsNewStatus(status)
      ..saveSettingsJson();
    Future.delayed(const Duration(milliseconds: 500), () {
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (BuildContext context) {
          return const WhatsAppPopupDialog(child: WhatsNewScreen());
        },
      );
    });
  }

  void connectToServer() async {
    // Disconnect & reset information to ensure
    // nothing leaks from previous sessions
    await Client.instance().disconnect();

    setState(() => _isConnectingToServer = true);

    ServerInfo serverInfo = ServerInfo(selectedServerUrl.value!);

    final DBConnection conn = ErmisDB.getConnection();
    conn.updateServerUrlLastUsed(serverInfo);

    try {
      await Client.instance().initialize(
        serverInfo,
        _checkServerCertificate
            ? ServerCertificateVerification.verify
            : ServerCertificateVerification.ignore,
      );
    } catch (e) {
      UserInfoManager.serverInfo = serverInfo;
      await UserInfoManager.fetchProfileInformation();
      await UserInfoManager.fetchLocalChatSessions();

      void pushToMainInterface() {
        // Navigate to the main interface
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => const MainInterface()),
          (route) => false, // Removes all previous routes.
        );
      }

      if (e is ServerVerificationFailedException) {
        bool $continue = false;
        await showConfirmationDialog(
          context,
          S.current.couldNotVerifyServerCertificate,
          () => $continue = true,
          includeTitle: true,
        );
        if (!$continue) {
          setState(() => _isConnectingToServer = false);
          return;
        }

        _checkServerCertificate = false;
        connectToServer();
        return;
      }

      if (e is SocketException) {
        await showToastDialog(S.current.connectionRefused);
        pushToMainInterface();
        return;
      }

      if (kDebugMode) print(e);

      setState(() => _isConnectingToServer = false);
      return;
    }

    try {
      await setupClientSession(context);
    } on Exception catch (te) {
      if (kDebugMode) debugPrint(te.toString());

      showToastDialog(S.current.connectionFailure);
      setState(() => _isConnectingToServer = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      body: Stack(
        alignment: Alignment.topRight,
        children: [
          buildConnectToServer(appColors),
          ConfigureOwnServerButton(shouldPulse: cachedServerUrls.isEmpty),
        ],
      ),
    );
  }

  Widget buildConnectToServer(AppColors appColors) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 100.0, 16.0, 200.0),
      decoration: BoxDecoration(
          gradient: LinearGradient(
        colors: [
          appColors.secondaryColor,
          isDarkMode ? Colors.black : Colors.white,
          colorScheme.primary, // Neon green glow
        ],
        begin: Alignment.topRight,
        end: Alignment.bottomCenter,
      )),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.asset(
            AppConstants.appIconPath,
            width: 100,
            height: 100,
          ),
          const SizedBox(height: 20),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Dropdown Menu for Server URLs
              ServersDropdownMenu(
                cachedServerUrls: cachedServerUrls,
                verifiedServers: AppConstants.verifiedServers,
                selectedServerUrl: selectedServerUrl,
              ),
              const SizedBox(height: 20),
              // Add Server and Certificate Options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Constrain size of button to ensure other widgets are
                  // not out of bounds in devices with large text fonts
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.5,
                      maxHeight: MediaQuery.of(context).size.height * 0.1,
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        String url = await showInputDialog(
                          context: context,
                          title: S.current.enterServerUrl,
                          hintText: "example.com",
                        );
                    
                        if (url.isEmpty) return;
                    
                        ServerInfo serverInfo;
                        try {
                          serverInfo = ServerInfo(url);
                        } on InvalidServerUrlException catch (e) {
                          showExceptionDialog(context, e.message);
                          return;
                        }
                    
                        setState(() => cachedServerUrls.add(serverInfo));
                        ErmisDB.getConnection().insertServerInfo(serverInfo);
                    
                        // Feedback
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(S.current.serverAddedSuccess)),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: Text(
                        softWrap: true,
                        S.current.serverAdd,
                        style: const TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appColors.primaryColor,
                        foregroundColor: appColors.tertiaryColor,
                      ),
                    ),
                  ),
                  Expanded(
                    child: CheckboxListTile(
                      value: _checkServerCertificate,
                      onChanged: (bool? value) {
                        setState(() {
                          _checkServerCertificate = value!;
                        });
                      },
                      activeColor: appColors.primaryColor,
                      title: Text(
                        S.current.checkCertificate,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 16,
                          color: appColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // "Connect" Button
              ElevatedButton(
                onPressed: _isConnectingToServer ? null : connectToServer,
                style: ElevatedButton.styleFrom(
                  foregroundColor: appColors.inferiorColor, // Splash color
                  backgroundColor: appColors.secondaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(S.current.connect,
                    style: TextStyle(
                      fontSize: 18,
                      color: _isConnectingToServer
                          ? appColors.secondaryColor
                          : appColors.primaryColor,
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}