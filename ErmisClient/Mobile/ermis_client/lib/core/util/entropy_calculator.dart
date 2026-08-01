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
///
/// August 2nd 2026 Update: Still terrible Shannon entropy calculator
///                         - but enhanced by Claude (Just like god intended)
class EntropyCalculator {
  /// Total entropy in bits for the whole string
  /// (per-symbol entropy * number of symbols).
  static double approximateTotalBits(String input) {
    if (input.isEmpty) return 0.0;
    return approximate(input) * input.runes.length;
  }

  /// Computes the Shannon entropy (in bits per symbol) of [input].
  ///
  /// Symbols are Unicode code points (runes), not UTF-16 code units, so
  /// multi-byte characters (emoji, non-Latin scripts, etc.) are counted
  /// correctly. Returns 0.0 for an empty string.
  static double approximate(String input) {
    if (input.isEmpty) return 0.0;

    final Map<int, int> frequencyMap = {};
    int symbolCount = 0;

    for (final int rune in input.runes) {
      frequencyMap[rune] = (frequencyMap[rune] ?? 0) + 1;
      symbolCount++;
    }

    double entropy = 0.0;
    for (final int count in frequencyMap.values) {
      final double probability = count / symbolCount;
      entropy -= probability * (log(probability) / ln2);
    }

    return entropy;
  }
}
