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

import 'package:ermis_client/client/app_event_bus.dart';
import 'package:ermis_client/client/common/user_device.dart';
import 'package:ermis_client/client/message_events.dart';
import 'package:ermis_client/generated/l10n.dart';
import 'package:ermis_client/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../client/client.dart';
import '../../util/dialogs_utils.dart';
import '../../util/top_app_bar_utils.dart';

class LinkedDevicesScreen extends StatefulWidget {
  const LinkedDevicesScreen({super.key});

  @override
  State<LinkedDevicesScreen> createState() => LinkedDevicesScreenState();
}

class LinkedDevicesScreenState extends State<LinkedDevicesScreen> {
  List<UserDeviceInfo> devices = Client.instance().userDevices;

  @override
  void initState() {
    super.initState();

    AppEventBus.instance.on<UserDevicesEvent>().listen((event) async {
      setState(() {
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
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      appBar: ErmisAppBar(titleText: S.current.linked_devices),
      body: Column(
        children: [
          Flexible(
            child: devices.isNotEmpty ? ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];
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
                      subtitle: Text('IP: ${device.ipAddress}'),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'logout') {
                            showLogoutConfirmationDialog(context,
                                S.current.are_you_sure_you_want_to_logout_from(device.formattedInfo()),
                                () {
                              Client.instance()
                                  .commands
                                  .logoutOtherDevice(device.ipAddress);
                            });
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: S.current.logout,
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
                              .logoutOtherDevice(device.ipAddress);
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
                Client.instance().commands.logoutAllDevices();
                SystemNavigator.pop();
              });
            },
          )
        ],
      ),
    );
  }

}