/* Copyright (C) 2026 Ilias Koukovinis <ilias.koukovinis@gmail.com>
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

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import '../../../../constants/app_constants.dart';
import '../../../../core/data_sources/api_client.dart';
import '../../../../core/util/top_app_bar_utils.dart';
import '../../../../core/widgets/custom_textfield.dart';
import '../../../../core/widgets/scroll/custom_scroll_view.dart';
import '../../../../generated/l10n.dart';
import '../../../../theme/app_colors.dart';
import '../../../authentication/utils/entry_buttons.dart';
import '../../../authentication/verification_mixin.dart';

class ChangePasswordSettings extends StatefulWidget {
  const ChangePasswordSettings({super.key});

  @override
  State<ChangePasswordSettings> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordSettings>
    with Verification, EntryButtons {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _changePassword() async {
    Client.instance().commands?.changePassword(_emailController.text, _passwordController.text);
    await performChangePasswordVerification(context, _emailController.text);
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      appBar: ErmisAppBar(titleText: S.current.changePassword),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 60.0, 16.0, 16.0),
        child: ScrollViewFixer.createScrollViewWithAppBarSafety(
            scrollView: ListView(
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

            // Input field for email address
            Padding(
              padding: const EdgeInsets.only(top: 48),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    hint: S.current.email,
                  ),
              
                  // Add space below the email input field
                  const SizedBox(height: 10),
              
                  // Input field for password
                  CustomTextField(
                    keyboardType: TextInputType.text,
                    controller: _passwordController,
                    hint: S.current.password,
                    obscureText: true,
                  ),
              
                  // Add space below the password input field
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Button to change password
            buildButton(
              label: S.current.changePassword,
              backgroundColor: appColors.secondaryColor,
              icon: Icons.password,
              onPressed: _changePassword,
              textColor: appColors.primaryColor,
            ),
          ],
        ),
      )),
    );
  }
}