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

import 'package:flutter/rendering.dart';
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
        final formatter = DateFormat(newPattern, 'en_US'); // In case of failure, fallback to English (US)
        return formatter.format(date);
      } catch (e2) {
        debugPrint('Error formatting date in fallback: $e2');
        return "Invalid Date";
      }
    }
  }
}
