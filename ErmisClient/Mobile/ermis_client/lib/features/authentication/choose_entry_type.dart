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

import 'package:ermis_mobile/core/util/dialogs_utils.dart';
import 'package:ermis_mobile/features/authentication/login_interface.dart';
import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../core/util/url_launcher.dart';
import '../../theme/app_colors.dart';
import 'register_interface.dart';

class AuthLandingScreen extends StatelessWidget {
  const AuthLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isCompact = mq.size.height < 700;
    final appColors = Theme.of(context).extension<AppColors>()!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: appColors.secondaryColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            children: [
              SizedBox(height: isCompact ? 24 : 56),
              // App icon display
              Image.asset(
                AppConstants.externalAppIconPath,
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 20),
              Text(
                "Ermis",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Giving you the freedom to communicate,\n— on your own terms.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              _PrimaryPillButton(
                label: 'Create a free account',
                onPressed: () => {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginInterface()),
                    (route) => false, // Removes all previous routes
                  )
                },
              ),
              const SizedBox(height: 14),
              _SecondaryPillButton(
                label: 'Log in',
                onPressed: () => {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CreateAccountInterface()),
                    (route) => false, // Removes all previous routes
                  )
                },
              ),
              const SizedBox(height: 28),
              const _OrDivider(),
              const SizedBox(height: 20),
              _ContinueRow(
                withPhoneNumber: () => showSnackBarDialog(context: context, content: 'Continue with number'),
                withFingerprint: () => showSnackBarDialog(context: context, content: 'Continue with fingerprint'),
                withPrivateKey: () => showSnackBarDialog(context: context, content: 'Continue with private key'),
              ),
              const SizedBox(height: 28),
              _PrivacyFooter(),
              SizedBox(height: isCompact ? 16 : 28),
            ],
          ),
        ),
      ),
    );
  }

}

class _PrimaryPillButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _PrimaryPillButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.black,
          shape: const StadiumBorder(),
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

class _SecondaryPillButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _SecondaryPillButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(color: colorScheme.outlineVariant, width: 1.4),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(child: Divider(color: colorScheme.outlineVariant, height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or continue with',
            style: TextStyle(fontSize: 12.5, color: colorScheme.onSurfaceVariant),
          ),
        ),
        Expanded(child: Divider(color: colorScheme.outlineVariant, height: 1)),
      ],
    );
  }
}


// Placeholder options, none implemented yet
class _ContinueRow extends StatelessWidget {
  final VoidCallback withPhoneNumber;
  final VoidCallback withFingerprint;
  final VoidCallback withPrivateKey;

  const _ContinueRow({
    required this.withPhoneNumber,
    required this.withFingerprint,
    required this.withPrivateKey,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _IconOptionButton(icon: Icons.phone_iphone_rounded, onTap: withPhoneNumber),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _IconOptionButton(icon: Icons.fingerprint_outlined, onTap: withFingerprint),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _IconOptionButton(icon: Icons.key, onTap: withPrivateKey),
        ),
      ],
    );
  }
}

class _IconOptionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconOptionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: AppColors0.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colorScheme.outline, width: 1),
          ),
          child: Icon(icon, size: 26),
        ),
      ),
    );
  }
}

class _PrivacyFooter extends StatelessWidget {
  const _PrivacyFooter();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.copyright_outlined, size: 16, color: Colors.deepPurpleAccent),
            const SizedBox(width: 3),
            Text(
              '2021-2026 Ilias Koukovinis',
              style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'By continuing, you agree to the',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.5, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8)),
            ),
            ElevatedButton(
              onPressed: () {
                UrlLauncher.launchURL(context, AppConstants.privacyPolicyURL);
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.transparent),
                elevation: WidgetStateProperty.all(0.0),
                splashFactory: NoSplash.splashFactory,
                overlayColor: WidgetStateProperty.all(Colors.transparent),
              ),
              child: Text(
                "Ermis Privacy Policy.",
                style: const TextStyle(
                  fontSize: 11.5,
                  decoration: TextDecoration.underline,
                  decorationStyle: TextDecorationStyle.wavy,
                  decorationThickness: 2,
                  color: Colors.blueAccent,
                  decorationColor: Colors.blueAccent
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
