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

import 'package:ermis_client/core/networking/user_info_manager.dart';
import 'package:ermis_client/core/widgets/loading_state.dart';
import 'package:ermis_client/generated/l10n.dart';
import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../event_bus/app_event_bus.dart';
import '../../models/message_events.dart';
import '../../util/dialogs_utils.dart';

class PersonalProfilePhoto extends StatefulWidget {
  final double? radius;

  const PersonalProfilePhoto({this.radius, super.key});

  @override
  LoadingState<PersonalProfilePhoto> createState() => PersonalProfilePhotoState();
}

class PersonalProfilePhotoState extends LoadingState<PersonalProfilePhoto> {
  Uint8List? _profileBytes = UserInfoManager.profilePhoto;

  @override
  void initState() {
    super.initState();

    // Determine initial loading state based on availability of profile photo
    isLoading = _profileBytes == null;

    AppEventBus.instance.on<ProfilePhotoReceivedEvent>().listen((event) async {
      if (!mounted) return;
      setState(() {
        _profileBytes = event.photoBytes;
        isLoading = false;
      });
    });
    
    AppEventBus.instance.on<AddProfilePhotoResultEvent>().listen((event) async {
      if (!mounted) return;
      if (event.success) {
        setState(() {
          _profileBytes = UserInfoManager.profilePhoto;
          isLoading = false;
        });
        return;
      }

      showSnackBarDialog(
          context: context,
          content: S.current.an_error_occured_while_trying_to_change_profile_photo);
    });

  }

  @override
  Widget build0(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Hero(
      tag: "self-user-profile",
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: appColors.primaryColor,
            width: 3.0,
          ),
        ),
        child: CircleAvatar(
          radius: widget.radius,
          backgroundColor: Colors.grey[200],
          backgroundImage: _profileBytes?.isEmpty ?? true ? null : MemoryImage(_profileBytes!),
          child: _profileBytes?.isEmpty ?? true
              ? Icon(
                  Icons.person_rounded,
                  color: Colors.grey,
                  size:  widget.radius == null ? 40 : widget.radius! * 2,
                )
              : null,
        ),
      ),
    );
  }

  @override
  Widget buildLoadingScreen() {
    return const Center(child: CircularProgressIndicator());
  }

}