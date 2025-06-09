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
import 'package:ermis_client/generated/l10n.dart';
import 'package:flutter/material.dart';

import '../../../../core/util/top_app_bar_utils.dart';
import '../../../../core/widgets/scroll/custom_scroll_view.dart';
import '../../../../theme/app_colors.dart';

class NetworkUsageScreen extends StatefulWidget {
  final ValueNotifier<int> sentDataBytes;
  final ValueNotifier<int> dataReceivedBytes;

  const NetworkUsageScreen({
    super.key,
    required this.sentDataBytes,
    required this.dataReceivedBytes,
  });

  @override
  State<NetworkUsageScreen> createState() => _NetworkUsageScreenState();
}

extension on ValueNotifier<int> {
  int operator +(ValueNotifier<int> other) {
    return value + other.value;
  }
}

class _NetworkUsageScreenState extends State<NetworkUsageScreen> {

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      appBar: ErmisAppBar(
        titleText: S().network_usage,
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
                      S().usage_capitalized,
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
                              S().sent_capitalized,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            ValueListenableBuilder(
                                valueListenable: widget.sentDataBytes,
                                builder: (context, value, child) {
                                  return Text(
                                    formatBytes(value),
                                    style: const TextStyle(fontSize: 16),
                                  );
                                }),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              S().received_capitalized,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            ValueListenableBuilder(
                              valueListenable: widget.dataReceivedBytes,
                              builder: (context, value, child) {
                                return Text(
                                  formatBytes(value),
                                  style: const TextStyle(fontSize: 16),
                                );
                              }
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
              fuck(S().calls_usage_not_available, Icons.call_outlined),
              fuck(S().media_usage_not_available, Icons.image),
              fuck(S().messages_usage_not_available, Icons.message_outlined),
              fuck(S().roaming_usage_not_available, Icons.public),
            ],
          ))),
          Column(
            children: [
              const Divider(),
              ListTile(
                contentPadding: const EdgeInsets.only(left: 75),
                title: Text(S().reset_statistics),
                onTap: () {
                  showConfirmationDialog(
                    context,
                    S().reset_network_usage_statistics,
                    () {
                      ErmisDB.getConnection().resetNetworkUsage(UserInfoManager.serverInfo);
                      setState(() {
                        widget.sentDataBytes.value = 0;
                        widget.dataReceivedBytes.value = 0;
                      });
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
