import 'package:ermis_client/generated/l10n.dart';
import 'package:ermis_client/core/widgets/scroll/custom_scroll_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_constants.dart';
import '../../core/services/locale_provider.dart';
import '../../core/services/settings_json.dart';

class LanguageSettingsPage {
  const LanguageSettingsPage._();

  static void showSheet(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    Locale selectedLanguage = localeProvider.locale;

    showCupertinoSheet(
        context: context,
        pageBuilder: (context) {
          return StatefulBuilder(
            builder: (BuildContext context, setState) {
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
