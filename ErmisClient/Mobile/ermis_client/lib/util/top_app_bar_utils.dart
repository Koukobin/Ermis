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

import '../constants/app_constants.dart';
import '../theme/app_theme.dart';

class ErmisAppBar extends StatelessWidget implements PreferredSizeWidget {

  final List<Widget> actions;
  final Widget title;

  const ErmisAppBar(
      {this.title = const Text(
        applicationTitle,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      this.actions = const [],
      super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return AppBar(
      backgroundColor: appColors.secondaryColor,
      foregroundColor: appColors.primaryColor,
      title: title,
      actions: actions,
      centerTitle: // Could be simplified but I find this much more intuitive
          actions.isEmpty ? true : false,
      elevation: 0, // Removes AppBar shadow for a flat, modern appearance
      bottom: DividerBottom(dividerColor: appColors.primaryColor),
    );
  }
}

class DividerBottom extends StatelessWidget implements PreferredSizeWidget {

  final Color dividerColor;

  const DividerBottom({required this.dividerColor, super.key});

  @override
  Size get preferredSize => const Size.fromHeight(1);

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: dividerColor,
      thickness: 1,
      height: 0, // Ensures no additional spacing below the divider
    );
  }
}

class GoBackBar extends StatelessWidget implements PreferredSizeWidget {
  final String title; // Allows customizable titles with "Go Back" default

  const GoBackBar({super.key, this.title = "Go Back"});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return AppBar(
      backgroundColor: appColors.secondaryColor,
      foregroundColor: appColors.primaryColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context); // Navigate back to the previous screen
        },
      ),
      centerTitle: true, // Like before, we center the title for a clean look
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      elevation: 0, // Removes AppBar shadow for a modern flat design (like before)
      bottom: DividerBottom(dividerColor: appColors.primaryColor),
    );
  }
}
