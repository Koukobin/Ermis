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

import 'dart:typed_data';

import 'package:ermis_mobile/theme/app_colors.dart';
import 'package:flutter/material.dart';

import '../../../constants/app_constants.dart';

class UserProfilePhoto extends StatefulWidget {
  final double? radius;
  final Uint8List? profileBytes;
  final bool removeBorder;

  const UserProfilePhoto({
    super.key,
    this.radius,
    this.removeBorder = false,
    required this.profileBytes,
  });

  @override
  State<UserProfilePhoto> createState() => UserProfilePhotoState();
}

class UserProfilePhotoState extends State<UserProfilePhoto> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    BoxDecoration? boxDecoration = widget.removeBorder
        ? null
        : BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: appColors.primaryColor,
              width: 3.0,
            ),
          );

    bool isProfileVacant = widget.profileBytes?.isEmpty ?? true;

    return Container(
      decoration: boxDecoration,
      child: CircleAvatar(
        radius: widget.radius,
        backgroundColor: Colors.grey[200],
        backgroundImage: !isProfileVacant ? MemoryImage(widget.profileBytes!) : null,
        child: isProfileVacant
            ?
            // Icon(
            //     Icons.person_rounded,
            //     color: Colors.grey,
            //     size: widget.radius == null ? 40 : widget.radius! * 1.3,
            //   )
            Image.asset(AppConstants.emptyUserProfileIconPath)
            : null,
      ),
    );
  }
}
