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


import 'package:ermis_client/core/util/entropy_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Entropy Calculator Tests', () {
    test('1.0', () {
      double entropy = EntropyCalculator.calculateEntropy("password");
      expect(entropy.ceil(), 3);
    });
    test('2.0', () {
      double entropy = EntropyCalculator.calculateEntropy("password123");
      expect(entropy.ceil(), 4);
    });
    test('3.0', () {
      double entropy = EntropyCalculator.calculateEntropy("Password123");
      expect(entropy.ceil(), 4);
    });
    test('4.0', () {
      double entropy = EntropyCalculator.calculateEntropy("correcthorsebatterystaple");
      expect(entropy.ceil(), 4);
    });
    test('5.0', () {
      double entropy = EntropyCalculator.calculateEntropy("696969");
      expect(entropy.ceil(), 1);
    });
  });
}
