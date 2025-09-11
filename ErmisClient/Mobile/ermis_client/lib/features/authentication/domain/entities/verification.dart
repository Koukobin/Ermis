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

import '../../../../generated/l10n.dart';
import 'resultable.dart';

enum VerificationResult implements Resultable {
  successfullyVerified(1, true),
  wrongCode(2, false),
  runOutOfAttempts(3, false),
  invalidEmailAddress(4, false);

  final int id;
  final bool success;

  const VerificationResult(this.id, this.success);

  static final Map<int, VerificationResult> _valuesById = {
    for (var result in values) result.id: result
  };

  static VerificationResult? fromId(int id) => _valuesById[id];
  
  @override
  bool get isSuccessful => success;
  
  @override
  String get message => switch(this) {
    VerificationResult.successfullyVerified => S.current.verification_success,
    VerificationResult.wrongCode => S.current.verification_code_incorrect,
    VerificationResult.runOutOfAttempts => S.current.verification_attempts_exhausted,
    VerificationResult.invalidEmailAddress => S.current.verification_email_invalid,
  };
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