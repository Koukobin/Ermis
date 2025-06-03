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
import 'package:ermis_client/core/services/database/database_service.dart';
import 'package:ermis_client/core/services/database/extensions/servers_extension.dart';
import 'package:ermis_client/core/services/settings_json.dart';
import 'package:ermis_client/core/util/top_app_bar_utils.dart';
import 'package:ermis_client/generated/l10n.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/scroll/custom_scroll_view.dart';

class StorageAndDataScreen extends StatefulWidget {
  const StorageAndDataScreen({super.key});

  @override
  State<StorageAndDataScreen> createState() => _StorageAndDataScreenState();
}

class _StorageAndDataScreenState extends State<StorageAndDataScreen> {
  bool useLessDataForCalls = false;
  int utilizedStorageByServerData = 0;
  
  int dataSent = 0;
  int dataReceived = 0;

  @override
  void initState() {
    super.initState();
    
    ErmisDB.getConnection()
        .getByteSize(UserInfoManager.serverInfo)
        .then((int totalBytes) {
      setState(() {
        utilizedStorageByServerData = totalBytes;
      });
    });

    ErmisDB.getConnection()
        .getDataBytesSent(UserInfoManager.serverInfo)
        .then((int totalBytes) {
      setState(() {
        dataSent = totalBytes;
      });
    });

    ErmisDB.getConnection()
        .getDataBytesReceived(UserInfoManager.serverInfo)
        .then((int totalBytes) {
      setState(() {
        dataReceived = totalBytes;
      });
    });

    Future(() async {
      SettingsJson settingsJson = SettingsJson();
      await settingsJson.loadSettingsJson();

      setState(() {
        useLessDataForCalls = settingsJson.useLessDataForCallsEnabled;
      });
    });
  }

  String formatBytes(int bytes) {
    String roundNum(num n) => n.toStringAsFixed(3);

    double kilobytes = bytes / 1024;
    if (kilobytes < 1) return "$bytes B";

    double megabytes = kilobytes / 1024;
    if (megabytes < 1) return "${roundNum(kilobytes)} KB";

    double gigabytes = megabytes / 1024;
    if (gigabytes < 1) return "${roundNum(megabytes)} MB";

    return "$gigabytes GB";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ErmisAppBar(titleText: "Storage and Data"),
      body: ScrollViewFixer.createScrollViewWithAppBarSafety(
          scrollView: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.storage),
            title: Text("Manage Storage"),
            subtitle: Text("${formatBytes(utilizedStorageByServerData)} used"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.network_check),
            title: Text("Network Usage"),
            subtitle: Text("${formatBytes(dataSent)} sent • ${formatBytes(dataReceived)} received"),
            onTap: () {},
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Media Auto-Download",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            title: Text("When using mobile data"),
            subtitle: Text("Photos"),
            enabled: false,
            onTap: () {
              _showRadioListTileDialog(title: "When using mobile data", tiles: [
                RadioListTile(
                  title: Text("balls"),
                  value: "value",
                  groupValue: "groupValue",
                  onChanged: (e) {},
                )
              ]);
            },
          ),
          ListTile(
            title: Text("When connected on Wi-Fi"),
            subtitle: Text("All media"),
            enabled: false,
            onTap: () {},
          ),
          ListTile(
            title: Text("When roaming"),
            subtitle: Text("No media"),
            enabled: false,
            onTap: () {},
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Call Settings",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            title: Text("Use less data for calls"),
            value: useLessDataForCalls,
            onChanged: (bool value) {
              setState(() {
                useLessDataForCalls = value;
              });

              SettingsJson().setUseLessDataForCallsEnabled(useLessDataForCalls);
              SettingsJson().saveSettingsJson();
            },
          ),
        ],
      )),
    );
  }

  void _showRadioListTileDialog({
    required String title,
    required List<RadioListTile> tiles,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: tiles,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Cancel
              child: Text(S.current.cancel, style: const TextStyle(fontSize: 18)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Confirm
              child: Text(S.current.ok, style: const TextStyle(fontSize: 18)),
            ),
          ],
        );
      },
    );
  }
}