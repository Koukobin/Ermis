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


/// Utility class for detecting disallowed characters in a string.
class StringValidator {
  StringValidator._();

  /// Checks if the input string contains any of the invalid characters
  /// specified in the `invalidCharacters` string.
  ///
  /// Returns `false` if any invalid character is found, otherwise `true`.
  ///
  /// This method uses a simple loop to check each character in the input string
  /// against the `invalidCharacters` string. The loop was chosen over regex due
  /// to its simplicity and clarity. In addition, for the small datasets used by this 
  /// application, using a loop is tremendously more efficient and avoids the overhead 
  /// of regex compilation.
  ///
  /// In cases where more complex patterns or multiple conditions need to be checked, a regex approach could be considered.
  static bool validate(String input, String invalidCharacters) {
    for (final char in input.runes) {
      if (invalidCharacters.contains(String.fromCharCode(char))) {
        return false; // Found invalid character
      }
    }
    return true; // No invalid characters found
  }
}