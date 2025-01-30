// /* Copyright (C) 2024 Ilias Koukovinis <ilias.koukovinis@gmail.com>
//  *
//  * This program is free software: you can redistribute it and/or modify
//  * it under the terms of the GNU Affero General Public License as
//  * published by the Free Software Foundation, either version 3 of the
//  * License, or (at your option) any later version.
//  * 
//  * This program is distributed in the hope that it will be useful,
//  * but WITHOUT ANY WARRANTY; without even the implied warranty of
//  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  * GNU Affero General Public License for more details.
//  * 
//  * You should have received a copy of the GNU Affero General Public License
//  * along with this program. If not, see <https://www.gnu.org/licenses/>.
//  */



// class EnumNotFoundException implements Exception {
//   final String message;
//   EnumNotFoundException(this.message);

//   @override
//   String toString() => 'EnumNotFoundException: $message';
// }


// enum ClientCommandResultType {
//   deleteChatMessage(1),
//   downloadFile(2),
//   downloadImage(3),
//   getDisplayName(4),
//   fetchAccountIcon(5),
//   setAccountIcon(6),
//   getClientId(7),
//   getChatRequests(8),
//   getChatSessions(9),
//   getWrittenText(10),
//   getDonationPage(11),
//   getServerSourceCodePage(12);

//   final int id;
//   const ClientCommandResultType(this.id);
  
//   static ClientCommandResultType fromId(int id) {
//     try {
//       return ClientCommandResultType.values
//           .firstWhere((type) => type.id == id);
//     } catch (e) {
//       throw EnumNotFoundException('No ClientCommandResultType found for id $id');
//     }
//   }
// }

// enum CommandLevel { light, heavy }

// enum ClientCommandType {
//   // Account Management
//   changeUsername(CommandLevel.heavy, 0),
//   changePassword(CommandLevel.heavy, 1),
//   addAccountIcon(CommandLevel.heavy, 2),
//   logout(CommandLevel.light, 3),

//   // User Information Requests
//   fetchUsername(CommandLevel.light, 4),
//   fetchClientId(CommandLevel.light, 5),
//   fetchAccountIcon(CommandLevel.heavy, 6),

//   // Chat Management
//   fetchChatRequests(CommandLevel.light, 7),
//   fetchChatSessions(CommandLevel.light, 8),
//   sendChatRequest(CommandLevel.heavy, 9),
//   acceptChatRequest(CommandLevel.heavy, 10),
//   declineChatRequest(CommandLevel.heavy, 11),
//   deleteChatSession(CommandLevel.heavy, 12),
//   deleteChatMessage(CommandLevel.heavy, 13),
//   fetchWrittenText(CommandLevel.heavy, 14),
//   downloadFile(CommandLevel.heavy, 15),
//   downloadImage(CommandLevel.heavy, 16),
//   startVoiceCall(CommandLevel.heavy, 17),

//   // External Pages
//   requestDonationPage(CommandLevel.light, 18),
//   requestSourceCodePage(CommandLevel.light, 19);

//   final CommandLevel commandLevel;
//   final int id;
//   const ClientCommandType(this.commandLevel, this.id);

//   // This function mimics the fromId functionality and throws an exception when no match is found.
//   static ClientCommandType fromId(int id) {
//     try {
//       return ClientCommandType.values.firstWhere((type) => type.id == id);
//     } catch (e) {
//       throw EnumNotFoundException('No ClientCommandType found for id $id');
//     }
//   }

//   CommandLevel getCommandLevel() => commandLevel;
// }

// enum ClientMessageType {
//   clientContent(0),
//   command(1);

//   final int id;
//   const ClientMessageType(this.id);

//   // This function mimics the fromId functionality and throws an exception when no match is found.
//   static ClientMessageType fromId(int id) {
//     try {
//       return ClientMessageType.values
//           .firstWhere((type) => type.id == id);
//     } catch (e) {
//       throw EnumNotFoundException('No ClientMessageType found for id $id');
//     }
//   }
// }

// enum ContentType {
//   text(0),
//   file(1),
//   image(2);

//   final int id;
//   const ContentType(this.id);

//   // This function mimics the fromId functionality and throws an exception when no match is found.
//   static ContentType fromId(int id) {
//     try {
//       return ContentType.values.firstWhere((type) => type.id == id);
//     } catch (e) {
//       throw EnumNotFoundException('No ContentType found for id $id');
//     }
//   }
// }

// class EntryResult {
//   final ResultHolder resultHolder;
// 	final Map<AddedInfo, String> addedInfo;

//   const EntryResult(this.resultHolder, this.addedInfo);

//   bool get isSuccessful => resultHolder.isSuccessful;
//   String get message => resultHolder.message;
// }

// enum AddedInfo {
//   passwordHash(1);

//   final int id;
//   const AddedInfo(this.id);

//   static AddedInfo fromId(int id) {
//     try {
//       return AddedInfo.values.firstWhere((type) => type.id == id);
//     } catch (e) {
//       throw EnumNotFoundException('No AddedInfo found for id $id');
//     }
//   }
// }

// class ResultHolder {
//   final bool isSuccessful;
//   final String message;

//   const ResultHolder(this.isSuccessful, this.message);
// }

// enum ServerMessageType {
//   clientContent(0),
//   messageSuccefullySent(1),
//   voiceCallIncoming(2),
//   serverMessageInfo(3),
//   commandResult(4);

//   final int id;
//   const ServerMessageType(this.id);

//   // Mimics the `fromId` functionality, throwing an exception if no match is found.
//   static ServerMessageType fromId(int id) {
//     try {
//       return ServerMessageType.values.firstWhere((type) => type.id == id);
//     } catch (e) {
//       throw EnumNotFoundException('No ServerMessageType found for id $id');
//     }
//   }
// }

// enum ChangePasswordResult {
//   successfullyChangedPassword(
//     id: 0,
//     resultHolder: ResultHolder(true, "Successfully changed password!"),
//   ),
//   errorWhileChangingPassword(
//     id: 1,
//     resultHolder: ResultHolder(false, "There was an error while trying to change password!"),
//   );

//   final int id;
//   final ResultHolder resultHolder;

//   const ChangePasswordResult({
//     required this.id,
//     required this.resultHolder,
//   });

//   static ChangePasswordResult fromId(int id) {
//     try {
//       return ChangePasswordResult.values.firstWhere((type) => type.id == id);
//     } catch (e) {
//       throw EnumNotFoundException('No ChangePasswordResult found for id $id');
//     }
//   }
// }

// enum ChangeUsernameResult {
//   successfullyChangedUsername(
//     id: 0,
//     resultHolder: ResultHolder(true, "Successfully changed username!"),
//   ),
//   errorWhileChangingUsername(
//     id: 1,
//     resultHolder: ResultHolder(false, "There was an error while trying to change username!"),
//   );

//   final int id;
//   final ResultHolder resultHolder;

//   const ChangeUsernameResult({
//     required this.id,
//     required this.resultHolder,
//   });

//   static ChangeUsernameResult fromId(int id) {
//     try {
//       return ChangeUsernameResult.values.firstWhere((type) => type.id == id);
//     } catch (e) {
//       throw EnumNotFoundException('No ChangeUsernameResult found for id $id');
//     }
//   }
// }

// enum IsPasswordValidResult {
//   successfullyValidatedPassword(
//     id: 1,
//     resultHolder: ResultHolder(true, "Successfully validated password!"),
//   ),
//   requirementsNotMet(
//     id: 2,
//     resultHolder: ResultHolder(false, "Password requirements not met!"),
//   );

//   final int id;
//   final ResultHolder resultHolder;

//   const IsPasswordValidResult({
//     required this.id,
//     required this.resultHolder,
//   });

//   static IsPasswordValidResult fromId(int id) {
//     try {
//       return IsPasswordValidResult.values.firstWhere((type) => type.id == id);
//     } catch (e) {
//       throw EnumNotFoundException('No IsPasswordValidResult found for id $id');
//     }
//   }
// }

// enum RegenerateBackupVerificationCodesResult {
//   successfullyRegeneratedBackupVerificationCodes(
//     id: 1,
//     resultHolder: ResultHolder(true, "Successfully regenerated backup verification codes!"),
//   ),
//   errorWhileChangingUsername(
//     id: 2,
//     resultHolder: ResultHolder(false, "There was an error while trying to change username!"),
//   );

//   final int id;
//   final ResultHolder resultHolder;

//   const RegenerateBackupVerificationCodesResult({
//     required this.id,
//     required this.resultHolder,
//   });

//   static RegenerateBackupVerificationCodesResult fromId(int id) {
//     try {
//       return RegenerateBackupVerificationCodesResult.values.firstWhere((type) => type.id == id);
//     } catch (e) {
//       throw EnumNotFoundException('No RegenerateBackupVerificationCodesResult found for id $id');
//     }
//   }
// }

// enum EntryType {
//   createAccount(1),
//   login(2);

//   final int id;
//   const EntryType(this.id);

//   static final Map<int, EntryType> _valuesById = {
//     for (var entry in EntryType.values) entry.id: entry,
//   };

//   static EntryType? fromId(int id) => _valuesById[id];
// }

// abstract class CredentialInterface {
//   int get id;
// }

// enum CreateAccountCredential implements CredentialInterface {
//   username(0),
//   password(1),
//   email(2);

//   @override
//   final int id;
//   const CreateAccountCredential(this.id);

//   static final Map<int, CreateAccountCredential> _valuesById = {
//     for (var credential in CreateAccountCredential.values) credential.id: credential,
//   };

//   static CreateAccountCredential? fromId(int id) => _valuesById[id];
// }

// enum AuthenticationStage {
//   credentialsValidation(1),
//   createAccount(2);

//   final int id;
//   const AuthenticationStage(this.id);

//   static final Map<int, AuthenticationStage> _valuesById = {
//     for (var stage in AuthenticationStage.values) stage.id: stage,
//   };

//   static AuthenticationStage? fromId(int id) => _valuesById[id];
// }

// enum CredentialValidationResult {
//   successfullyExchangedCredentials(1, ResultHolder(true, "Successfully exchanged credentials!")),
//   unableToGenerateClientId(2, ResultHolder(false, "Unable to generate client id!")),
//   emailAlreadyUsed(3, ResultHolder(false, "Email is already used!")),
//   usernameRequirementsNotMet(4, ResultHolder(false, "Username requirements not met!")),
//   passwordRequirementsNotMet(5, ResultHolder(false, "Password requirements not met!")),
//   invalidEmailAddress(6, ResultHolder(false, "Invalid email address"));

//   final int id;
//   final ResultHolder resultHolder;

//   const CredentialValidationResult(this.id, this.resultHolder);

//   static final Map<int, CredentialValidationResult> _valuesById = {
//     for (var result in CredentialValidationResult.values) result.id: result,
//   };

//   static CredentialValidationResult? fromId(int id) => _valuesById[id];
// }

// enum LoginCredential implements CredentialInterface {
//   email(1),
//   password(2);

//   @override
//   final int id;
//   const LoginCredential(this.id);

//   static final Map<int, LoginCredential> _valuesById = {
//     for (var credential in LoginCredential.values) credential.id: credential,
//   };

//   static LoginCredential? fromId(int id) => _valuesById[id];
// }

// enum PasswordType {
//   password(1),
//   backupVerificationCode(2);

//   final int id;
//   const PasswordType(this.id);

//   static final Map<int, PasswordType> _valuesById = {
//     for (var type in PasswordType.values) type.id: type,
//   };

//   static PasswordType? fromId(int id) => _valuesById[id];
// }

// enum LoginAction {
//   togglePasswordType(1);

//   final int id;
//   const LoginAction(this.id);

//   static final Map<int, LoginAction> _valuesById = {
//     for (var action in LoginAction.values) action.id: action,
//   };

//   static LoginAction? fromId(int id) => _valuesById[id];
// }

// enum LoginResult {
//   successfullyLoggedIn(1, ResultHolder(true, "Successfully logged into your account!")),
//   errorWhileLoggingIn(2, ResultHolder(false, "An error occurred while logging into your account! Please contact the server administrator.")),
//   incorrectPassword(3, ResultHolder(false, "Incorrect password.")),
//   incorrectBackupVerificationCode(4, ResultHolder(false, "Incorrect backup verification code"));

//   final int id;
//   final ResultHolder resultHolder;

//   const LoginResult(this.id, this.resultHolder);

//   static final Map<int, LoginResult> _valuesById = {
//     for (var result in LoginResult.values) result.id: result,
//   };

//   static LoginResult? fromId(int id) => _valuesById[id];
// }

// // Verification Action
// enum VerificationAction {
//   resendCode(1);

//   final int id;
//   static final Map<int, VerificationAction> _valuesById = {
//     for (var action in VerificationAction.values) action.id: action
//   };

//   const VerificationAction(this.id);

//   static VerificationAction? fromId(int id) => _valuesById[id];
// }

// // Verification Result
// class VerificationResult {
//   final int id;
//   final ResultHolder resultHolder;

//   const VerificationResult._(this.id, this.resultHolder);

//   static const successfullyVerified = VerificationResult._(
//     1,
//     ResultHolder(true, "Successfully verified!"),
//   );
//   static const wrongCode = VerificationResult._(
//     2,
//     ResultHolder(false, "Incorrect code!"),
//   );
//   static const runOutOfAttempts = VerificationResult._(
//     3,
//     ResultHolder(false, "Run out of attempts!"),
//   );
//   static const invalidEmailAddress = VerificationResult._(
//     4,
//     ResultHolder(false, "Invalid email address"),
//   );

//   static const List<VerificationResult> values = [
//     successfullyVerified,
//     wrongCode,
//     runOutOfAttempts,
//     invalidEmailAddress,
//   ];

//   static final Map<int, VerificationResult> _valuesById = {
//     for (var result in values) result.id: result
//   };

//   static VerificationResult? fromId(int id) => _valuesById[id];
// }

