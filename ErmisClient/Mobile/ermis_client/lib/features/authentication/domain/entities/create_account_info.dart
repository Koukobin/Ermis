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

enum AuthenticationStage {
  credentialsValidation(1),
  createAccount(2);

  final int id;
  const AuthenticationStage(this.id);

  static final Map<int, AuthenticationStage> _valuesById = {
    for (final stage in AuthenticationStage.values) stage.id: stage,
  };

  static AuthenticationStage? fromId(int id) => _valuesById[id];
}

/// This enum indicates/signifies to the server that the message is an action and not a credential
enum GeneralEntryAction {
  action(117 /* Number chosen arbitrarily... */);

  final int id;
  const GeneralEntryAction(this.id);
}

enum CreateAccountAction {
  addDeviceInfo(1), fetchRequirements(3);

  final int id;
  const CreateAccountAction(this.id);

  static final Map<int, CreateAccountAction> _valuesById = {
    for (final action in CreateAccountAction.values) action.id: action,
  };

  static CreateAccountAction? fromId(int id) => _valuesById[id];
}

enum CreateAccountCredential implements CredentialInterface {
  username(0),
  password(1),
  email(2);

  @override
  final int id;
  const CreateAccountCredential(this.id);

  static final Map<int, CreateAccountCredential> _valuesById = {
    for (final credential in CreateAccountCredential.values) credential.id: credential,
  };

  static CreateAccountCredential? fromId(int id) => _valuesById[id];
}

enum CredentialValidationResult implements Resultable {
  successfullyExchangedCredentials(1, true),
  unableToGenerateClientId(2, false),
  emailAlreadyUsed(3, false),
  usernameRequirementsNotMet(4, false),
  passwordRequirementsNotMet(5, false),
  invalidEmailAddress(6, false);

  final int id;
  final bool success;

  const CredentialValidationResult(this.id, this.success);

  @override
  bool get isSuccessful => success;
  
  @override
  String get message => switch (this) {
    CredentialValidationResult.successfullyExchangedCredentials => S.current.credential_validation_success,
    CredentialValidationResult.unableToGenerateClientId => S.current.credential_validation_client_id_error,
    CredentialValidationResult.emailAlreadyUsed => S.current.create_account_email_exists,
    CredentialValidationResult.usernameRequirementsNotMet => S.current.credential_validation_username_invalid,
    CredentialValidationResult.passwordRequirementsNotMet => S.current.credential_validation_password_invalid,
    CredentialValidationResult.invalidEmailAddress => S.current.credential_validation_email_invalid,
  };

  static final Map<int, CredentialValidationResult> _valuesById = {
    for (final result in CredentialValidationResult.values) result.id: result,
  };

  static CredentialValidationResult? fromId(int id) => _valuesById[id];
}

enum CreateAccountResult implements Resultable {
  successfullyCreatedAccount(1, true),
  errorWhileCreatingAccount(2, false),
  databaseMaxSizeReached(3, false),
  emailAlreadyUsed(4, false);

  final int id;
  final bool success;

  const CreateAccountResult(this.id, this.success);

  @override
  bool get isSuccessful => success;
  
  @override
  String get message => switch(this) {
    CreateAccountResult.successfullyCreatedAccount => S.current.create_account_success,
    CreateAccountResult.errorWhileCreatingAccount => S.current.create_account_error,
    CreateAccountResult.databaseMaxSizeReached => S.current.create_account_database_full,
    CreateAccountResult.emailAlreadyUsed => S.current.create_account_email_exists,
  };

  static final Map<int, CreateAccountResult> _valuesById = {
    for (final result in CreateAccountResult.values) result.id: result,
  };

  static CreateAccountResult? fromId(int id) => _valuesById[id];
  
}
