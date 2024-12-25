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

import 'package:ermis_client/util/top_app_bar_utils.dart';
import 'package:flutter/material.dart';

import '../../client/common/exceptions/EnumNotFoundException.dart';

class NotificationSettings extends StatefulWidget {
  const NotificationSettings({super.key});

  @override
  State<NotificationSettings> createState() => _NotificationSettingsState();
}

enum NotificationSound {
  osDefault(name: "OS default", id: 1),
  bell(name: "Bell", id: 2);

  final String name;

  /// This is used to identify each chat backdrop by its id
  final int id;

  const NotificationSound({required this.name, required this.id});

  static NotificationSound fromId(int id) {
    try {
      return NotificationSound.values.firstWhere((type) => type.id == id);
    } catch (e) {
      throw EnumNotFoundException('No NotificationSound found for id $id');
    }
  }
}

class _NotificationSettingsState extends State<NotificationSettings> {
  bool _notificationsEnabled = true;
  bool _messagePreviewEnabled = true;
  NotificationSound _selectedSound = NotificationSound.osDefault;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ErmisAppBar(
        title: const Text(
          "Notification Settings",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Enable/Disable Notifications
          SwitchListTile(
            title: const Text("Enable Notifications"),
            value: _notificationsEnabled,
            onChanged: (bool value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),

          // Enable/Disable Message Previews
          SwitchListTile(
            title: const Text("Show Message Previews"),
            subtitle: const Text("Display part of the message in notifications"),
            value: _messagePreviewEnabled,
            onChanged: (bool value) {
              setState(() {
                _messagePreviewEnabled = value;
              });
            },
          ),

          // Notification Sound Selection
          ListTile(
            title: const Text("Notification Sound"),
            subtitle: Text(_selectedSound.name),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showSoundSelectionDialog();
            },
          ),

          // Additional Settings (if any)
          const Divider(),
          const Text(
            "Other Settings",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ListTile(
            title: const Text("Vibration"),
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // Handle vibration toggle
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showSoundSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select Notification Sound"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: NotificationSound.values.map((NotificationSound sound) {
              return RadioListTile<NotificationSound>(
                title: Text(sound.name),
                value: sound,
                groupValue: _selectedSound,
                onChanged: (NotificationSound? value) {
                  setState(() {
                    _selectedSound = value!;
                  });
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
