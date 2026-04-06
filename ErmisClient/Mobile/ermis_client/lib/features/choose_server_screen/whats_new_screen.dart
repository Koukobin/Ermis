/* Copyright (C) 2025 Ilias Koukovinis <ilias.koukovinis@gmail.com>
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

import 'package:ermis_mobile/constants/app_constants.dart';
import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../../theme/app_colors.dart';

class WhatsNewScreen extends StatelessWidget {
  const WhatsNewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.whatsNewTitle),
        backgroundColor: appColors.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${S.current.whatsNewTitle} v${AppConstants.applicationVersion}",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: appColors.primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            // Feature List
            ListTile(
              leading: Icon(Icons.add, color: appColors.primaryColor),
              title: Text(S.current.enhancedEncryption),
            ),
            ListTile(
              leading: Icon(Icons.lightbulb_outline, color: appColors.primaryColor),
              title: Text(S.current.abilityToFormGroupChats),
            ),
            ListTile(
              leading: Icon(Icons.build, color: appColors.primaryColor),
              title: Text(S.current.manyBugFixes),
            ),
            ListTile(
              leading: Icon(Icons.speed, color: appColors.primaryColor),
              title: Text(S.current.optimizationsOnDataUsage),
            ),
            ListTile(
              leading: Icon(Icons.call,  color: appColors.primaryColor),
              title: Text(S.current.voiceCallsFeature),
            ),
            const SizedBox(height: 30),
            // Dismiss Button
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: appColors.primaryColor,
                ),
                onPressed: Navigator.of(context).pop,
                child: Text(
                  S.current.gotIt,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
