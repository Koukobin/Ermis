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
import 'package:ermis_mobile/theme/app_colors.dart';
import 'package:flutter/material.dart';

import '../../../constants/app_constants.dart';
import '../../services/custom_http_service.dart';

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

class UserProfilePhotoState extends State<UserProfilePhoto> {
  Uint8List? profileBytes;

  @override
  void initState() {
    super.initState();
    _loadIcon();
  }

  Future<void> _loadIcon() async {
    if (widget.icon == null) return;
    if (widget.icon?.isLoaded() ?? false) {
      setState(() {
        profileBytes = widget.icon?.profilePhoto;
      });
      return;
    }
    String iconUrl = widget.icon?.getUrl() ?? "";
    profileBytes = await CustomHttpClient().fetchUint8ListFromUrl(iconUrl) ?? Uint8List(0);

    widget.icon?.profilePhoto = profileBytes!;
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
}
