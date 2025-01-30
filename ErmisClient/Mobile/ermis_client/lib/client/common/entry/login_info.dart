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
import 'entry_type.dart';

enum LoginResult {
  successfullyLoggedIn(1, ResultHolder(true, "Successfully logged into your account!")),
  errorWhileLoggingIn(2, ResultHolder(false, "An error occurred while logging into your account! Please contact the server administrator.")),
  incorrectPassword(3, ResultHolder(false, "Incorrect password.")),
  incorrectBackupVerificationCode(4, ResultHolder(false, "Incorrect backup verification code"));

  final int id;
  final ResultHolder resultHolder;

  const LoginResult(this.id, this.resultHolder);

  static final Map<int, LoginResult> _valuesById = {
    for (var result in LoginResult.values) result.id: result,
  };

  static LoginResult? fromId(int id) => _valuesById[id];
}

enum LoginCredential implements CredentialInterface {
  email(1),
  password(2);

  @override
  final int id;
  const LoginCredential(this.id);

  static final Map<int, LoginCredential> _valuesById = {
    for (var credential in LoginCredential.values) credential.id: credential,
  };

  static LoginCredential? fromId(int id) => _valuesById[id];
}

enum LoginAction {
  togglePasswordType(1),
  addDeviceInfo(2);

  final int id;
  const LoginAction(this.id);

  static final Map<int, LoginAction> _valuesById = {
    for (var action in LoginAction.values) action.id: action,
  };

  static LoginAction? fromId(int id) => _valuesById[id];
}

enum PasswordType {
  password(1),
  backupVerificationCode(2);

  final int id;
  const PasswordType(this.id);

  static final Map<int, PasswordType> _valuesById = {
    for (var type in PasswordType.values) type.id: type,
  };

  static PasswordType? fromId(int id) => _valuesById[id];
}