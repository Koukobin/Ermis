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

import 'dart:math';

import 'package:ermis_client/core/networking/user_info_manager.dart';
import 'package:ermis_client/core/services/database/database_service.dart';
import 'package:ermis_client/core/services/database/extensions/servers_extension.dart';
import 'package:ermis_client/core/util/dialogs_utils.dart';
import 'package:ermis_client/features/settings/options/storage_and_data_settings/byte_formatter.dart';
import 'package:flutter/material.dart';

import '../../../../core/util/top_app_bar_utils.dart';
import '../../../../core/widgets/scroll/custom_scroll_view.dart';
import '../../../../theme/app_colors.dart';

class NetworkUsageScreen extends StatefulWidget {
  final int sentDataBytes;
  final int dataReceivedBytes;

  const NetworkUsageScreen({
    super.key,
    required this.sentDataBytes,
    required this.dataReceivedBytes,
  });

  @override
  State<NetworkUsageScreen> createState() => _NetworkUsageScreenState();
}

class _NetworkUsageScreenState extends State<NetworkUsageScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      appBar: ErmisAppBar(
        titleText: "Network Usage",
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(75, 20, 75, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Usage",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      formatBytes(widget.sentDataBytes + widget.dataReceivedBytes),
                      style: TextStyle(
                        fontSize: 30,
                        color: appColors.inferiorColor,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.green,
                            offset: Offset(0, 0), // No offset for a central glow
                          ),
                          Shadow(
                            blurRadius: 20.0,
                            color: Colors.greenAccent,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Sent",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              formatBytes(widget.sentDataBytes),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Received",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              formatBytes(widget.dataReceivedBytes),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(),
            ],
          ),
          Expanded(
              child: ScrollViewFixer.createScrollViewWithAppBarSafety(
                  scrollView: ListView(
            children: [
              // _unknownDataWidget(),
              fuck("Calls Usage Not Available", Icons.call_outlined),
              fuck("Media Usage Not Available", Icons.image),
              fuck("Messages Usage Not Available", Icons.message_outlined),
              fuck("Roaming Usage Not Available", Icons.public),
            ],
          ))),
          Column(
            children: [
              const Divider(),
              ListTile(
                contentPadding: const EdgeInsets.only(left: 75),
                title: Text("Reset statistics"),
                onTap: () {
                  showConfirmationDialog(
                    context,
                    "Reset network usage statistics?",
                    () {
                      ErmisDB.getConnection().resetNetworkUsage(UserInfoManager.serverInfo);
                    },
                    includeTitle: false,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget fuck(String title, IconData leadingIcon) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return ListTile(
      leading: Icon(leadingIcon),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      subtitle: LinearProgressIndicator(
        value: 0.05 + Random().nextInt(15) / 100,
        color: appColors.primaryColor,
        backgroundColor: appColors.quaternaryColor,
        borderRadius: BorderRadius.circular(32),
      ),
      trailing: const Icon(
        Icons.error_outline,
        color: Colors.redAccent,
      ),
    );
  }
}
