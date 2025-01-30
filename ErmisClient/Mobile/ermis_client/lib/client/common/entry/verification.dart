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

import '../results/ResultHolder.dart';

class VerificationResult {
  final int id;
  final ResultHolder resultHolder;

  const VerificationResult._(this.id, this.resultHolder);

  static const successfullyVerified = VerificationResult._(
    1,
    ResultHolder(true, "Successfully verified!"),
  );
  static const wrongCode = VerificationResult._(
    2,
    ResultHolder(false, "Incorrect code!"),
  );
  static const runOutOfAttempts = VerificationResult._(
    3,
    ResultHolder(false, "Run out of attempts!"),
  );
  static const invalidEmailAddress = VerificationResult._(
    4,
    ResultHolder(false, "Invalid email address"),
  );

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