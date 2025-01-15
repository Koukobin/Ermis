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

import 'package:ermis_client/util/dialogs_utils.dart';
import 'package:ermis_client/util/top_app_bar_utils.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

import '../../client/common/exceptions/EnumNotFoundException.dart';
import '../../util/settings_json.dart';

class NotificationSettings extends StatefulWidget {
  const NotificationSettings({super.key});

  @override
  State<NotificationSettings> createState() => _NotificationSettingsState();
}

enum NotificationSound {
  osDefault(name: "OS default", id: 1);

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
  final SettingsJson _settingsJson = SettingsJson();

  bool _notificationsEnabled = true;
  bool _messagePreviewEnabled = true;
  NotificationSound _selectedSound = NotificationSound.osDefault;
  bool _vibrationEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    if (_settingsJson.isJsonNotLoaded) await _settingsJson.loadSettingsJson();
    setState(() {
      _notificationsEnabled = _settingsJson.notificationsEnabled;
      _messagePreviewEnabled = _settingsJson.showMessagePreview;
      _vibrationEnabled = _settingsJson.vibrationEnabled;
    });
  }

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
            onChanged: (bool newValue) {
              setState(() {
                _notificationsEnabled = newValue;
              });
              _settingsJson.setNotificationsEnabled(_notificationsEnabled);
              _settingsJson.saveSettingsJson();
            },
          ),

          // Enable/Disable Message Previews
          SwitchListTile(
            title: const Text("Show Message Previews"),
            subtitle: const Text("Display part of the message in notifications"),
            value: _messagePreviewEnabled,
            onChanged: (bool newValue) {
              setState(() {
                _messagePreviewEnabled = newValue;
              });
              _settingsJson.setShowMessagePreview(_messagePreviewEnabled);
              _settingsJson.saveSettingsJson();
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
              value: _vibrationEnabled,
              onChanged: (bool newValue) async {
                // Check if vibration is available on this device
                if (!(await Vibration.hasVibrator() ?? false)) {
                  showSnackBarDialog(context: context, content: "Vibration is not available on this device");
                  return;
                }
                
                Vibration.vibrate();

                setState(() {
                  _vibrationEnabled = newValue;
                });
                _settingsJson.setVibrationEnabled(_vibrationEnabled);
                _settingsJson.saveSettingsJson();
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
