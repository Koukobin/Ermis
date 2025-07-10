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

import 'package:ermis_mobile/core/data_sources/api_client.dart';
import 'package:ermis_mobile/core/models/member.dart';
import 'package:ermis_mobile/core/util/transitions_util.dart';
import 'package:ermis_mobile/features/call_history_screen/call_history_screen.dart';
import 'package:ermis_mobile/features/chats/send_chat_request_button.dart';
import 'package:ermis_mobile/features/messaging/presentation/choose_friends_screen.dart';
import 'package:ermis_mobile/features/settings/options/linked_devices_settings.dart';
import 'package:ermis_mobile/features/settings/primary_settings_interface.dart';
import 'package:ermis_mobile/features/splash_screen/splash_screen.dart';
import 'package:ermis_mobile/generated/l10n.dart';
import 'package:flutter/material.dart';

class ChatPopupMenuButton extends StatelessWidget {
  const ChatPopupMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<VoidCallback>(
      position: PopupMenuPosition.under,
      menuPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      onSelected: (VoidCallback callback) {
        callback();
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem(
          value: () async {
            List<Member> members = await showChooseFriendsScreen(context);

            if (members.isEmpty) return;
            List<int> memberIds =
                members.map((member) => member.clientID).toList();
            Client.instance().commands?.createGroup(memberIds);
          },
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Text(
            S.current.new_group,
            style: const TextStyle(
                color: Colors.green, fontStyle: FontStyle.italic, fontSize: 15),
          ),
        ),
        PopupMenuItem(
          value: () {
            // FUCK
            SendChatRequestButton.showAddChatRequestDialog(context);
          },
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Text(
            S.current.new_chat,
            style: const TextStyle(
                color: Colors.green, fontStyle: FontStyle.italic, fontSize: 15),
          ),
        ),
        PopupMenuItem(
          value: () {
            pushSlideTransition(context, const LinkedDevicesScreen());
          },
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Text(S.current.linked_devices,
              style: const TextStyle(
                  color: Colors.green,
                  fontStyle: FontStyle.italic,
                  fontSize: 15)),
        ),
        PopupMenuItem(
          value: () {
            pushSlideTransition(context, const CallHistoryPage());
          },
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Text(S().voice_calls_history,
              style: const TextStyle(
                  color: Colors.green,
                  fontStyle: FontStyle.italic,
                  fontSize: 15)),
        ),
        PopupMenuItem(
          value: () {
            pushSlideTransition(context, const SettingsScreen());
          },
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Text(
            S.current.settings,
            style: const TextStyle(
                color: Colors.green, fontStyle: FontStyle.italic, fontSize: 15),
          ),
        ),
        PopupMenuItem(
          value: () {
            Client.instance().disconnect();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const SplashScreen(),
              ),
              (route) => false, // Removes all previous routes
            );
          },
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Text(
            S.current.sign_out,
            style: const TextStyle(
                color: Colors.green, fontStyle: FontStyle.italic, fontSize: 15),
          ),
        ),
      ],
    );
  }
}
