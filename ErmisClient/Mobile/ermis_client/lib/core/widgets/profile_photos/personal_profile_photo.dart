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

import 'package:camera/camera.dart';
import 'package:ermis_mobile/constants/app_constants.dart';
import 'package:ermis_mobile/core/networking/user_info_manager.dart';
import 'package:ermis_mobile/core/widgets/loading_state.dart';
import 'package:ermis_mobile/generated/l10n.dart';
import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../data_sources/api_client.dart';
import '../../event_bus/app_event_bus.dart';
import '../../models/message_events.dart';
import '../../util/dialogs_utils.dart';
import '../../util/file_utils.dart';
import 'avatar_glow.dart';

class _ProfilePhotoUpdatingEvent {}

class PersonalProfilePhoto extends StatefulWidget {
  final double? radius;

  const PersonalProfilePhoto({this.radius, super.key});

  static void changeProfileImage(BuildContext context) {
    Widget buildPopupOption({
      required IconData icon,
      required String label,
      required VoidCallback onTap,
    }) {
      final appColors = Theme.of(context).extension<AppColors>()!;
      return GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: appColors.inferiorColor.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: CircleAvatar(
                radius: 27,
                backgroundColor: appColors.tertiaryColor,
                child: Icon(icon, size: 28, color: appColors.primaryColor),
              ),
            ),
            SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 14)),
          ],
        ),
      );
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                S.current.profile_photo,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildPopupOption(
                    icon: Icons.image_outlined,
                    label: S.current.profile_gallery,
                    onTap: () async {
                      Navigator.pop(context);
                      attachSingleFile(context, (String fileName, Uint8List fileBytes) {
                        Client.instance().commands?.setAccountIcon(fileBytes);

                        AppEventBus.instance.fire(_ProfilePhotoUpdatingEvent());
                      });
                    },
                  ),
                  SizedBox(
                    width: 90,
                  ),
                  buildPopupOption(
                    icon: Icons.camera_alt_outlined,
                    label: S.current.profile_camera,
                    onTap: () async {
                      Navigator.pop(context);
                      XFile? file = await MyCamera.capturePhoto();

                      if (file == null) {
                        return;
                      }

                      Uint8List fileBytes = await file.readAsBytes();
                      Client.instance().commands?.setAccountIcon(fileBytes);

                      AppEventBus.instance.fire(_ProfilePhotoUpdatingEvent());
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

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

    AppEventBus.instance.on<_ProfilePhotoUpdatingEvent>().listen((event) {
      if (!mounted) return;
      setState(() => isLoading = true);
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

      setState(() => isLoading = false);
      showSnackBarDialog(
          context: context,
          content: S.current.an_error_occured_while_trying_to_change_profile_photo);
    });

  }

  @override
  Widget build0(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final bool isProfileEmpty = _profileBytes?.isEmpty ?? true;

    Widget avatar = CircleAvatar(
      radius: widget.radius,
      backgroundColor: Colors.grey[200],
      backgroundImage: isProfileEmpty ? null : MemoryImage(_profileBytes!),
      child: isProfileEmpty
          ?
          // Icon(
          //     Icons.person_rounded,
          //     color: Colors.grey,
          //     size:  widget.radius == null ? 40 : widget.radius! * 2,
          //   )
          Image.asset(AppConstants.emptyUserProfileIconPath)
          : null,
    );

    if (isProfileEmpty) {
      avatar = AvatarGlow(
        repeat: true,
        glowRadiusFactor: 0.5,
        glowColor: appColors.primaryColor,
        repeatDelay: const Duration(milliseconds: 500),
        startDelay: const Duration(seconds: 1),
        child: avatar,
      );
    }

    return Hero(
      tag: "personal-user-profile",
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: appColors.primaryColor,
            width: 3.0,
          ),
        ),
        child: avatar,
      ),
    );
  }

  @override
  Widget buildLoadingScreen() {
    return const CircularProgressIndicator(
      constraints: BoxConstraints(minWidth: 50, minHeight: 50),
    );
  }
}
