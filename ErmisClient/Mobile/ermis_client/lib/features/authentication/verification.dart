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

import 'package:ermis_client/core/data_sources/api_client.dart';
import 'package:ermis_client/features/authentication/domain/entities/added_info.dart';
import 'package:ermis_client/client/common/results/entry_result.dart';
import 'package:ermis_client/core/services/database_service.dart';
import 'package:ermis_client/core/util/dialogs_utils.dart';
import 'package:ermis_client/generated/l10n.dart';
import 'package:flutter/material.dart';

Future<void> _showVerificationDialog({
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
                        onPressed: isSubmitting
                            ? null
                            : () {
                                onResendCode();
                              },
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
                                  Navigator.of(context).pop();
                                  onSumbittedCode(codeInt);
                                }).whenComplete(() {
                                  setState(() {
                                    isSubmitting = false;
                                  });
                                });
                              },
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

  Future<bool> performVerification(BuildContext context, String email) async {
    Entry verificationEntry = Client.instance().createNewVerificationEntry();
    EntryResult entryResult;

    bool isSuccessful = false;

    while (!verificationEntry.isVerificationComplete) {
      await _showVerificationDialog(
          context: context,
          title: S.current.verification,
          promptMessage: S.current.enter_verification_code_sent_to_your_email,
          onResendCode: () => verificationEntry.resendVerificationCode(),
          onSumbittedCode: verificationEntry.sendVerificationCode);

      entryResult = await verificationEntry.getResult();
      isSuccessful = entryResult.resultHolder.isSuccessful;
      String resultMessage = entryResult.resultHolder.message;

      if (isSuccessful) {
        showToastDialog(resultMessage);
        ErmisDB.getConnection().addUserAccount(
            LocalAccountInfo.fuck(
                email: email,
                passwordHash: entryResult.addedInfo[AddedInfo.passwordHash]!),
            Client.instance().serverInfo);
        break;
      }

      showToastDialog(resultMessage);
    }

    return isSuccessful;
  }
}
