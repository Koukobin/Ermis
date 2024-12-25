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
import 't.dart';

String? serverUrl;

class ChooseServer extends StatefulWidget {

  final Set<ServerInfo> cachedServerUrls;

  ChooseServer(this.cachedServerUrls, {super.key}) {
    if (cachedServerUrls.isEmpty) {
      return;
    }

    serverUrl = cachedServerUrls.first.serverUrl.toString();
  }

  @override
  State<ChooseServer> createState() => ChooseServerState();
}

class ChooseServerState extends State<ChooseServer> {
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
      backgroundColor: appColors.tertiaryColor,
      appBar: const ErmisAppBar(),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 100.0, 16.0, 200.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset(
              appIconPath,
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Dropdown Menu for Server URLs
                DropdownMenu(
                  [for (final item in cachedServerUrls) item.toString()],
                ),
                const SizedBox(height: 20),
                // Add Server and Certificate Options
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        String? url = await showInputDialog(
                          context: context,
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
                          cachedServerUrls = cachedServerUrls..add(serverInfo);
                        });
                        ErmisDB.createConnection().insertServerInfo(serverInfo);
          
                        // Feedback
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Server added successfully!")),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text("Add Server", style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appColors.primaryColor,
                        foregroundColor: appColors.tertiaryColor,
                      ),
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: _checkServerCertificate,
                          onChanged: (bool? value) {
                            setState(() {
                              _checkServerCertificate = value!;
                            });
                          },
                          activeColor: appColors.primaryColor,
                        ),
                        Text(
                          "Check certificate",
                          style: TextStyle(fontSize: 16, color: appColors.primaryColor),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                // "Connect" Button
                ElevatedButton(
                  onPressed: () async {
                    Uri url = Uri.parse(serverUrl!);

                    final DBConnection conn = ErmisDB.createConnection();
                    conn.updateServerUrlLastUsed(ServerInfo(url));
                    UserAccount? userInfo = await conn.getLastUsedAccount(ServerInfo(url));
                    if (kDebugMode) {
                      debugPrint(userInfo?.email);
                      debugPrint(userInfo?.passwordHash);
                    }

                    try {
                      await Client.getInstance().initialize(
                        url,
                        _checkServerCertificate
                            ? ServerCertificateVerification.verify
                            : ServerCertificateVerification.ignore,
                      );
                    } catch (e) {
                      if (e is TlsException || e is SocketException) {
                        showExceptionDialog(context, (e as dynamic).message);
                        return;
                      }

                      rethrow;
                    }

                    setupClientSession(context, userInfo);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: appColors.inferiorColor, // Splash color
                    backgroundColor: appColors.secondaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text("Connect", style: TextStyle(fontSize: 18, color: appColors.primaryColor)),
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

  List<String> cachedServerUrls;

  DropdownMenu(this.cachedServerUrls, {super.key});

  @override
  State<DropdownMenu> createState() => _DropdownMenuState();
}

class _DropdownMenuState extends State<DropdownMenu> {

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
            items: widget.cachedServerUrls.map((String url) {
              return DropdownMenuItem<String>(
                value: url,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        url,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: appColors.primaryColor),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      splashRadius: 20,
                      onPressed: () {
                        final serverInfo = ServerInfo(Uri.parse(url));
                        ErmisDB.createConnection().removeServerInfo(serverInfo);
                        widget.cachedServerUrls = List.from(widget.cachedServerUrls)..remove(url);
                        setState(() {
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