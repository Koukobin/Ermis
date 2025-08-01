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

import 'package:ermis_mobile/constants/app_constants.dart';
import 'package:ermis_mobile/core/models/app_state/new_features_page_status.dart';
import 'package:ermis_mobile/enums/notification_sound_enum.dart';
import 'package:ermis_mobile/enums/chat_back_drop_enum.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

final _defaultJsonSettings = {
  "useSystemDefaultTheme": true,
  "darkMode": false,
  "chatsBackDrop": ChatBackDrop.monotone.id,
  "gradientColors": [Colors.blue.value, Colors.green.value],
  "notificationsEnabled": true,
  "showMessagePreview": true,
  "notificationsSound": NotificationSound.ermis.id,
  "vibrationEnabled": true,
  "useLessDataForCallsEnabled": false,
  "hasUserSentFirstMessage": false, // Used for achievement unlocked popup
  "hasUserMadeFirstFriend": false, // Used for achievement unlocked popup
};

class SettingsJson {
  static SettingsJson? _instance;

  SettingsJson._internal();

  factory SettingsJson() {
    _instance ??= SettingsJson._internal();
    return _instance!;
  }

  bool _isJsonLoaded = false;
  late Map<String, dynamic> _settingsJson;

  /// Loads Json Settings if not already loaded
  Future<void> loadSettingsJson() async {
    if (_isJsonLoaded) return;

    final path = await _getJsonSettingsFilePath();
    final file = File(path);
    if (!await file.exists()) {
      await file.create();
    }

    final content = await file.readAsString();

    try {
      _settingsJson = jsonDecode(content);
    } on FormatException {
      // If content invalid JSON, reset settings
      _settingsJson = {};
    }

    _initializeUnspecifiedSettingsToDefault(file);

    _isJsonLoaded = true;
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

  void setNotificationSound(NotificationSound sound) {
    _settingsJson["notificationsSound"] = sound.id;
  }

  void setShowMessagePreview(bool showPreview) {
    _settingsJson["showMessagePreview"] = showPreview;
  }

  void setLocale(Locale locale) {
    _settingsJson["languageCode"] = locale.languageCode;
    _settingsJson["countryCode"] = locale.countryCode;
  }

  void setVibrationEnabled(bool enabled) {
    _settingsJson["vibrationEnabled"] = enabled;
  }

  void setHasShownNewFeaturesPage(NewFeaturesPageStatus page) {
    _settingsJson["newFeaturesPageStatus"] = jsonEncode(page.toJson());
  }

  void setUseLessDataForCallsEnabled(bool enabled) {
    _settingsJson["useLessDataForCallsEnabled"] = enabled;
  }

  void setHasUserSentFirstMessage(bool hasUserSentFirstMessage) {
    _settingsJson["hasUserSentFirstMessage"] = hasUserSentFirstMessage;
  }

  void setHasUserMadeFirstFriend(bool hasUserMadeFirstFriend) {
    _settingsJson["hasUserMadeFirstFriend"] = hasUserMadeFirstFriend;
  }

  bool get useSystemDefaultTheme => _settingsJson["useSystemDefaultTheme"];
  bool get isDarkModeEnabled => _settingsJson["darkMode"];
  ChatBackDrop get chatsBackDrop => ChatBackDrop.fromId(_settingsJson["chatsBackDrop"]);
  List<Color> get gradientColors => (_settingsJson['gradientColors'] as List)
      .map((colorInt) => Color(colorInt))
      .toList();
  bool get notificationsEnabled => _settingsJson["notificationsEnabled"];
  NotificationSound get notificationSound => NotificationSound.fromId(_settingsJson["notificationsSound"]);

  bool get showMessagePreview => _settingsJson["showMessagePreview"];
  bool get vibrationEnabled => _settingsJson["vibrationEnabled"];

  Locale? get getLocale {
    String? languageCode = _settingsJson['languageCode'];
    String? countryCode = _settingsJson['countryCode'];

    if (languageCode == null) return null;

    return Locale(languageCode, countryCode);
  }

  NewFeaturesPageStatus get newFeaturesPageStatus {
    final status = _settingsJson["newFeaturesPageStatus"];
    if (status is String) {
      try {
        return NewFeaturesPageStatus.fromJson(jsonDecode(status));
      } on Error {
        // In case of a fail, return a default status
      }
    }

    return NewFeaturesPageStatus(hasShown: false, version: AppConstants.applicationVersion);
  }

  bool get isJsonLoaded => _isJsonLoaded;
  bool get isJsonNotLoaded => !_isJsonLoaded;

  bool get useLessDataForCallsEnabled => _settingsJson["useLessDataForCallsEnabled"];

  bool get hasUserSentFirstMessage => _settingsJson["hasUserSentFirstMessage"];
  bool get hasUserMadeFirstFriend => _settingsJson["hasUserMadeFirstFriend"];

  Future<void> saveSettingsJson() async {
    final path = await _getJsonSettingsFilePath();
    final file = File(path);
    await file.writeAsString(jsonEncode(_settingsJson));
  }

  Future<String> _getJsonSettingsFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    final String settingsPath = '${directory.path}/settings.json';
    return settingsPath;
  }

  Future<void> _initializeUnspecifiedSettingsToDefault(File file) async {
    for (final entry in _defaultJsonSettings.entries) {
      if (_settingsJson.containsKey(entry.key)) {
        continue;
      }

      _settingsJson[entry.key] = entry.value;
    }

    await file.writeAsString(jsonEncode(_settingsJson));
  }
}

// Similar to the code above, but instead of manually storing the json 
// to a file, it utilizes a plugin called 'shared_preferences' to do so.
// Kept it here just in case it is useful in the future.

// import 'dart:convert';

// import 'package:ermis_mobile/main_ui/settings/theme_settings.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class SettingsJson {
//   static SettingsJson? _instance;

//   SettingsJson._internal();

//   factory SettingsJson() {
//     _instance ??= SettingsJson._internal();
//     return _instance!;
//   }

//   bool _isJsonLoaded = false;
//   late Map<String, dynamic> _settingsJson;

//   Future<void> loadSettingsJson() async {
//     Map<String, dynamic>? json = await getJsonFromSharedPreferences();
//     json ??= await _retrieveDefaultSettings();

//     _settingsJson = json;
//     _isJsonLoaded = true;
//   }

//   void setUseSystemDefaultTheme(bool useSystemDefaultTheme) {
//     _settingsJson["useSystemDefaultTheme"] = useSystemDefaultTheme;
//   }

//   void setDarkMode(bool darkMode) {
//     _settingsJson["darkMode"] = darkMode;
//   }

//   void setChatBackDrop(int backdropId) {
//     _settingsJson["chatsBackDrop"] = backdropId;
//   }

//   void setGradientColors(List<Color> colors) {
//     _settingsJson["gradientColors"] =
//         colors.map((color) => color.value).toList();
//   }

//   void setNotificationsEnabled(bool enabled) {
//     _settingsJson["notificationsEnabled"] = enabled;
//   }

//   void setShowMessagePreview(bool showPreview) {
//     _settingsJson["showMessagePreview"] = showPreview;
//   }

//   void setVibrationEnabled(bool enabled) {
//     _settingsJson["vibrationEnabled"] = enabled;
//   }

//   bool get useSystemDefaultTheme => _settingsJson["useSystemDefaultTheme"];
//   bool get isDarkModeEnabled => _settingsJson["darkMode"];
//   ChatBackDrop get chatsBackDrop =>
//       ChatBackDrop.fromId(_settingsJson["chatsBackDrop"]);
//   List<Color> get gradientColors => (_settingsJson['gradientColors'] as List)
//       .map((colorInt) => Color(colorInt))
//       .toList();
//   bool get notificationsEnabled => _settingsJson["notificationsEnabled"];
//   bool get showMessagePreview => _settingsJson["showMessagePreview"];
//   bool get vibrationEnabled => _settingsJson["vibrationEnabled"];

//   bool get isJsonLoaded => _isJsonLoaded;
//   bool get isJsonNotLoaded => !_isJsonLoaded;

//   Future<void> saveSettingsJson() async {
//     final prefs = await SharedPreferences.getInstance();
//     prefs.setString("jsonData", jsonEncode(_settingsJson));
//   }

//   Future<Map<String, dynamic>?> getJsonFromSharedPreferences() async {
//     final prefs = await SharedPreferences.getInstance();

//     // Retrieve the JSON string from SharedPreferences
//     String? jsonString = prefs.getString('jsonData');

//     if (jsonString != null) {
//       return jsonDecode(jsonString);
//     }

//     return null;
//   }

//   Future<Map<String, Object>> _retrieveDefaultSettings() async {
//     return {
//       "useSystemDefaultTheme": true,
//       "darkMode": false,
//       "chatsBackDrop": 0,
//       "gradientColors": [Colors.blue.value, Colors.green.value],
//       "notificationsEnabled": true,
//       "showMessagePreview": true,
//       "vibrationEnabled": false,
//     };
//   }
// }
