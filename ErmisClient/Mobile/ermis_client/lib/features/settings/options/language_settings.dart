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

import 'package:ermis_mobile/generated/l10n.dart';
import 'package:ermis_mobile/core/widgets/scroll/custom_scroll_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../constants/app_constants.dart';
import '../../../core/services/locale_provider.dart';
import '../../../core/services/settings_json.dart';

class LanguageSettingsPage {
  const LanguageSettingsPage._();

  static void showSheet(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    Locale selectedLanguage = localeProvider.locale;

    showCupertinoSheet(
        context: context,
        pageBuilder: (context) {
          return StatefulBuilder(builder: (context, StateSetter setState) {
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  onPressed: Navigator.of(context).pop,
                  icon: const Icon(CupertinoIcons.xmark),
                  color: Colors.grey,
                ),
                title: Text(
                  S.current.app_language,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              body: ScrollViewFixer.createScrollViewWithAppBarSafety(
                scrollView: ListView(
                  children: [
                    RadioListTile<Locale>(
                      title: Text(AppConstants.languageNames["el"]!),
                      value: const Locale('el', 'GR'),
                      groupValue: selectedLanguage,
                      onChanged: (Locale? value) {
                        setState(() {
                          selectedLanguage = value!;
                          localeProvider.setLocale(value);

                          SettingsJson json = SettingsJson();
                          json.setLocale(value);
                          json.saveSettingsJson();
                        });
                      },
                    ),

                    RadioListTile<Locale>(
                      title: Text(AppConstants.languageNames["grc"]!),
                      value: const Locale('grc'),
                      groupValue: selectedLanguage,
                      onChanged: (Locale? value) {
                        setState(() {
                          selectedLanguage = value!;
                          localeProvider.setLocale(value);

                          SettingsJson json = SettingsJson();
                          json.setLocale(value);
                          json.saveSettingsJson();
                        });
                      },
                    ),

                    const Divider(),

                    ...AppConstants.availableLanguages.map((Locale locale) {
                      // if (locale.languageCode == 'el' || locale.languageCode == 'grc') return const SizedBox.shrink();
                      return RadioListTile<Locale>(
                        title: Text(AppConstants.languageNames[locale.languageCode]!),
                        value: locale,
                        groupValue: selectedLanguage,
                        onChanged: (Locale? value) {
                          setState(() {
                            selectedLanguage = value!;
                            localeProvider.setLocale(value);
                            SettingsJson json = SettingsJson();
                            json.setLocale(locale);
                            json.saveSettingsJson();
                          });
                        },
                      );
                    }),
                  ],
                ),
              ),
            );
          });
        });
  }
}
