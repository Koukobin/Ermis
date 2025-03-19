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
      final formatter = DateFormat(newPattern); // Uses default locale
      return formatter.format(date);
    } on ArgumentError catch (e) {
      debugPrint('Error formatting date: $e');
      try {
        final formatter = DateFormat(newPattern, 'en_US'); // Fallback to English (US)
        return formatter.format(date);
      } on ArgumentError catch (e2) {
        debugPrint('Error formatting date in fallback: $e2');
        return "Invalid Date";
      }
    }
  }
}
