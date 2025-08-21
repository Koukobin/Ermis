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
import 'package:ermis_mobile/core/models/app_state/new_features_page_status.dart';
import 'package:ermis_mobile/theme/app_colors.dart';
import 'package:ermis_mobile/core/services/database/database_service.dart';
import 'package:ermis_mobile/core/util/dialogs_utils.dart';
import 'package:ermis_mobile/core/services/settings_json.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/data_sources/api_client.dart';
import '../../constants/app_constants.dart';
import '../../core/services/url_launcher.dart';
import '../../main.dart';
import '../authentication/domain/entities/client_session_setup.dart';
import 'whats_new_screen.dart';

String? serverUrl;

class ChooseServerScreen extends StatefulWidget {
  final Set<ServerInfo> cachedServerUrls;

  ChooseServerScreen(this.cachedServerUrls, {super.key}) {
    serverUrl = cachedServerUrls.firstOrNull?.toString();
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

    NewFeaturesPageStatus status = SettingsJson().newFeaturesPageStatus;
    if (status.hasShown && status.version == AppConstants.applicationVersion) {
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

    status.hasShown = true;
    status.version = AppConstants.applicationVersion;

    SettingsJson()
      ..setHasShownNewFeaturesPage(status)
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

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    Widget buildHowToConfigureYourOwnServerInstanceUrlLauncher() {
      return Padding(
        padding: const EdgeInsets.only(top: 25),
        child: Column(
          children: [
            IconButton.outlined(
              onPressed: () {
                UrlLauncher.launchURL(
                  context,
                  AppConstants.configureServerURL,
                );
              },
              icon: const Icon(Icons.question_mark),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 120),
              child: Text(
                S().how_to_configure_your_own_server,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Stack(
        alignment: Alignment.topRight,
        children: [
          buildConnectToServer(appColors),
          buildHowToConfigureYourOwnServerInstanceUrlLauncher(),
        ],
      ),
    );
  }

  Widget buildConnectToServer(AppColors appColors) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 100.0, 16.0, 200.0),
      decoration: BoxDecoration(
          gradient: LinearGradient(
        colors: [
          appColors.secondaryColor,
          isDarkMode ? Colors.black : Colors.white,
          Color(0xFF00FF00), // Neon green glow
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
              DropdownMenu(cachedServerUrls),
              const SizedBox(height: 20),
              // Add Server and Certificate Options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      String url = await showInputDialog(
                        context: context,
                        title: S.current.server_url_enter,
                        hintText: "example.com",
                      );
                  
                      if (url.isEmpty) return;
                  
                      ServerInfo serverInfo;
                      try {
                        Uri buildUri(String url) => url.startsWith('http')
                            ? Uri.parse(url)
                            : Uri.https(url);
                  
                        serverInfo = ServerInfo(buildUri(url));
                      } on InvalidServerUrlException catch (e) {
                        showExceptionDialog(context, e.message);
                        return;
                      }
                  
                      setState(() => cachedServerUrls.add(serverInfo));
                      ErmisDB.getConnection().insertServerInfo(serverInfo);
                  
                      // Feedback
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(S.current.server_add_success)),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: Text(
                      softWrap: true,
                      S.current.server_add,
                      style: const TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appColors.primaryColor,
                      foregroundColor: appColors.tertiaryColor,
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
                        S.current.server_certificate_check,
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
                onPressed: _isConnectingToServer
                    ? null
                    : () async {
                        // Reset information to ensure nothing leaks from previous sessions
                        UserInfoManager.resetServerInformation();
                        UserInfoManager.resetUserInformation();
                        await Client.instance().disconnect();

                        Uri url = Uri.parse(serverUrl!);
                        setState(() => _isConnectingToServer = true);

                        ServerInfo serverInfo = ServerInfo(url);

                        final DBConnection conn = ErmisDB.getConnection();
                        conn.updateServerUrlLastUsed(serverInfo);

                        try {
                          await Client.instance().initialize(
                            url,
                            _checkServerCertificate
                                ? ServerCertificateVerification.verify
                                : ServerCertificateVerification.ignore,
                          );
                        } catch (e) {
                          UserInfoManager.serverInfo = serverInfo;
                          await UserInfoManager.fetchProfileInformation();
                          await UserInfoManager.fetchLocalChatSessions();

                          // Navigate to the main interface
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MainInterface()),
                            (route) => false, // Removes all previous routes.
                          );

                          if (e is SocketException) {
                            await showToastDialog(S.current.connection_refused);
                            return;
                          }

                          if (e is ServerVerificationFailedException) {
                            await showToastDialog(
                                S.current.could_not_verify_server_certificate);
                            return;
                          }

                          rethrow;
                        }

                        setupClientSession(context);
                      },
                style: ElevatedButton.styleFrom(
                  foregroundColor: appColors.inferiorColor, // Splash color
                  backgroundColor: appColors.secondaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(S.current.connect,
                    style: TextStyle(
                      fontSize: 18,
                      color: appColors.primaryColor,
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DropdownMenu extends StatefulWidget {
  final Set<ServerInfo> cachedServerUrls;
  const DropdownMenu(this.cachedServerUrls, {super.key});

  @override
  State<DropdownMenu> createState() => _DropdownMenuState();
}

class _DropdownMenuState extends State<DropdownMenu> {
  /// [UniqueKey] used to refresh dropdown menu (i.e force rebuild) when a URL is deleted
  Key _widgetKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final borderRadius = BorderRadius.circular(8.0);

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: appColors.secondaryColor.withOpacity(0.1),
          borderRadius: borderRadius,
          border: Border.all(color: appColors.primaryColor, width: 1.5),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            key: _widgetKey,
            hint: Text(
              S.current.server_url_choose,
              style: TextStyle(
                color: appColors.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            value: serverUrl,
            isExpanded: true,
            onChanged: (String? selectedUrl) {
              setState(() {
                serverUrl = selectedUrl!;
              });
            },
            dropdownColor: appColors.secondaryColor.withOpacity(0.9),
            style: TextStyle(
              color: appColors.primaryColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            icon: Icon(
              Icons.arrow_drop_down,
              color: appColors.primaryColor,
            ),
            items: widget.cachedServerUrls.map((ServerInfo server) {
              return DropdownMenuItem<String>(
                value: server.toString(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        server.toString(),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: appColors.primaryColor),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      splashRadius: 20,
                      onPressed: () {
                        ErmisDB.getConnection().removeServerInfo(server);
                        setState(() {
                          widget.cachedServerUrls.remove(server);

                          // To ensure an error is not thrown by dropdown menu because
                          // it cannot find selected item - i.e serverUrl - assign it to null
                          if (serverUrl == server.toString()) {
                            serverUrl = null;
                          }

                          _widgetKey = UniqueKey();
                        });
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
