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

import 'package:ermis_mobile/features/authentication/domain/entities/resultable.dart';
import 'package:ermis_mobile/generated/l10n.dart';
import 'entry_type.dart';

enum LoginResult implements Resultable {
  successfullyLoggedIn(1, true),
  errorWhileLoggingIn(2, false),
  incorrectPassword(3, false),
  incorrectBackupVerificationCode(4, false);

  final int id;
  final bool success;

  const LoginResult(this.id, this.success);

  @override
  bool get isSuccessful => success;

  @override
  String get message => switch(this) {
    LoginResult.successfullyLoggedIn => S.current.login_success,
    LoginResult.errorWhileLoggingIn => S.current.login_error,
    LoginResult.incorrectPassword => S.current.login_password_incorrect,
    LoginResult.incorrectBackupVerificationCode => S.current.login_backup_code_incorrect,
  };

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

enum LoginCredentialResult implements Resultable {
  successfullyExchangedCredentials(1, true),
  incorrectEmail(2, false),
  accountDoesntExist(3, false);

  final int id;
  final bool success;

  const LoginCredentialResult(this.id, this.success);

  @override
  bool get isSuccessful => success;
  
  @override
  String get message => switch (this) {
    LoginCredentialResult.successfullyExchangedCredentials => S.current.credential_validation_success,
    LoginCredentialResult.incorrectEmail => S.current.login_email_incorrect,
    LoginCredentialResult.accountDoesntExist => S.current.login_account_not_found,
  };

  static final Map<int, LoginCredentialResult> _valuesById = {
    for (var result in LoginCredentialResult.values) result.id: result,
  };

  static LoginCredentialResult? fromId(int id) => _valuesById[id];
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