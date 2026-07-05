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

import 'package:ermis_mobile/core/models/member_icon.dart';
import 'package:ermis_mobile/core/widgets/loading_state.dart';
import 'package:ermis_mobile/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../constants/app_constants.dart';
import '../../services/profile_icon_loader.dart';

class UserProfilePhoto extends StatefulWidget {
  final double? radius;
  final MemberIcon? icon;
  final bool removeBorder;

  const UserProfilePhoto({
    super.key,
    this.radius,
    this.removeBorder = false,
    required this.icon,
  });

  @override
  State<UserProfilePhoto> createState() => UserProfilePhotoState();
}

class UserProfilePhotoState extends LoadingState<UserProfilePhoto> {
  Uint8List? profileBytes;

  @override
  void initState() {
    super.initState();
    if (widget.icon != null) {
      IconLoaderUtil. loadIcon$0(widget.icon!).then((bytes) {
        if (!mounted) return;
        setState(() {
          isLoading = false;
          profileBytes = bytes;
        });
      });
    }
  }

  @override
  Widget build0(BuildContext context) {
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

    bool isProfileVacant = profileBytes?.isEmpty ?? true;

    return Container(
      decoration: boxDecoration,
      child: CircleAvatar(
        radius: widget.radius,
        backgroundColor: Colors.grey[200],
        backgroundImage: !isProfileVacant ? MemoryImage(profileBytes!) : null,
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

  @override
  Widget buildLoadingScreen() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade400,
      highlightColor: Colors.grey.shade100,
      child: const CircleAvatar(radius: 25 /* MUST MATCH AVATAR RADIUS OF MAIN BUILD */),
    );
  }
}
