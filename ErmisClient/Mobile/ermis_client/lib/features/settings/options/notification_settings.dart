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

import 'package:ermis_client/enums/notification_sound_enum.dart';
import 'package:ermis_client/core/util/dialogs_utils.dart';
import 'package:ermis_client/core/util/top_app_bar_utils.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import '../../../core/widgets/scroll/custom_scroll_view.dart';
import '../../../generated/l10n.dart';
import '../../../core/services/settings_json.dart';

class NotificationSettings extends StatefulWidget {
  const NotificationSettings({super.key});

  @override
  State<NotificationSettings> createState() => _NotificationSettingsState();
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
      _selectedSound = _settingsJson.notificationSound;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ErmisAppBar(titleText: S.current.notification_settings),
      body: ScrollViewFixer.createScrollViewWithAppBarSafety(
          scrollView: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Enable/Disable Notifications
          SwitchListTile(
            title: Text(S.current.notification_enable),
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
            title: Text(S.current.notification_preview_show),
            subtitle: Text(S.current.display_part_of_messages_in_notifications),
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
            title: Text(S.current.notification_sound),
            subtitle: Text(_selectedSound.cleanName),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showSoundSelectionDialog();
            },
          ),

          const Divider(),
          Text(
            S.current.other_settings,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          SwitchListTile(
            title: Text(S.current.vibration),
            value: _vibrationEnabled,
            onChanged: (bool newValue) async {
              // Check if vibration is available on this device
              if (!(await Vibration.hasVibrator())) {
                showSnackBarDialog(context: context, content: S.current.vibration_unavailable);
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
        ],
      )),
    );
  }

  void _showSoundSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return WhatsAppPopupDialog(
          child: AlertDialog(
            title: Text(S.current.notification_sound_select),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: NotificationSound.values.map((NotificationSound sound) {
                return RadioListTile<NotificationSound>(
                  title: Text(sound.cleanName),
                  value: sound,
                  groupValue: _selectedSound,
                  onChanged: (NotificationSound? value) {
                    setState(() {
                      _selectedSound = value!;
                    });
                    _settingsJson.setNotificationSound(value!);
                    _settingsJson.saveSettingsJson();
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
