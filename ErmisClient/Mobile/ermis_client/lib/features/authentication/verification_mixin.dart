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

import 'package:ermis_mobile/core/data_sources/api_client.dart';
import 'package:ermis_mobile/core/networking/user_info_manager.dart';
import 'package:ermis_mobile/core/services/database/extensions/accounts_extension.dart';
import 'package:ermis_mobile/core/services/database/models/local_account_info.dart';
import 'package:ermis_mobile/features/authentication/domain/entities/added_info.dart';
import 'package:ermis_mobile/core/networking/common/results/entry_result.dart';
import 'package:ermis_mobile/core/services/database/database_service.dart';
import 'package:ermis_mobile/core/util/dialogs_utils.dart';
import 'package:ermis_mobile/features/authentication/domain/entities/verification.dart';
import 'package:ermis_mobile/generated/l10n.dart';
import 'package:flutter/material.dart';

Future<void> showVerificationDialog({
  required BuildContext context,
  required String title,
  required String promptMessage,
  required VoidCallback onResendCode,
  required void Function(int code) onSumbittedCode,
}) async {
  final TextEditingController codeController = TextEditingController();
  bool isSubmitting = false;

  await showDialog(
    context: context,
    barrierDismissible: false, // Prevents exiting dialog from tapping out of it
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return WhatsAppPopupDialog(
            child: AlertDialog(
              title: Text(title),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(promptMessage),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: codeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: S.current.enter_verification_code,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: isSubmitting ? null : onResendCode,
                        style: ElevatedButton.styleFrom(
                          maximumSize: Size(
                            // Constraint maximum width so widget cannot go out of bounds;
                            // this is not a problem in English, in other languages however,
                            // with longer text strings - this could potentially pose an issue
                            MediaQuery.of(context).size.width * 0.4,
                            MediaQuery.of(context).size.height,
                          ),
                        ),
                        child: Text(S.current.resend_code),
                      ),
                      ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () {
                                final codeString = codeController.text.trim();
                                if (codeString.isEmpty) {
                                  showToastDialog(
                                      S.current.please_enter_the_verification_code);
                                  return;
                                }
            
                                int? codeInt = int.tryParse(codeString);
            
                                if (codeInt == null) {
                                  showToastDialog(
                                      S.current.verification_code_must_be_number);
                                  return;
                                }
            
                                setState(() {
                                  isSubmitting = true;
                                });

                                // Set a delay to close dialog
                                Future.delayed(const Duration(seconds: 1), () {
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                  }

                                  onSumbittedCode(codeInt);
                                }).whenComplete(() {
                                  setState(() {
                                    isSubmitting = false;
                                  });
                                });
                              },
                        style: ElevatedButton.styleFrom(
                          maximumSize: Size(
                            // Constraint maximum width so widget cannot go out of bounds;
                            // this is not a problem in English, in other languages however,
                            // with longer text strings - this could potentially pose an issue
                            MediaQuery.of(context).size.width * 0.4,
                            MediaQuery.of(context).size.height,
                          ),
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(S.current.submit),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  ).then((_) => codeController.clear());
}

mixin Verification {

  Future<bool> performDeleteAccountVerification(BuildContext context, String email) async {
    Entry verificationEntry = Client.instance().createNewVerificationEntry();
    EntryResult entryResult;

    bool isSuccessful = false;

    for (;;) {
      Future<EntryResult> entryResultFuture = verificationEntry.getResult();

      await showVerificationDialog(
          context: context,
          title: S.current.verification,
          promptMessage: S.current.enter_verification_code_sent_to_your_email,
          onResendCode: () => verificationEntry.resendVerificationCodeToEmail(),
          onSumbittedCode: verificationEntry.sendVerificationCode);

      entryResult = await entryResultFuture;
      isSuccessful = entryResult.result.isSuccessful;
      String resultMessage = entryResult.result.message;

      if (isSuccessful) {
        showToastDialog(resultMessage);
        break;
      }

      showToastDialog(resultMessage);

      // If the operation failed (success == false) and the result is not 
      // a verification attempt - meaning it's either a login or account 
      // creation - then break due to authentication failure.
      if (entryResult.result is! VerificationResult) {
        break;
      }
    }

    return isSuccessful;
  }

  Future<bool> performChangePasswordVerification(BuildContext context, String email) async {
    Entry verificationEntry = Client.instance().createNewVerificationEntry();
    EntryResult entryResult;

    bool isSuccessful = false;

    for (;;) {
      Future<EntryResult> entryResultFuture = verificationEntry.getChangePasswordResult();

      await showVerificationDialog(
          context: context,
          title: S.current.verification,
          promptMessage: S.current.enter_verification_code_sent_to_your_email,
          onResendCode: () => verificationEntry.resendVerificationCodeToEmail(),
          onSumbittedCode: verificationEntry.sendVerificationCode);

      entryResult = await entryResultFuture;
      isSuccessful = entryResult.result.isSuccessful;
      String resultMessage = entryResult.result.message;

      if (isSuccessful) {
        showToastDialog(resultMessage);

        final accountInfo = LocalAccountInfo.fuck(
          email: email,
          passwordHash: entryResult.addedInfo[AddedInfo.passwordHash]!,
          deviceUUID: UserInfoManager.accountInfo!.deviceUUID,
        );
        ErmisDB.getConnection().addUserAccount(
          accountInfo,
          UserInfoManager.serverInfo,
        );

        UserInfoManager.accountInfo = accountInfo;
        break;
      }

      showToastDialog(resultMessage);

      // If the operation failed (success == false) and the result is not 
      // a verification attempt - meaning it's either a login or account 
      // creation - then break due to authentication failure.
      if (entryResult.result is! VerificationResult) {
        break;
      }
    }

    return isSuccessful;
  }

  Future<bool> getBackupVerification(BuildContext context, LoginEntry loginEntry, String email) async {
    EntryResult entryResult = await loginEntry.getBackupVerificationCodeResult();

    showToastDialog(entryResult.message);
    if (entryResult.success) {
      final accountInfo = LocalAccountInfo.fuck(
        email: email,
        passwordHash: entryResult.addedInfo[AddedInfo.passwordHash]!,
        deviceUUID: entryResult.addedInfo[AddedInfo.deviceUUID]!,
      );
      ErmisDB.getConnection().addUserAccount(
        accountInfo,
        UserInfoManager.serverInfo,
      );

      UserInfoManager.accountInfo = accountInfo;
    }

    return entryResult.success;
  }

  Future<bool> performRegistrationVerification(BuildContext context, String email) async {
    Entry verificationEntry = Client.instance().createNewVerificationEntry();
    EntryResult entryResult;

    bool isSuccessful = false;

    for (;;) {
      Future<EntryResult> entryResultFuture = verificationEntry.getResult();

      await showVerificationDialog(
          context: context,
          title: S.current.verification,
          promptMessage: S.current.enter_verification_code_sent_to_your_email,
          onResendCode: () => verificationEntry.resendVerificationCodeToEmail(),
          onSumbittedCode: verificationEntry.sendVerificationCode);

      entryResult = await entryResultFuture;
      isSuccessful = entryResult.success;
      String resultMessage = entryResult.message;

      if (isSuccessful) {
        showToastDialog(resultMessage);

        final accountInfo = LocalAccountInfo.fuck(
          email: email,
          passwordHash: entryResult.addedInfo[AddedInfo.passwordHash]!,
          deviceUUID: entryResult.addedInfo[AddedInfo.deviceUUID]!,
        );
        ErmisDB.getConnection().addUserAccount(
          accountInfo,
          UserInfoManager.serverInfo,
        );

        UserInfoManager.accountInfo = accountInfo;
        break;
      }

      showToastDialog(resultMessage);

      // If the operation failed (success == false) and the result is not 
      // a verification attempt - meaning it's either a login or account 
      // creation - then break due to authentication failure.
      if (entryResult.result is! VerificationResult) {
        break;
      }
    }

    return isSuccessful;
  }
}
