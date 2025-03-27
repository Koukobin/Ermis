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

class VerificationResult {
  final int id;
  final bool success;

  const VerificationResult._(this.id, this.success);

  static const successfullyVerified = VerificationResult._(1, true);
  static const wrongCode = VerificationResult._(2, false);
  static const runOutOfAttempts = VerificationResult._(3, false);
  static const invalidEmailAddress = VerificationResult._(4, false);

  static const List<VerificationResult> values = [
    successfullyVerified,
    wrongCode,
    runOutOfAttempts,
    invalidEmailAddress,
  ];

  static final Map<int, VerificationResult> _valuesById = {
    for (var result in values) result.id: result
  };

  static VerificationResult? fromId(int id) => _valuesById[id];
}

enum VerificationAction {
  resendCode(1);

  final int id;
  static final Map<int, VerificationAction> _valuesById = {
    for (var action in VerificationAction.values) action.id: action
  };

  const VerificationAction(this.id);

  static VerificationAction? fromId(int id) => _valuesById[id];
}