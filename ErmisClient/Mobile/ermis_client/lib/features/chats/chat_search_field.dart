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

import '../../generated/l10n.dart';
import '../../theme/app_colors.dart';

class ChatSearchField extends StatefulWidget {
  final TextEditingController searchController;
  final FocusNode focusNode;
  const ChatSearchField({
    super.key,
    required this.searchController,
    required this.focusNode,
  });

  @override
  State<ChatSearchField> createState() => _ChatSearchFieldState();
}

class _ChatSearchFieldState extends State<ChatSearchField> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 15), () {
      if (mounted) {
        setState(() => _opacity = 1.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    widget.focusNode.requestFocus();

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: _opacity, // Fully visible when searching
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: appColors.secondaryColor.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: appColors.secondaryColor, width: 1.5),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            inputDecorationTheme: InputDecorationTheme(
              hintStyle: const TextStyle(color: Colors.grey),
              labelStyle: const TextStyle(color: Colors.white),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.2),
              contentPadding: const EdgeInsets.symmetric(vertical: 5),
            ),
          ),
          child: TextField(
              focusNode: widget.focusNode,
              controller: widget.searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() => _opacity = 0.0);
                      Future.delayed(Duration(milliseconds: 175), () {
                        widget.focusNode.unfocus();
                        widget.searchController.clear();
                      });
                    },
                    child: const Icon(Icons.clear)),
                hintText: S.current.search,
                fillColor: appColors.tertiaryColor,
                filled: true,
              )),
        ),
      ),
    );
  }
}
