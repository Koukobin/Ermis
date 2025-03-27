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

import 'dart:io';

import 'package:ermis_client/languages/generated/l10n.dart';
import 'package:ermis_client/core/models/app_state/new_features_page_status.dart';
import 'package:ermis_client/theme/app_colors.dart';
import 'package:ermis_client/core/services/database_service.dart';
import 'package:ermis_client/core/util/dialogs_utils.dart';
import 'package:ermis_client/core/services/settings_json.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/data_sources/api_client.dart';
import '../../constants/app_constants.dart';
import '../authentication/domain/entities/client_session_setup.dart';

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
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Container(
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
                    SizedBox(
                      width: 150,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          String? url = await showInputDialog(
                            context: context,
                            title: S.current.server_url_enter,
                            hintText: "example.com",
                          );
                          if (url == null) return;

                          ServerInfo serverInfo;

                          try {
                            serverInfo = ServerInfo(Uri.https(url));
                          } on InvalidServerUrlException catch (e) {
                            showExceptionDialog(context, e.message);
                            return;
                          }

                          setState(() {
                            cachedServerUrls.add(serverInfo);
                          });
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
                          style: TextStyle(fontSize: 16, color: appColors.primaryColor),
                        ),
                      ),
                    ),
                    // Row(
                    //   children: [
                    //     Checkbox(
                    //       value: _checkServerCertificate,
                    //       onChanged: (bool? value) {
                    //         setState(() {
                    //           _checkServerCertificate = value!;
                    //         });
                    //       },
                    //       activeColor: appColors.primaryColor,
                    //     ),
                    //     Text(
                    //       "Check certificate hello world",
                    //       style: TextStyle(
                    //           fontSize: 16, color: appColors.primaryColor),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
                const SizedBox(height: 30),
                // "Connect" Button
                ElevatedButton(
                  onPressed: _isConnectingToServer ? null : () async {
                    Uri url = Uri.parse(serverUrl!);
                    setState(() => _isConnectingToServer = true);

                    final DBConnection conn = ErmisDB.getConnection();
                    conn.updateServerUrlLastUsed(ServerInfo(url));
                    LocalAccountInfo? userInfo = await conn.getLastUsedAccount(ServerInfo(url));
                    if (kDebugMode) {
                      debugPrint(userInfo?.email);
                      debugPrint(userInfo?.passwordHash);
                    }

                    try {
                      await Client.instance().initialize(
                        url,
                        _checkServerCertificate
                            ? ServerCertificateVerification.verify
                            : ServerCertificateVerification.ignore,
                      );
                    } catch (e) {
                      setState(() => _isConnectingToServer = false);
                      if (e is TlsException || e is SocketException) {
                        await showToastDialog((e as dynamic).message);
                        return;
                      }

                      // Navigator.pushAndRemoveUntil(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (context) => MainInterface()),
                      //   (route) => false, // Removes all previous routes.
                      // );

                      rethrow;
                    }

                    setupClientSession(context, userInfo);
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
  /// UniqueKey used to refresh dropdown menu (i.e force rebuild) when a URL is deleted
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

class WhatsNewScreen extends StatelessWidget {
  const WhatsNewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.whats_new),
        backgroundColor: Color(0xFF4CAF50),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.current.whats_new_title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(height: 20),
            // Feature List
            ListTile(
              leading: const Icon(Icons.add, color: Color(0xFF4CAF50)),
              title: Text(S.current.feature_encryption),
            ),
            ListTile(
              leading: const Icon(Icons.language, color: Color(0xFF4CAF50)),
              title: Text(S.current.feature_languages),
            ),
            ListTile(
              leading: const Icon(Icons.call, color: Color(0xFF4CAF50)),
              title: Text(S.current.feature_voice_calls),
            ),
            const SizedBox(height: 30),
            // Dismiss Button
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4CAF50),
                ),
                onPressed: Navigator.of(context).pop,
                child: Text(
                  S.current.got_it_button,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
