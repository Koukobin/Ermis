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

import 'dart:convert';
import 'dart:io';

import 'package:ermis_client/main_ui/settings/theme_settings.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class SettingsJson {

  static SettingsJson? _instance;

  SettingsJson._internal();

  factory SettingsJson() {
    _instance ??= SettingsJson._internal();
    return _instance!;
  }

  late Map<String, dynamic> _settingsJson;

  Future<void> loadSettingsJson() async {
    final path = await _getSettingsFilePath();
    final file = File(path);
    if (!await file.exists()) {
      file.create();
      _initializeDefaultSettings(file);
    }

    final content = await file.readAsString();
    _settingsJson = jsonDecode(content);
  }

  void setUseSystemDefaultTheme(bool useSystemDefaultTheme) {
    _settingsJson["useSystemDefaultTheme"] = useSystemDefaultTheme;
  }

  void setDarkMode(bool darkMode) {
    _settingsJson["darkMode"] = darkMode;
  }

  void setChatBackDrop(int backdropId) {
    _settingsJson["chatsBackDrop"] = backdropId;
  }

  void setGradientColors(List<Color> colors) {
    _settingsJson["gradientColors"] = colors.map((color) => color.value).toList();
  }

  void setNotificationsEnabled(bool enabled) {
    _settingsJson["notificationsEnabled"] = enabled;
  }

  void setShowMessagePreview(bool showPreview) {
    _settingsJson["showMessagePreview"] = showPreview;
  }

  void setVibrationEnabled(bool enabled) {
    _settingsJson["vibrationEnabled"] = enabled;
  }

  bool get useSystemDefaultTheme => _settingsJson["useSystemDefaultTheme"];
  bool get isDarkModeEnabled => _settingsJson["darkMode"];
  ChatBackDrop get chatsBackDrop => ChatBackDrop.fromId(_settingsJson["chatsBackDrop"]);
  List<Color> get gradientColors => (_settingsJson['gradientColors'] as List)
      .map((colorInt) => Color(colorInt))
      .toList();
  bool get notificationsEnabled => _settingsJson["notificationsEnabled"];
  bool get showMessagePreview => _settingsJson["showMessagePreview"];
  bool get vibrationEnabled => _settingsJson["vibrationEnabled"];

  Future<void> saveSettingsJson() async {
    final path = await _getSettingsFilePath();
    final file = File(path);
    await file.writeAsString(jsonEncode(_settingsJson));
  }

  Future<String> _getSettingsFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    final String settingsPath = '${directory.path}/settings.json';
    return settingsPath;
  }

  Future<void> _initializeDefaultSettings(File file) async {
    _settingsJson = {
      "useSystemDefaultTheme": true,
      "darkMode": false,
      "chatsBackDrop": 0,
      "gradientColors": [Colors.blue.value, Colors.green.value],
      "notificationsEnabled": true,
      "showMessagePreview": true,
      "vibrationEnabled": false,
    };
    await file.writeAsString(jsonEncode(_settingsJson));
  }
}
