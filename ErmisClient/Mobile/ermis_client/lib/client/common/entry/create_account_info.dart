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

enum AuthenticationStage {
  credentialsValidation(1),
  createAccount(2);

  final int id;
  const AuthenticationStage(this.id);

  static final Map<int, AuthenticationStage> _valuesById = {
    for (var stage in AuthenticationStage.values) stage.id: stage,
  };

  static AuthenticationStage? fromId(int id) => _valuesById[id];
}

enum CreateAccountAction {
  addDeviceInfo(1);

  final int id;
  const CreateAccountAction(this.id);

  static final Map<int, CreateAccountAction> _valuesById = {
    for (var action in CreateAccountAction.values) action.id: action,
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
    for (var credential in CreateAccountCredential.values) credential.id: credential,
  };

  static CreateAccountCredential? fromId(int id) => _valuesById[id];
}

enum CredentialValidationResult {
  successfullyExchangedCredentials(1, ResultHolder(true, "Successfully exchanged credentials!")),
  unableToGenerateClientId(2, ResultHolder(false, "Unable to generate client id!")),
  emailAlreadyUsed(3, ResultHolder(false, "Email is already used!")),
  usernameRequirementsNotMet(4, ResultHolder(false, "Username requirements not met!")),
  passwordRequirementsNotMet(5, ResultHolder(false, "Password requirements not met!")),
  invalidEmailAddress(6, ResultHolder(false, "Invalid email address"));

  final int id;
  final ResultHolder resultHolder;

  const CredentialValidationResult(this.id, this.resultHolder);

  static final Map<int, CredentialValidationResult> _valuesById = {
    for (var result in CredentialValidationResult.values) result.id: result,
  };

  static CredentialValidationResult? fromId(int id) => _valuesById[id];
}