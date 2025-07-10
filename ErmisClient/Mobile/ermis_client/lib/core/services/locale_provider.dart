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

import 'dart:ui';

import 'package:ermis_mobile/constants/app_constants.dart';
import 'package:flutter/material.dart';

import 'settings_json.dart';

Locale _getSystemLocale() {
  return PlatformDispatcher.instance.locale;
}

final class LocaleProvider extends ChangeNotifier {
  /// By default, if a locale is not specified within
  /// the JSON configuration file, use the system locale.
  Locale _locale = SettingsJson().getLocale ?? _getSystemLocale();

  Locale get locale => _locale;
  String? get language => AppConstants.languageNames[_locale.languageCode];

  void setLocale(Locale newLocale) {
    _locale = newLocale;
    notifyListeners(); // Notify widgets that the locale has changed
  }
}
