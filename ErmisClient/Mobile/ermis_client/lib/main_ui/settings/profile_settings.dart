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
import 'package:ermis_client/client/app_event_bus.dart';
import 'package:ermis_client/client/message_events.dart';
import 'package:ermis_client/util/transitions_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_theme.dart';
import '../../client/client.dart';
import '../../util/dialogs_utils.dart';
import '../../util/top_app_bar_utils.dart';
import '../../util/file_utils.dart';
import '../user_profile.dart';
import 'settings_interface.dart';

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({super.key});

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> with SingleTickerProviderStateMixin {

  int _clientID = Client.getInstance().clientID;
  String _displayName = Client.getInstance().displayName ?? "";

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    AppEventBus.instance.on<ClientIdEvent>().listen((event) async {
      if (!mounted) return;
      setState(() {
        _clientID = event.clientId;
      });
    });
    
    AppEventBus.instance.on<UsernameReceivedEvent>().listen((event) async {
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
    Future.delayed(Duration(milliseconds: 25), _controller.forward);
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: appColors.secondaryColor,
      appBar: const ErmisAppBar(
          title: Text(
        "Profile Settings",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      )),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Image Section
            GestureDetector(
              onTap: onChangeProfileImage,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const PersonalProfilePhoto(radius: 80),
                  Positioned(
                    right: 105,
                    bottom: 15,
                    child: ScaleTransition(
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
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.person_outline_rounded),
              trailing: Icon(
                Icons.edit_outlined,
                color: appColors.primaryColor,
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Name',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  Text(_displayName),
                ],
              ),
              onTap: () {
                createModalBottomSheet();
              },
            ),
            ListTile(
              leading: Icon(Icons.info_outline),
              trailing: Icon(
                Icons.edit_outlined,
                color: appColors.primaryColor,
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [ 
                  Text(
                    'About',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  Text("Hey there!"),
                ],
              ),
              onTap: () {
                showSnackBarDialog(context: context, content: "Functionality not implemented yet!");
              },
            ),
            ListTile(
              leading: Icon(Icons.numbers_outlined),
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
                showSnackBarDialog(context: context, content: "Message copied to clipboard");
              },
            ),
          ],
        ),
      ),
    );
  }

  void onChangeProfileImage() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Profile Photo",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPopupOption(
                    context,
                    icon: Icons.image_outlined,
                    label: "Gallery",
                    onTap: () async {
                      Navigator.pop(context);
                      attachSingleFile(context,
                          (String fileName, Uint8List fileBytes) {
                        Client.getInstance().commands.setAccountIcon(fileBytes);
                      });
                    },
                  ),
                  SizedBox(
                    width: 90,
                  ),
                  _buildPopupOption(
                    context,
                    icon: Icons.camera_alt_outlined,
                    label: "Camera",
                    onTap: () async {
                      Navigator.pop(context);
                      XFile? file = await MyCamera.capturePhoto();

                      if (file == null) {
                        return;
                      }

                      Uint8List fileBytes = await file.readAsBytes();
                      Client.getInstance().commands.setAccountIcon(fileBytes);
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
          Text(label, style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Future createModalBottomSheet() {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final TextEditingController displayNameController = TextEditingController();
    displayNameController.text = Client.getInstance().displayName!;
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
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
                "Enter your name",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Flexible(
                      child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Enter your name',
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
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text("Cancel")),
                  TextButton(
                      onPressed: () {
                        String newDisplayName = displayNameController.text;
                        Client.getInstance().commands.changeDisplayName(newDisplayName);
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "Save",
                        style: TextStyle(),
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