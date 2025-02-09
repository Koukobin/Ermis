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

import 'package:ermis_client/util/database_service.dart';
import 'package:ermis_client/util/dialogs_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../client/client.dart';
import '../constants/app_constants.dart';
import '../theme/app_theme.dart';
import '../util/top_app_bar_utils.dart';
import 'client_session_setup.dart';

String? serverUrl;

class ChooseServer extends StatefulWidget {
  final Set<ServerInfo> cachedServerUrls;

  ChooseServer(this.cachedServerUrls, {super.key}) {
    serverUrl = cachedServerUrls.firstOrNull?.toString();
    // Above one-liner is equivalent to:
    // `if (cachedServerUrls.isEmpty) {
    //   return;
    // }
    // serverUrl = cachedServerUrls.first.serverUrl.toString();`
  }

  @override
  State<ChooseServer> createState() => ChooseServerState();
}

class ChooseServerState extends State<ChooseServer> with TickerProviderStateMixin {
  Set<ServerInfo> cachedServerUrls = {};
  bool _checkServerCertificate = false;

  @override
  void initState() {
    super.initState();
    cachedServerUrls = widget.cachedServerUrls;
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.fromLTRB(16.0, 100.0, 16.0, 200.0),
        decoration: BoxDecoration(
            gradient: LinearGradient(
          colors: [
            appColors.secondaryColor,
            Color(0xFF002200), // Very dark green
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
                        String? url = await showInputDialog(
                          context: context,
                          vsync: this,
                          title: "Enter Server URL",
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
                          SnackBar(content: Text("Server added successfully!")),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text("Add Server",
                          style: TextStyle(fontSize: 16)),
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
                          "Check certificate",
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
                const SizedBox(
                  height: 30,
                ),
                // "Connect" Button
                ElevatedButton(
                  onPressed: () async {
                    Uri url = Uri.parse(serverUrl!);

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
                  child: Text("Connect",
                      style: TextStyle(
                          fontSize: 18, color: appColors.primaryColor)),
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
              "Choose server URL",
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
