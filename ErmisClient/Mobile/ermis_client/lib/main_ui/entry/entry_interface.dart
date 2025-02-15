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

import 'package:ermis_client/main_ui/custom_textfield.dart';
import 'package:ermis_client/util/device_utils.dart';
import 'package:ermis_client/util/dialogs_utils.dart';
import 'package:flutter/material.dart';

import '../../client/common/entry/added_info.dart';
import '../../client/common/entry/create_account_info.dart';
import '../../client/common/entry/login_info.dart';
import '../../client/common/results/ResultHolder.dart';
import '../../client/common/results/entry_result.dart';
import '../../constants/app_constants.dart';
import '../../theme/app_theme.dart';
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

  @override
  void initState() {
    super.initState();
    isDisplaying = true;
  }

    @override
  void dispose() {
    super.dispose();
    isDisplaying = false;
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      appBar: const ErmisAppBar(),
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

            // Form section for login
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomTextField(
                          controller: _emailController, hint: "Email"),
                      SizedBox(height: 8),
                      CustomTextField(
                          controller: _usernameController,
                          hint: "Display Name"),
                      SizedBox(height: 8),
                      CustomTextField(
                          controller: _passwordController,
                          hint: "Password",
                          obscureText: true),
                      SizedBox(height: 8),
                      _buildButton(
                        label: "Create Account",
                        icon: Icons.account_circle,
                        backgroundColor: appColors.secondaryColor,
                        textColor: appColors.primaryColor,
                        onPressed: () async {
                          CreateAccountEntry createAccountEntry =
                              Client.instance()
                                  .createNewCreateAccountEntry();
                          createAccountEntry.sendEntryType();
                          createAccountEntry.addDeviceInfo(
                              await getDeviceType(), await getDeviceDetails());
                          createAccountEntry.sendCredentials({
                            CreateAccountCredential.email:
                                _emailController.text,
                            CreateAccountCredential.username:
                                _usernameController.text,
                            CreateAccountCredential.password:
                                _passwordController.text,
                          });

                          ResultHolder entryResult = await createAccountEntry
                              .getCredentialsExchangeResult();

                          bool isSuccessful = entryResult.isSuccessful;
                          String resultMessage = entryResult.message;

                          if (!isSuccessful) {
                            showSnackBarDialog(
                                context: context, content: resultMessage);
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
                    ]
                ),
              ),
            ),

            _buildButton(
              label: "Login",
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
                    LoginInterface(), DirectionYAxis.bottomToTop));
              },
            )
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

  @override
  void initState() {
    super.initState();
    isDisplaying = true;
  }

  @override
  void dispose() {
    super.dispose();
    isDisplaying = false;
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      appBar: const ErmisAppBar(centerTitle: false, removeDivider: true,),
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

            // Form section for login
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomTextField(controller: _emailController, hint: "Email"),
                      const SizedBox(height: 8),
                      AnimatedSwitcher(
                        duration: Duration(milliseconds: 600),
                        switchInCurve: Curves.easeInOut,
                        switchOutCurve: Curves.easeInOut,
                        child: _useBackupverificationCode
                            ? CustomTextField(
                                key: ValueKey('backupCode'), // Unique key for backup verification code
                                controller: _backupVerificationController,
                                hint: "Backup-Verification Code",
                                obscureText: true)
                            : CustomTextField(
                                key: ValueKey('password'),
                                controller: _passwordController,
                                hint: "Password",
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
                      SizedBox(height: 8),
                      _buildButton(
                        label: "Login",
                        icon: Icons.login,
                        backgroundColor: appColors.secondaryColor,
                        textColor: appColors.primaryColor,
                        onPressed: () async {
                          if (_emailController.text.isEmpty) {
                            showToastDialog("Email is empty!");
                            return;
                          }

                          if (_passwordController.text.isEmpty) {
                            showToastDialog("Password is empty!");
                            return;
                          }

                          LoginEntry loginEntry = Client.instance().createNewLoginEntry();
                          loginEntry.sendEntryType();
                          loginEntry.addDeviceInfo(await getDeviceType(), await getDeviceDetails());

                          if (_useBackupverificationCode) {
                            loginEntry.togglePasswordType();
                          }

                          loginEntry.sendCredentials({
                            LoginCredential.email: _emailController.text,
                            LoginCredential.password: _passwordController.text,
                          });

                          ResultHolder entryResult = await loginEntry.getCredentialsExchangeResult();

                          bool isSuccessful = entryResult.isSuccessful;
                          String resultMessage = entryResult.message;

                          if (!isSuccessful) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      "Registration failed: $resultMessage")),
                            );
                            return;
                          }

                          // If password is used, further verification/authentication is required
                          if (!_useBackupverificationCode) {
                            isSuccessful = await performVerification(context, _emailController.text);
                          }

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
                      ),
                      const SizedBox(height: 10),
                      Center(
                          child: Text(
                        "OR",
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
                        label: AnimatedSwitcher(duration: Duration(milliseconds: 400), child: _useBackupverificationCode ? Text(
                          key: ValueKey("sex"),
                          "Use Password",
                          style: TextStyle(
                              fontSize: 18, color: appColors.inferiorColor),
                        ) : Text(
                          key: ValueKey("anal"),
                          "Use Backup-Verification Code",
                          style: TextStyle(
                              fontSize: 18, color: appColors.inferiorColor),
                        ),
                        
                        switchInCurve: Curves.easeInOut,
                        switchOutCurve: Curves.easeInOut,
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                                return ScaleTransition(scale: animation, child: child,);
                              },
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
                label: "Create Account",
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
                      CreateAccountInterface(), DirectionYAxis.bottomToTop));
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
                    decoration: const InputDecoration(
                      labelText: 'Enter Verification Code',
                      border: OutlineInputBorder(),
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
                        child: const Text('Resend Code'),
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
                                          'Please enter the verification code');
                                  return;
                                }
            
                                int? codeInt = int.tryParse(codeString);
            
                                if (codeInt == null) {
                                  showSnackBarDialog(
                                      context: context,
                                      content:
                                          "Verification code must be number");
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
                            : const Text('Submit'),
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
          title: "Verification",
          promptMessage: "Enter verification code sent to your email",
          onResendCode: () => verificationEntry.resendVerificationCode(),
          onSumbittedCode: verificationEntry.sendVerificationCode);

      entryResult = await verificationEntry.getResult();
      isSuccessful = entryResult.isSuccessful;
      String resultMessage = entryResult.message;

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
