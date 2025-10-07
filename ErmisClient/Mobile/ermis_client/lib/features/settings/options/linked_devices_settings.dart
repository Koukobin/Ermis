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

import 'package:ermis_mobile/core/event_bus/app_event_bus.dart';
import 'package:ermis_mobile/core/models/user_device.dart';
import 'package:ermis_mobile/core/models/message_events.dart';
import 'package:ermis_mobile/core/networking/user_info_manager.dart';
import 'package:ermis_mobile/core/widgets/loading_state.dart';
import 'package:ermis_mobile/mixins/event_bus_subscription_mixin.dart';
import 'package:ermis_mobile/core/widgets/dots_loading_screen.dart';
import 'package:ermis_mobile/generated/l10n.dart';
import 'package:ermis_mobile/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/data_sources/api_client.dart';
import '../../../core/util/dialogs_utils.dart';
import '../../../core/util/top_app_bar_utils.dart';
import '../../../core/widgets/scroll/custom_scroll_view.dart';

class LinkedDevicesScreen extends StatefulWidget {
  const LinkedDevicesScreen({super.key});

  @override
  State<LinkedDevicesScreen> createState() => LinkedDevicesScreenState();
}

class LinkedDevicesScreenState extends LoadingState<LinkedDevicesScreen> with EventBusSubscriptionMixin {
  List<UserDeviceInfo>? devices = Client.instance().userDevices;

  @override
  void initState() {
    super.initState();

    devices ?? Client.instance().commands?.fetchDevices();
    isLoading = devices == null;

    subscribe(AppEventBus.instance.on<UserDevicesEvent>(), (event) {
      setState(() {
        isLoading = false;
        devices = event.devices;
      });
    });
  }

 /*
 ListView.separated( // Use ListView.separated for better dividers
                      itemCount: devices.length,
                      separatorBuilder: (context, index) => const Divider(height: 1), // Thin dividers
                      itemBuilder: (context, index) {
                        final device = devices[index];
                        IconData deviceIcon = switch (device.deviceType) {
                          DeviceType.mobile => Icons.smartphone,
                          DeviceType.desktop => Icons.computer,
                          DeviceType.tablet => Icons.tablet,
                          DeviceType.unknown => Icons.device_unknown_outlined
                        };

                        return ListTile(
                          leading: Icon(deviceIcon, color: appColors.primaryColor),
                          title: Text(device.osName),
                          subtitle: Text('IP: ${device.ipAddress}'),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'logout') {
                                showLogoutConfirmationDialog(
                                    context,
                                    'Are you sure you want to logout from ${device.formattedInfo()}?',
                                    () {
                                  Client.instance()
                                      .commands
                                      .logoutOtherDevice(device.ipAddress);
                                });
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'logout',
                                child: Row(
                                  children: [
                                    const Icon(Icons.logout, color: Colors.red), // Changed to logout icon
                                    const SizedBox(width: 8),
                                    Text(S.current.logout_capitalized),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            showLogoutConfirmationDialog(
                                context,
                                'Are you sure you want to logout from ${device.formattedInfo()}?',
                                () {
                              Client.instance()
                                  .commands
                                  .logoutOtherDevice(device.ipAddress);
                            });
                          },
                        );
                      },
                    ) 
                    */

  @override
  Widget build0(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      appBar: ErmisAppBar(titleText: S.current.linked_devices),
      body: ScrollViewFixer.createScrollViewWithAppBarSafety(
          scrollView: Column(
        children: [
          Flexible(
            child: devices!.length > 1 ? ListView.builder(
              itemCount: devices!.length,
              itemBuilder: (context, index) {
                final device = devices![index];

                // Exclude self
                if (device.deviceUUID == UserInfoManager.accountInfo!.deviceUUID) {
                  return const SizedBox.shrink();
                }

                IconData deviceIcon = switch (device.deviceType) {
                  DeviceType.mobile => Icons.smartphone,
                  DeviceType.desktop => Icons.computer,
                  DeviceType.tablet => Icons.tablet,
                  DeviceType.unknown => Icons.device_unknown_outlined
                };
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    color: appColors.tertiaryColor,
                    child: ListTile(
                      leading: Icon(deviceIcon, color: appColors.primaryColor),
                      title: Text(device.osName),
                      subtitle: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: SensitiveContent(
                              sensitivity: ContentSensitivity.sensitive,
                              child: Text('UUID: ${device.deviceUUID}',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                            )),

                          // Widget to hide rest of UUID for security reasons
                          Text(
                            '##############',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'logout') {
                            showLogoutConfirmationDialog(context,
                                S.current.are_you_sure_you_want_to_logout_from(device.formattedInfo()),
                                () {
                              Client.instance()
                                  .commands
                                  ?.logoutOtherDevice(device.deviceUUID);
                            });
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'logout',
                            child: Row(
                              children: [
                                const Icon(Icons.delete, color: Colors.red),
                                const SizedBox(width: 8),
                                Text(S.current.logout_capitalized),
                              ],
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        showLogoutConfirmationDialog(context,
                             S.current.are_you_sure_you_want_to_logout_from(device.formattedInfo()),
                            () {
                          Client.instance()
                              .commands
                              ?.logoutOtherDevice(device.deviceUUID);
                        });
                      },
                    ),
                  ),
                );
              },
            ) : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_off, size: 120, color: Colors.grey[400]), // Changed icon
                          const SizedBox(height: 16),
                          Text(
                            S.current.no_linked_devices, // Assuming you have this localization
                            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            S.current.link_new_device, // Assuming you have this localization
                            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.dangerous_outlined,
              size: 30,
              color: Colors.redAccent,
            ),
            title: Center(
              child: Text(
                S.current.logout_from_all_devices,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            onTap: () {
              showLogoutConfirmationDialog(context, S.current.are_you_sure_you_want_to_logout_from_all_devices,
                  () {
                Client.instance().commands?.logoutAllDevices();
                SystemNavigator.pop();
              });
            },
          )
        ],
      )),
    );
  }
  
  @override
  Widget buildLoadingScreen() {
    return Scaffold(
      appBar: ErmisAppBar(titleText: S.current.linked_devices),
      body: const DotsLoadingScreen(),
    );
  }
}
