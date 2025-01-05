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

import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class UserAvatar extends StatelessWidget {
  final Uint8List imageBytes;
  final bool isOnline;

  const UserAvatar({
    super.key,
    required this.imageBytes,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Stack(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: imageBytes.isEmpty ? null : MemoryImage(imageBytes),
          backgroundColor: Colors.grey[200],
          child: imageBytes.isEmpty
              ? Icon(
                  Icons.person,
                  color: Colors.grey,
                )
              : null,
        ),
        // Online/Offline Indicator
        Positioned(
          bottom: 0,
          left: 30,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: isOnline
                  ? Colors.green
                  : Colors.red, // Online or offline color
              shape: BoxShape.circle,
              border: Border.all(
                color: appColors
                    .secondaryColor, // Border to separate the indicator from the avatar
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}