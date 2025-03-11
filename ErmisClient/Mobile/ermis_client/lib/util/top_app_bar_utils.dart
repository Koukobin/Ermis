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
  final Widget? leading;
  final List<Widget> actions;
  final Widget title;
  final Color? color;
  final bool? centerTitle;
  final bool removeDivider;

  factory ErmisAppBar({
    Key? key,
    String? titleText,
    Widget? title,
    List<Widget> actions = const [],
    Color? color,
    bool? centerTitle,
    Widget? leading,
    bool removeDivider = false,
  }) {
    assert((title == null || titleText == null));

    title ??= Text(
          titleText ?? AppConstants.applicationTitle,
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w500,
            fontSize: 20,
            letterSpacing: 1.2,
          ),
        );

    return ErmisAppBar._(
      key: key,
      titleText: titleText,
      title: title,
      actions: actions,
      color: color,
      removeDivider: removeDivider,
      leading: leading,
      centerTitle: centerTitle,
    );
  }

  const ErmisAppBar._({
    super.key,
    String? titleText,
    required this.title,
    this.actions = const [],
    this.color,
    this.removeDivider = false,
    this.leading,
    this.centerTitle,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return AppBar(
      leading: leading,
      backgroundColor: color ?? appColors.secondaryColor,
      foregroundColor: appColors.primaryColor,
      title: title,
      actions: actions,
      centerTitle: centerTitle ?? actions.isEmpty ? true : false,  // Could be simplified but I find this much more intuitive
      elevation: 0, // Removes AppBar shadow for a flat, modern appearance
      bottom: removeDivider ? null : DividerBottom(dividerColor: appColors.primaryColor),
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
      thickness: 0.5,
      height: 0, // Ensures no additional spacing below the divider
    );
  }
}

class GoBackBar extends StatelessWidget implements PreferredSizeWidget {
  final String title; // Allows customizable titles with "Go Back" defaults

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
        onPressed: () => {
          Navigator.pop(context) // Navigate back to the previous screen
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

class AnimatedAppBar extends StatefulWidget implements PreferredSizeWidget {
  final AppBar appBar;

  const AnimatedAppBar({super.key, required this.appBar});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<AnimatedAppBar> createState() => _AnimatedAppBarState();
}

class _AnimatedAppBarState extends State<AnimatedAppBar> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(milliseconds: 100), toggleOpacity);
  }

  void toggleOpacity() {
    setState(() {
      _opacity = _opacity == 1.0 ? 0.0 : 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: _opacity,
      child: widget.appBar,
    );
  }
}
