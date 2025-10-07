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

import 'dart:math';

/// Terrible Shannon entropy approximation calculator
class EntropyCalculator {
  static double approximate(String input) {
    if (input.isEmpty) return 0.0;

    final Map<String, int> frequencyMap = {};

    // Count occurrences of each character
    for (final int char in input.runes) {
      String key = String.fromCharCode(char);
      frequencyMap[key] = (frequencyMap[key] ?? 0) + 1;
    }

    final int length = input.length;
    double entropy = 0.0;

    // Calculate entropy
    for (final int count in frequencyMap.values) {
      double probability = count / length;
      entropy -= probability * (log(probability) / ln2);
    }

    if (input.length > 12) return entropy * 30;
    return entropy * 4;
  }
}
