import 'dart:ui';

import 'package:ermis_client/constants/app_constants.dart';
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
