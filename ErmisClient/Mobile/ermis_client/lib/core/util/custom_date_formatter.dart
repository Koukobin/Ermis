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

import 'package:ermis_mobile/core/services/locale_provider.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

/// You may inquire why this class with this singular method is even necessary.
/// The answer is exceptionally simple; I simply wanted to add Ancient Greek and Latin
/// to the available languages for users. Everything worked fine... for the most part - but,
/// an issue occured with the [DateFormat] class. Essentially, it could not process the
/// aformentioned languages and resulted in an ArgumentError. Hence the purpose of this class.
/// It contains a single method that enables Ancient Greek and Latin to work smoothly by falling
/// back to an English formatter in case of an error.
final class CustomDateFormatter {
  const CustomDateFormatter._();

  static String formatDate(DateTime date, String newPattern) {
    try {
      final formatter = DateFormat(newPattern); // Uses default locale by default
      return formatter.format(date);
    } catch (e) {
      debugPrint('Error formatting date: $e');
      try {
        String locale;

        // In case of failure, fallback to Greek if Ancient
        // Greek language is selected; other to English (US)
        if (LocaleProvider().locale.languageCode == 'grc') {
          locale = 'el_GR';
          initializeDateFormatting(); // Vital for ancient greek formatting to work
        } else {
          locale = 'en_US';
        }

        final formatter = DateFormat(newPattern, locale);
        return formatter.format(date);
      } catch (e2) {
        debugPrint('Error formatting date in fallback: $e2');
        return "Invalid Date";
      }
    }
  }
}
