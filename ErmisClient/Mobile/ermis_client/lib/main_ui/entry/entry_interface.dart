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

import 'package:ermis_client/client/common/entry/requirements.dart';
import 'package:ermis_client/generated/l10n.dart';
import 'package:ermis_client/main_ui/custom_textfield.dart';
import 'package:ermis_client/theme/app_colors.dart';
import 'package:ermis_client/util/device_utils.dart';
import 'package:ermis_client/util/dialogs_utils.dart';
import 'package:ermis_client/util/entropy_calculator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import '../../client/common/entry/added_info.dart';
import '../../client/common/entry/create_account_info.dart';
import '../../client/common/entry/login_info.dart';
import '../../client/common/results/entry_result.dart';
import '../../constants/app_constants.dart';
import '../../main.dart';
import '../../util/database_service.dart';
import '../../util/top_app_bar_utils.dart';
import '../../client/client.dart';
import '../../util/transitions_util.dart';

class CreateAccountInterface extends StatefulWidget {
  const CreateAccountInterface({super.key});

  @override
  State<CreateAccountInterface> createState() => CreateAccountInterfaceState();
  
}

class CreateAccountInterfaceState extends State<CreateAccountInterface> with Verification {
  static bool isDisplaying = false;

  // Controllers for user input
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late final CreateAccountEntry createAccountEntry;

  Requirements _passwordRequirements = Requirements.empty(); // By default empty
  Requirements _usernameRequirements = Requirements.empty(); // By default empty

  double _passwordEntropy = 0.0;

  @override
  void initState() {
    super.initState();
    isDisplaying = true;
    createAccountEntry = Client.instance().createNewCreateAccountEntry();
    createAccountEntry.sendEntryType();

    createAccountEntry.fetchCredentialRequirements().whenComplete(() {
      _passwordRequirements = createAccountEntry.passwordRequirements!;
      _usernameRequirements = createAccountEntry.usernameRequirements!;
      setState(() {});
    });

    _passwordController.addListener(() {
      _passwordEntropy = EntropyCalculator.calculateEntropy(_passwordController.text);
      setState(() {});
    }); 
  }

  @override
  void dispose() {
    isDisplaying = false;
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      appBar: ErmisAppBar(),
      backgroundColor: appColors.tertiaryColor,
      resizeToAvoidBottomInset: false, // Prevent resizing when keyboard opens
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 60.0, 16.0, 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // App icon display
            Image.asset(
              AppConstants.appIconPath,
              width: 100,
              height: 100,
            ),

            KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
              if (isKeyboardVisible) {
                return const SizedBox.shrink();
              }
              return Container(margin: const EdgeInsets.only(top: 30));
            }),

            // Form section for login
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomTextField(
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailController,
                          hint: S.current.email),
                      const SizedBox(height: 8),
                      CustomTextField(
                          maxLength: _usernameRequirements.maxLength,
                          illegalCharacters: _usernameRequirements.invalidCharacters,
                          keyboardType: TextInputType.name,
                          controller: _usernameController,
                          hint: S.current.display_name),
                      const SizedBox(height: 8),
                      CustomTextField(
                          maxLength: _passwordRequirements.maxLength,
                          illegalCharacters: _passwordRequirements.invalidCharacters,
                          keyboardType: TextInputType.twitter,
                          controller: _passwordController,
                          hint: S.current.password,
                          obscureText: true),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Flexible so text is flexible and does not exceed screen
                          Flexible(
                            child: Text(
                              S.current.entropy_rough_estimate(double.parse((_passwordEntropy).toStringAsFixed(3))),
                              style: const TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ),
                          // Flexible so text is flexible and does not exceed screen
                          Flexible( 
                            child: Text(
                              S.current.min_entropy(_passwordRequirements.minEntropy ?? 0),
                              style: const TextStyle(fontStyle: FontStyle.italic),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 3),
                      LinearProgressIndicator(
                        value: (_passwordEntropy / 100),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(3.25),
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color.lerp(
                                  Colors.red, Colors.green, _passwordEntropy / 100) ??
                              Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _buildButton(
                        label: S.current.create_account,
                        icon: Icons.account_circle,
                        backgroundColor: appColors.secondaryColor,
                        textColor: appColors.primaryColor,
                        onPressed: () async {
                          createAccountEntry.sendEntryType();
                          createAccountEntry.addDeviceInfo(await getDeviceType(), await getDeviceDetails());
                          createAccountEntry.sendCredentials({
                            CreateAccountCredential.email:
                                _emailController.text,
                            CreateAccountCredential.username:
                                _usernameController.text,
                            CreateAccountCredential.password:
                                _passwordController.text,
                          });
                      
                          A entryResult = await createAccountEntry.getCredentialsExchangeResult();
                      
                          bool isSuccessful = entryResult.isSuccessful;
                          String resultMessage = entryResult.message;
                      
                          if (!isSuccessful) {
                            showSnackBarDialog(context: context, content: resultMessage);
                            return;
                          }
                      
                          isSuccessful = await performVerification(context, _emailController.text);
                      
                          if (isSuccessful) {
                            Client.instance().startMessageHandler();
                            await showLoadingDialog(context,
                                Client.instance().fetchUserInformation());
                            // Navigate to the main interface
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MainInterface()),
                              (route) => false, // Removes all previous routes.
                            );
                          }
                        },
                      )
                    ]),
              ),
            ),

            _buildButton(
              label: S.current.login,
              icon: Icons.login,
              backgroundColor: appColors.primaryColor,
              textColor: appColors.secondaryColor,
              onPressed: () {
                if (LoginInterfaceState.isDisplaying) {
                  isDisplaying = false;
                  Navigator.of(context).pop();
                  return;
                }

                Navigator.of(context).push(createVerticalTransition(
                  const LoginInterface(),
                  DirectionYAxis.bottomToTop,
                ));
              },
            ),
          ],
        ),
      ),
    );
  }

}

class LoginInterface extends StatefulWidget {
  const LoginInterface({super.key});

  @override
  State<LoginInterface> createState() => LoginInterfaceState();
}

class LoginInterfaceState extends State<LoginInterface> with Verification {
  static bool isDisplaying = false;

  // Controllers for user input
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _backupVerificationController = TextEditingController();

  bool _useBackupverificationCode = false;

  LoginEntry loginEntry = Client.instance().createNewLoginEntry();

  @override
  void initState() {
    super.initState();
    isDisplaying = true;
  }

  @override
  void dispose() {
    isDisplaying = false;
    _emailController.dispose();
    _passwordController.dispose();
    _backupVerificationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      appBar: ErmisAppBar(centerTitle: false, removeDivider: true),
      backgroundColor: appColors.secondaryColor,
      resizeToAvoidBottomInset: false, // Prevent resizing when keyboard opens
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 60.0, 16.0, 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // App icon display
            Image.asset(
              AppConstants.appIconPath,
              width: 100,
              height: 100,
            ),

            KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
              if (isKeyboardVisible) {
                return const SizedBox.shrink();
              }
              return Container(margin: const EdgeInsets.only(top: 32));
            }),

            // Form section for login
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomTextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        hint: S.current.email,
                      ),
                      const SizedBox(height: 8),
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 600),
                        switchInCurve: Curves.easeInOut,
                        switchOutCurve: Curves.easeInOut,
                        child: _useBackupverificationCode
                            ? CustomTextField(
                                key: ValueKey('backupCode'), // Unique key for backup verification code
                                controller: _backupVerificationController,
                                hint: S.current.backup_verification_code,
                              )
                            : CustomTextField(
                                keyboardType: TextInputType.twitter,
                                controller: _passwordController,
                                hint: S.current.password,
                                obscureText: true),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          // return ScaleTransition(scale: animation, child: child,);
                          // return SizeTransition(sizeFactor: animation, child: child,);
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: _useBackupverificationCode ? Offset(1, 0) : Offset(-1, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildButton(
                        label: S.current.login,
                        icon: Icons.login,
                        backgroundColor: appColors.secondaryColor,
                        textColor: appColors.primaryColor,
                        onPressed: () async {
                          if (_emailController.text.isEmpty) {
                            showToastDialog(S.current.email_is_empty);
                            return;
                          }

                          if (_passwordController.text.isEmpty) {
                            showToastDialog(S.current.password_is_empty);
                            return;
                          }

                          loginEntry.sendEntryType();
                          loginEntry.addDeviceInfo(await getDeviceType(), await getDeviceDetails());

                          if (_useBackupverificationCode) {
                            loginEntry.togglePasswordType();
                          }

                          loginEntry.sendCredentials({
                            LoginCredential.email: _emailController.text,
                            LoginCredential.password: _passwordController.text,
                          });

                          A entryResult = await loginEntry.getCredentialsExchangeResult();

                          bool isSuccessful = entryResult.isSuccessful;
                          String resultMessage = entryResult.message;

                          if (!isSuccessful) {
                            showSnackBarDialog(
                                context: context,
                                content: S.current
                                    .registration_failed(resultMessage));
                            return;
                          }

                          // If password is used, further verification/authentication is required
                          if (!_useBackupverificationCode) {
                            isSuccessful = await performVerification(context, _emailController.text);
                          }

                          if (isSuccessful) {
                            Client.instance().startMessageHandler();
                            await showLoadingDialog(context, Client.instance().fetchUserInformation());
                            // Navigate to the main interface
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MainInterface()),
                              (route) => false, // Removes all previous routes.
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      Center(
                          child: Text(
                        S.current.or,
                        style: TextStyle(color: appColors.primaryColor, fontSize: 16),
                      )),
                      const SizedBox(height: 10),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _useBackupverificationCode = !_useBackupverificationCode;
                          });
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: appColors.quaternaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          textStyle: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        label: AnimatedSwitcher(
                          duration: Duration(milliseconds: 400),
                          switchInCurve: Curves.easeInOut,
                          switchOutCurve: Curves.easeInOut,
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return ScaleTransition(
                              scale: animation,
                              child: child,
                            );
                          },
                          child: _useBackupverificationCode
                              ? Text(
                                  key: ValueKey("sex"),
                                  "Use Password",
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: appColors.inferiorColor),
                                )
                              : Text(
                                  key: ValueKey("anal"),
                                  "Use Backup-Verification Code",
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: appColors.inferiorColor),
                                ),
                        ),
                      ),
                      // _buildTextButton(
                      //     label:
                      //         "${_useBackupverificationCode ? "Unuse" : "Use"} backup verification code",
                      //     icon: null,
                      //     backgroundColor: appColors.quaternaryColor,
                      //     textColor: appColors.inferiorColor,
                      //     onPressed: () {
                      //       setState(() {
                      //         _useBackupverificationCode =
                      //             !_useBackupverificationCode;
                      //       });
                      //     }),
                    ]),
              ),
            ),

            _buildButton(
                label: S.current.create_account,
                icon: Icons.account_circle,
                backgroundColor: appColors.primaryColor,
                textColor: appColors.secondaryColor,
                onPressed: () {
                  if (CreateAccountInterfaceState.isDisplaying) {
                    isDisplaying = false;
                    Navigator.of(context).pop();
                    return;
                  }

                  Navigator.of(context).push(createVerticalTransition(
                    const CreateAccountInterface(),
                    DirectionYAxis.bottomToTop,
                  ));
                })
          ],
        ),
      ),
    );
  }
}

Widget _buildButton({
  required String label,
  required IconData icon,
  required Color backgroundColor,
  required Color textColor,
  required VoidCallback onPressed,
}) {
  return ElevatedButton.icon(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 17),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.white30, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    icon: Icon(
      icon,
      color: textColor,
    ),
    label: Text(
      label,
      style: TextStyle(fontSize: 18, color: textColor),
    ),
  );
}

Widget _buildTextButton({
  required String label,
  IconData? icon,
  required Color backgroundColor,
  required Color textColor,
  required VoidCallback onPressed,
}) {
  return TextButton.icon(
    onPressed: onPressed,
    style: TextButton.styleFrom(
      backgroundColor: backgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 18),
      textStyle: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    icon: icon == null ? null : Icon(
      icon,
      color: textColor,
    ),
    label: Text(
      label,
      style: TextStyle(fontSize: 18, color: textColor),
    ),
  );
}

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
                                  showSnackBarDialog(
                                      context: context,
                                      content:
                                          S.current.please_enter_the_verification_code);
                                  return;
                                }
            
                                int? codeInt = int.tryParse(codeString);
            
                                if (codeInt == null) {
                                  showSnackBarDialog(
                                      context: context,
                                      content:
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
