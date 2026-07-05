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

import 'package:ermis_mobile/core/models/member_icon.dart';
import 'package:ermis_mobile/core/networking/common/message_types/client_status.dart';
import 'package:ermis_mobile/core/services/profile_icon_loader.dart';
import 'package:ermis_mobile/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../loading_state.dart';

class UserAvatar extends StatefulWidget {
  final MemberIcon memberIcon;
  final ClientStatus status;

  const UserAvatar({
    super.key,
    required this.memberIcon,
    required this.status,
  });

  UserAvatar.empty({super.key})
      : memberIcon = MemberIcon.emptY(),
        status = ClientStatus.offline;

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends LoadingState<UserAvatar> {
  Uint8List imageBytes = Uint8List(0);

  @override
  void initState() {
    super.initState();
    IconLoaderUtil.loadIcon$0(widget.memberIcon).then((bytes) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        imageBytes = bytes;
      });
    });
  }

  @override
  Widget build0(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Stack(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey[200],
          backgroundImage: imageBytes.isEmpty ? null : MemoryImage(imageBytes),
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
              color: switch (widget.status) {
                ClientStatus.online => Colors.green,
                ClientStatus.offline => Colors.red,
                ClientStatus.doNotDisturb => Colors.amber,
                ClientStatus.invisible => Colors.blueGrey,
              },
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

  @override
  Widget buildLoadingScreen() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade400,
      highlightColor: Colors.grey.shade100,
      child: const CircleAvatar(radius: 25 /* MUST MATCH AVATAR RADIUS OF MAIN BUILD */),
    );
  }
}