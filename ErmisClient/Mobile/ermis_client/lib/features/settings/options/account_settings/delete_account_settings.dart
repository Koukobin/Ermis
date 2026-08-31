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

import 'package:flutter/material.dart';

import '../../../../core/data_sources/api_client.dart';
import '../../../../core/util/screen_reset.dart';
import '../../../../core/util/top_app_bar_utils.dart';
import '../../../../core/widgets/custom_textfield.dart';
import '../../../../core/widgets/scroll/custom_scroll_view.dart';
import '../../../../generated/l10n.dart';
import '../../../../theme/app_colors.dart';
import '../../../authentication/verification_mixin.dart';

class DeleteAccountSettings extends StatefulWidget {
  const DeleteAccountSettings({super.key});

  @override
  State<DeleteAccountSettings> createState() => _DeleteAccountSettingsState();
}

class _DeleteAccountSettingsState extends State<DeleteAccountSettings>
    with Verification {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: appColors.secondaryColor,
      appBar: ErmisAppBar(titleText: S.current.accountDelete),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 16.0),
        child: ScrollViewFixer.createScrollViewWithAppBarSafety(
            scrollView: ListView(
          children: [
            Row(
              children: [
                // Display a warning icon in red
                const Icon(Icons.warning_amber_rounded, color: Colors.red),

                // Add space between the icon and text
                const SizedBox(width: 20),

                // Display the warning text about account deletion
                Text(S.current.accountDeleteConfirmation,
                    style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16))
              ],
            ),

            // Add space below the warning text
            const SizedBox(height: 16),

            // Display bullet points explaining what will happen if the account is deleted
            buildBullet(S.current.accountDeleteBullet1),
            buildBullet(S.current.accountDeleteBullet2),
            buildBullet(S.current.accountDeleteBullet3),

            // Add space below the bullet points
            const SizedBox(height: 30),

            // Text
            Text(
              S.current.areYouCertainYouWantToProceed,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.red,
                letterSpacing: 1.7,
              ),
            ),

            // Add space
            const SizedBox(height: 35),

            // Input field for email address
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

            // Button to delete the account
            ElevatedButton(
              onPressed: () async {
                Client.instance().commands?.deleteAccount(
                      _emailController.text,
                      _passwordController.text,
                    );
                final isSuccessful = await performDeleteAccountVerification(
                  context,
                  _emailController.text,
                );

                if (!mounted) return;
                if (isSuccessful) resetToStartingScreen(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size.fromHeight(50),
              ),
              child: Text(
                S.current.accountDelete,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        )),
      ),
    );
  }

  Widget buildBullet(String text) {
    return Row(
      children: [
        const SizedBox(width: 45),
        const Icon(Icons.circle, size: 10, color: Colors.grey),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            softWrap: true,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
              fontFamily: 'Roboto',
            ),
          ),
        ),
      ],
    );
  }

  Future createModalBottomSheet() {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final TextEditingController displayNameController = TextEditingController();
    displayNameController.text = Client.instance().displayName!;

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
              top: 16.0,
              right: 16.0,
              left: 16.0,
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                S.current.enterYourName,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Flexible(
                      child: TextField(
                    decoration: InputDecoration(
                      hintText: S.current.enterYourName,
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: appColors.primaryColor), // Bottom line color
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: appColors.primaryColor,
                            width: 2), // Highlight color
                      ),
                    ),
                    autofocus: true,
                    controller: displayNameController,
                  )),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(S.current.cancel)),
                  TextButton(
                      onPressed: () {
                        String newDisplayName = displayNameController.text;
                        Client.instance()
                            .commands
                            ?.changeDisplayName(newDisplayName);
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        S.current.save,
                      ))
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}