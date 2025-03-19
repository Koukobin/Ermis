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

import 'package:ermis_client/theme/app_colors.dart';
import 'package:flutter/material.dart';

import '../main_ui/chats/user_avatar.dart';

SizedBox createSimpleButton(BuildContext context, String text, IconData iconData, GestureTapCallback onTap) {
  final appColors = Theme.of(context).extension<AppColors>()!;
  return SizedBox.fromSize(
    size: const Size(0 /* Width set by list view */, 60),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: ClipRect(
        child: Material(
          color: appColors.secondaryColor,
          child: InkWell(
            splashColor: appColors.primaryColor,
            onTap: onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Icon(iconData, color: appColors.inferiorColor),
                SizedBox(width: 5),
                Text(text,
                    style: TextStyle(
                        color: appColors.primaryColor, // Change the color here
                        fontSize: 16.0)),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Container createOutlinedButton({
  required BuildContext context,
  required Text text,
  required UserAvatar avatar,
  List<Widget>? otherWidgets,
  required GestureTapCallback onTap,
}) {
  final appColors = Theme.of(context).extension<AppColors>()!;
  return Container(
    height: 60,
    decoration: BoxDecoration(
      border: Border.all(color: appColors.primaryColor, width: 1),
      borderRadius: BorderRadius.circular(10),
    ),
    child: InkWell(
      splashColor: appColors.primaryColor,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            avatar,
            const SizedBox(width: 5),
              text,
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (otherWidgets != null)
                    for (final item in otherWidgets) item
                ],
              ),
            )
          ],
        ),
      ),
    ),
  );
}


Widget createReallyNiceButton(BuildContext context, String label, IconData icon, VoidCallback onPressed) {
  final appColors = Theme.of(context).extension<AppColors>()!;
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    child: ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: appColors.primaryColor,
        foregroundColor: appColors.secondaryColor,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      icon: Icon(icon),
      label: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
  );
}