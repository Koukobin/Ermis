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

import 'package:camera/camera.dart';
import 'package:ermis_client/core/event_bus/app_event_bus.dart';
import 'package:ermis_client/core/models/message_events.dart';
import 'package:ermis_client/mixins/event_bus_subscription_mixin.dart';
import 'package:ermis_client/generated/l10n.dart';
import 'package:ermis_client/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/data_sources/api_client.dart';
import '../../../core/util/dialogs_utils.dart';
import '../../../core/util/top_app_bar_utils.dart';
import '../../../core/util/file_utils.dart';
import '../../../core/widgets/user_profile.dart';

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({super.key});

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> with SingleTickerProviderStateMixin, EventBusSubscriptionMixin {
  int _clientID = Client.instance().clientID;
  String _displayName = Client.instance().displayName ?? "";

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    subscribe(AppEventBus.instance.on<ClientIdEvent>(), (event) async {
      if (!mounted) return;
      setState(() {
        _clientID = event.clientId;
      });
    });

    subscribe(AppEventBus.instance.on<UsernameReceivedEvent>(), (event) async {
      if (!mounted) return;
      setState(() {
        _displayName = event.displayName;
      });
    });

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Tween for scaling
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    // Start the animation
    Future.delayed(const Duration(milliseconds: 500), _controller.forward);
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return;
        }

        _controller.reverse().whenComplete(() {
          _controller.dispose();
          Navigator.pop(context);
        });
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: appColors.secondaryColor,
        appBar: ErmisAppBar(titleText: S.current.profile_settings),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Image Section
              Center(
                child: GestureDetector(
                  onTap: onChangeProfileImage,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      const PersonalProfilePhoto(radius: 80),
                      ScaleTransition(
                        scale: _animation,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.green, // Online or offline color
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.camera_alt_outlined,
                            color: appColors.secondaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.person_outline_rounded),
                trailing: Icon(
                  Icons.edit_outlined,
                  color: appColors.primaryColor,
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.current.name,
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                    Text(_displayName),
                  ],
                ),
                onTap: () {
                  showChangeDisplayNameModalBottomSheet();
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                trailing: Icon(
                  Icons.edit_outlined,
                  color: appColors.primaryColor,
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.current.profile_about,
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                    Text(S.current.profile_hey_there),
                  ],
                ),
                onTap: () {
                  showSnackBarDialog(
                      context: context,
                      content: S.current.functionality_not_implemented);
                },
              ),
              ListTile(
                leading: const Icon(Icons.numbers_outlined),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ID",
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                    Text(_clientID.toString()),
                  ],
                ),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: _clientID.toString()));
                  showSnackBarDialog(
                      context: context, content: S.current.profile_id_copied);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onChangeProfileImage() {
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
                  _buildPopupOption(
                    context,
                    icon: Icons.image_outlined,
                    label: S.current.profile_gallery,
                    onTap: () async {
                      Navigator.pop(context);
                      attachSingleFile(context, (String fileName, Uint8List fileBytes) {
                        Client.instance().commands.setAccountIcon(fileBytes);
                      });
                    },
                  ),
                  SizedBox(
                    width: 90,
                  ),
                  _buildPopupOption(
                    context,
                    icon: Icons.camera_alt_outlined,
                    label: S.current.profile_camera,
                    onTap: () async {
                      Navigator.pop(context);
                      XFile? file = await MyCamera.capturePhoto();

                      if (file == null) {
                        return;
                      }

                      Uint8List fileBytes = await file.readAsBytes();
                      Client.instance().commands.setAccountIcon(fileBytes);
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

  Widget _buildPopupOption(
    BuildContext context, {
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
                color: appColors.inferiorColor.withOpacity(0.4),
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

  Future showChangeDisplayNameModalBottomSheet() {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final TextEditingController displayNameController = TextEditingController();
    displayNameController.text = Client.instance().displayName!;

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
              top: 16.0,
              right: 16.0,
              left: 16.0,
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                S.current.name_enter,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Flexible(
                      child: TextField(
                    decoration: InputDecoration(
                      hintText: S.current.name_enter,
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: appColors.primaryColor), // Bottom line color
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: appColors.primaryColor,
                            width: 2), // Highlight color
                      ),
                    ),
                    autofocus: true,
                    controller: displayNameController,
                  )),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(S.current.cancel)),
                  TextButton(
                      onPressed: () {
                        String newDisplayName = displayNameController.text;
                        Client.instance()
                            .commands
                            .changeDisplayName(newDisplayName);
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        S.current.save,
                      ))
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
