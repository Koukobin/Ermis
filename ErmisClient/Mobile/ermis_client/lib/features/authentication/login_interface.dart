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
import 'package:ermis_mobile/features/authentication/register_interface.dart';
import 'package:ermis_mobile/features/authentication/verification_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import '../../core/data_sources/api_client.dart';
import 'domain/entities/login_info.dart';
import '../../constants/app_constants.dart';
import '../../core/util/device_utils.dart';
import '../../core/util/dialogs_utils.dart';
import '../../core/util/top_app_bar_utils.dart';
import '../../core/util/transitions_util.dart';
import '../../core/widgets/custom_textfield.dart';
import '../../generated/l10n.dart';
import '../../main.dart';
import '../../theme/app_colors.dart';
import 'utils/entry_buttons.dart';

class LoginInterface extends StatefulWidget {
  const LoginInterface({super.key});

  @override
  State<LoginInterface> createState() => LoginInterfaceState();
}

class LoginInterfaceState extends State<LoginInterface> with Verification, EntryButtons {
  static bool isDisplaying = false;

  // Controllers for user input
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _backupVerificationController = TextEditingController();

  PasswordType passwordType = PasswordType.password;

  LoginEntry loginEntry = Client.instance().createNewLoginEntry();
  
  bool get _useBackupverificationCode => passwordType == PasswordType.backupVerificationCode;
  bool get _usePassword => passwordType == PasswordType.password;

  set _useBackupverificationCode(bool useBackup) => passwordType = useBackup ? PasswordType.backupVerificationCode : PasswordType.password;
  // ignore: unused_element
  set _usePassword(bool usePassword) => passwordType = usePassword ? PasswordType.password : PasswordType.backupVerificationCode;

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
                                key: const ValueKey('backupCode'), // Unique key for backup verification code
                                controller: _backupVerificationController,
                                hint: S.current.backup_verification_code,
                              )
                            : CustomTextField(
                                keyboardType: TextInputType.text,
                                controller: _passwordController,
                                hint: S.current.password,
                                obscureText: true,
                              ),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          // return ScaleTransition(scale: animation, child: child,);
                          // return SizeTransition(sizeFactor: animation, child: child,);
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: _useBackupverificationCode ? const Offset(1, 0) : const Offset(-1, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      buildButton(
                        label: S.current.login,
                        icon: Icons.login,
                        backgroundColor: appColors.secondaryColor,
                        textColor: appColors.primaryColor,
                        onPressed: () async {
                          if (_emailController.text.isEmpty) {
                            showToastDialog(S.current.email_is_empty);
                            return;
                          }

                          if (_passwordController.text.isEmpty && _backupVerificationController.text.isEmpty) {
                            showToastDialog(S.current.password_is_empty);
                            return;
                          }

                          loginEntry.sendEntryType();
                          loginEntry.addDeviceInfo(await getDeviceType(), await getDeviceDetails());
                          loginEntry.setPasswordType(passwordType);

                          loginEntry.sendCredentials({
                            LoginCredential.email: _emailController.text,
                            LoginCredential.password: _useBackupverificationCode ? _backupVerificationController.text : _passwordController.text,
                          });
                          
                          Resultable entryResult = await loginEntry.getCredentialsExchangeResult();

                          bool isExchangeSuccessful = entryResult.isSuccessful;
                          String resultMessage = entryResult.message;

                          if (!isExchangeSuccessful) {
                            showSnackBarDialog(
                                context: context,
                                content: S.current.registration_failed(resultMessage));
                            return;
                          }
                          
                          bool isSuccessful = false;

                          // If password is used, further verification/authentication is required
                          if (_usePassword) {
                            isSuccessful = await performRegistrationVerification(context, _emailController.text);
                          } else {
                            entryResult = await loginEntry.getBackupVerificationCodeResult();
                            isSuccessful = entryResult.isSuccessful;
                            showToastDialog(entryResult.message);
                          }

                          if (isSuccessful) {
                            await showLoadingDialog(context, Client.instance().fetchUserInformation());
                            // Navigate to the main interface
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const MainInterface()),
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
                          textStyle: const TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        label: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          switchInCurve: Curves.easeInOut,
                          switchOutCurve: Curves.easeInOut,
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return ScaleTransition(
                              scale: animation,
                              child: child,
                            );
                          },
                          child: _useBackupverificationCode
                              ? Text(
                                  key: const ValueKey("switch-to-password"),
                                  S.current.use_password,
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: appColors.inferiorColor),
                                )
                              : Text(
                                  key: const ValueKey("switch-to-backup-verification-code"),
                                  S.current.use_backup_verification_code,
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

            buildButton(
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