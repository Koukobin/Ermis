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

import 'package:ermis_client/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppConstants {
  static late final String applicationVersion;

  static Future<void> initialize() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    applicationVersion = packageInfo.version;
  }

  static const String applicationTitle = "Ermis";
  static const String appIconPath = 'assets/primary_application_icon.png';
  static const String parthenonasPath = 'assets/background/parthenon.jpg';
  static const String ermisMascotPath = 'assets/ermis/ermis_mascot.png';
  static const String ermisCryingPath = 'assets/ermis/crying-ermis.png';
  static const String sourceCodeURL = "https://github.com/Koukobin/Ermis";
  static const String licenceURL = "$sourceCodeURL/wiki/License";
  static const String licencePath = "assets/LICENCE.txt";

  static const AppColors lightAppColors = AppColors(
      primaryColor: Colors.green,
      secondaryColor: Colors.white,
      tertiaryColor: Color.fromARGB(255, 233, 233, 233),
      quaternaryColor: Color.fromARGB(255, 150, 150, 150),
      inferiorColor: Colors.black);

  static const AppColors darkAppColors = AppColors(
    primaryColor: Colors.green,
    secondaryColor: Color.fromARGB(255, 17, 17, 17),
    tertiaryColor: Color.fromARGB(255, 30, 30, 30),
    quaternaryColor: Color.fromARGB(255, 46, 46, 46),
    inferiorColor: Colors.white,
  );

  static const List<Locale> availableLanguages = [
    Locale('en', 'EN'), // English
    Locale('el', 'GR'), // Greek
    Locale('es', 'ES'), // Spanish
    Locale('ru', 'RU'), // Russian
    Locale('ar', 'SA'), // Arabic (using Saudi Arabia as a common region)
    Locale('ja', 'JP'), // Japanese
    Locale('tr', 'TR'), // Turkish
    Locale('ro', 'RO'), // Romanian
    Locale('grc'), // Ancient Greek (no region code)
    Locale('la'), // Latin (no region code)
    Locale('pt', 'PT'), // Portuguese
    Locale('it', 'IT'), // Italian
    Locale('de', 'DE'), // German
    Locale('fr', 'FR'), // French
    // Locale('zh', 'CN'), // Chinese (Mandarin, using China as region)
    // Locale('hi', 'IN'), // Hindi
    // Locale('bn', 'BD'), // Bengali
    // Locale('id', 'ID'), // Indonesian
    // Locale('ur', 'PK'), // Urdu
    // Locale('vi', 'VN'), // Vietnamese
    // Locale('pl', 'PL'), // Polish
    // Locale('fa', 'IR'), // Persian/Farsi
    // Locale('ko', 'KR'), // Korean
    // Locale('uk', 'UA'), // Ukrainian
    // Locale('nl', 'NL'), // Dutch
    // Locale('sv', 'SE'), // Swedish
    // Locale('no', 'NO'), // Norwegian
    // Locale('da', 'DK'), // Danish
    // Locale('fi', 'FI'), // Finnish
    // Locale('he', 'IL'), // Hebrew
    // Locale('hu', 'HU'), // Hungarian
    // Locale('cs', 'CZ'), // Czech
    // Locale('sk', 'SK'), // Slovak
    // Locale('th', 'TH'), // Thai
    // Locale('sw', 'KE'), // Swahili
    // Locale('ml', 'IN'), // Malayalam
    // Locale('te', 'IN'), // Telugu
    // Locale('ta', 'IN'), // Tamil
    // Locale('kn', 'IN'), // Kannada
    // Locale('mr', 'IN'), // Marathi
    // Locale('gu', 'IN'), // Gujarati
  ];

static const Map<String, String> languageNames = {
    'en': 'English',
    'fr': 'Français',
    'es': 'Español',
    'de': 'Deutsch',
    'it': 'Italiano',
    'el': 'Ελληνικά',
    'zh': '中文',
    'ja': '日本語',
    'ru': 'Русский',
    'ar': 'العربية',
    'af': 'Afrikaans',
    'am': 'አማርኛ',
    'az': 'Azərbaycan dili',
    'be': 'Беларуская мова',
    'bg': 'Български език',
    'bn': 'বাংলা',
    'bs': 'Bosanski jezik',
    'ca': 'Català',
    'ceb': 'Binisaya',
    'co': 'Corsu',
    'cs': 'Čeština',
    'cy': 'Cymraeg',
    'da': 'Dansk',
    'eo': 'Esperanto',
    'et': 'Eesti keel',
    'eu': 'Euskara',
    'fa': 'فارسی',
    'fi': 'Suomen kieli',
    'fy': 'Frysk',
    'ga': 'Gaeilge',
    'gd': 'Gàidhlig',
    'gl': 'Galego',
    'gu': 'ગુજરાતી',
    'ha': 'Hausa',
    'haw': 'ʻŌlelo Hawaiʻi',
    'he': 'עברית',
    'hi': 'हिन्दी',
    'hmn': 'Hmong',
    'hr': 'Hrvatski jezik',
    'ht': 'Kreyòl ayisyen',
    'hu': 'Magyar nyelv',
    'hy': 'Հայերեն',
    'id': 'Bahasa Indonesia',
    'ig': 'Asụsụ Igbo',
    'is': 'Íslenska',
    'jw': 'Basa Jawa',
    'ka': 'ქართული ენა',
    'kk': 'Қазақ тілі',
    'km': 'ខ្មែរ',
    'kn': 'ಕನ್ನಡ',
    'ko': '한국어',
    'ku': 'Kurdî',
    'ky': 'Кыргыз тили',
    'lb': 'Lëtzebuergesch',
    'lo': 'ລາວ',
    'lt': 'Lietuvių kalba',
    'lv': 'Latviešu valoda',
    'mg': 'Malagasy',
    'mi': 'Te Reo Māori',
    'mk': 'Македонски јазик',
    'ml': 'മലയാളം',
    'mn': 'Монгол хэл',
    'mr': 'मराठी',
    'ms': 'Bahasa Melayu',
    'mt': 'Malti',
    'my': 'ဗမာစာ',
    'ne': 'नेपाली',
    'nl': 'Nederlands',
    'no': 'Norsk',
    'ny': 'Chichewa',
    'or': 'ଓଡ଼ିଆ',
    'pa': 'ਪੰਜਾਬੀ',
    'pl': 'Polski',
    'ps': 'پښتو',
    'pt': 'Português',
    'ro': 'Română',
    'sd': 'سنڌي',
    'si': 'සිංහල',
    'sk': 'Slovenčina',
    'sl': 'Slovenščina',
    'sm': 'Gagana Samoa',
    'sn': 'ChiShona',
    'so': 'Soomaali',
    'sq': 'Shqip',
    'sr': 'Српски језик',
    'st': 'Sesotho',
    'su': 'Basa Sunda',
    'sv': 'Svenska',
    'sw': 'Kiswahili',
    'ta': 'தமிழ்',
    'te': 'తెలుగు',
    'tg': 'Тоҷикӣ',
    'th': 'ไทย',
    'tl': 'Tagalog',
    'tr': 'Türkçe',
    'tt': 'Татар теле',
    'ug': 'ئۇيغۇرچە',
    'uk': 'Українська мова',
    'ur': 'اردو',
    'uz': 'Oʻzbek tili',
    'vi': 'Tiếng Việt',
    'xh': 'isiXhosa',
    'yi': 'ייִדיש',
    'yo': 'Yorùbá',
    'zu': 'isiZulu',
    'grc': 'Αρχαία Ελληνικά',
    'la':'Latin'
  };
}
