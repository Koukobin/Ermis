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

import 'package:ermis_client/client/app_event_bus.dart';
import 'package:ermis_client/client/message_events.dart';
import 'package:ermis_client/main_ui/loading_state.dart';
import 'package:ermis_client/theme/app_colors.dart';
import 'package:ermis_client/util/dialogs_utils.dart';
import 'package:flutter/material.dart';

import '../client/client.dart';

class UserProfilePhoto extends StatefulWidget {
  final double? radius;
  final Uint8List profileBytes;

  const UserProfilePhoto({this.radius, required this.profileBytes, super.key});

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
    return Container(
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
        backgroundImage: widget.profileBytes.isNotEmpty ? MemoryImage(widget.profileBytes) : null,
        child: widget.profileBytes.isEmpty
            ? Icon(
                Icons.person_rounded,
                color: Colors.grey,
                size: widget.radius == null ? 40 : widget.radius! * 2,
              )
            : null,
      ),
    );
  }

}

class PersonalProfilePhoto extends StatefulWidget {
  final double? radius;

  const PersonalProfilePhoto({this.radius, super.key});

  @override
  LoadingState<PersonalProfilePhoto> createState() => PersonalProfilePhotoState();
}

class PersonalProfilePhotoState extends LoadingState<PersonalProfilePhoto> {
  Uint8List? _profileBytes = Client.instance().profilePhoto;

  @override
  void initState() {
    super.initState();

    // Determine initial loading state based on availability of profile photo
    isLoading = _profileBytes == null;

    AppEventBus.instance.on<ProfilePhotoEvent>().listen((event) async {
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
          _profileBytes = Client.instance().profilePhoto;
          isLoading = false;
        });
        return;
      }
      showSnackBarDialog(
          context: context,
          content: "An error occured while trying to change profile photo");
    });

  }

  @override
  Widget build0(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Hero(
      tag: "titty-fuck",
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
    return Center(child: CircularProgressIndicator());
  }

}