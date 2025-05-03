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

import 'package:ermis_client/features/authentication/domain/entities/requirements.dart';
import 'package:ermis_client/features/authentication/domain/entities/resultable.dart';
import 'package:ermis_client/features/authentication/utils/entry_buttons.dart';
import 'package:ermis_client/features/authentication/login_interface.dart';
import 'package:ermis_client/features/authentication/verification_mixin.dart';
import 'package:ermis_client/generated/l10n.dart';
import 'package:ermis_client/core/widgets/custom_textfield.dart';
import 'package:ermis_client/theme/app_colors.dart';
import 'package:ermis_client/core/util/device_utils.dart';
import 'package:ermis_client/core/util/dialogs_utils.dart';
import 'package:ermis_client/core/util/entropy_calculator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import 'domain/entities/create_account_info.dart';
import '../../constants/app_constants.dart';
import '../../main.dart';
import '../../core/util/top_app_bar_utils.dart';
import '../../core/data_sources/api_client.dart';
import '../../core/util/transitions_util.dart';

class CreateAccountInterface extends StatefulWidget {
  const CreateAccountInterface({super.key});

  @override
  State<CreateAccountInterface> createState() => CreateAccountInterfaceState();
  
}

class CreateAccountInterfaceState extends State<CreateAccountInterface> with Verification, EntryButtons {
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
                      // Email Address
                      CustomTextField(
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController,
                        hint: S.current.email,
                      ),
                      const SizedBox(height: 8),

                      // Username
                      CustomTextField(
                        maxLength: _usernameRequirements.maxLength,
                        illegalCharacters: _usernameRequirements.invalidCharacters,
                        keyboardType: TextInputType.name,
                        controller: _usernameController,
                        hint: S.current.display_name,
                      ),
                      const SizedBox(height: 8),

                      // Password
                      CustomTextField(
                        maxLength: _passwordRequirements.maxLength,
                        illegalCharacters: _passwordRequirements.invalidCharacters,
                        keyboardType: TextInputType.twitter,
                        controller: _passwordController,
                        hint: S.current.password,
                        obscureText: true,
                      ),
                      const SizedBox(height: 4),

                      // Entropy
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

                      // Register
                      buildButton(
                        label: S.current.create_account,
                        icon: Icons.account_circle,
                        backgroundColor: appColors.secondaryColor,
                        textColor: appColors.primaryColor,
                        onPressed: () async {
                          createAccountEntry.sendEntryType();
                          createAccountEntry.addDeviceInfo(await getDeviceType(), await getDeviceDetails());
                          createAccountEntry.sendCredentials({
                            CreateAccountCredential.email: _emailController.text,
                            CreateAccountCredential.username: _usernameController.text,
                            CreateAccountCredential.password: _passwordController.text,
                          });
                      
                          Resultable entryResult = await createAccountEntry.getCredentialsExchangeResult();
                      
                          bool isSuccessful = entryResult.isSuccessful;
                          String resultMessage = entryResult.message;
                      
                          if (!isSuccessful) {
                            showSnackBarDialog(context: context, content: resultMessage);
                            return;
                          }
                      
                          isSuccessful = await performRegistrationVerification(context, _emailController.text);
                      
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
                      )
                    ]),
              ),
            ),

            // Switch to login
            buildButton(
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

