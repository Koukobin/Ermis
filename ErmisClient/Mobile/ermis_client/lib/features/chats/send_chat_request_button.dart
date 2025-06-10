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

import 'package:ermis_client/core/data_sources/api_client.dart';
import 'package:ermis_client/core/util/dialogs_utils.dart';
import 'package:ermis_client/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class SendChatRequestButton extends StatefulWidget {
  const SendChatRequestButton({super.key});

  @override
  State<SendChatRequestButton> createState() => _SendChatRequestButtonState();

  static void showAddChatRequestDialog(BuildContext context) async {
    final String input = await showInputDialog(
      context: context,
      keyboardType: TextInputType.number,
      title: S.current.send_chat_request,
      hintText: S.current.client_id_must_be_a_number,
    );

    if (input.trim().isEmpty) return;
    if (int.tryParse(input) == null) {
      showSnackBarDialog(
        context: context,
        content: S.current.client_id_must_be_a_number,
      );
      return;
    }

    final int clientID = int.parse(input);
    Client.instance().commands?.sendChatRequest(clientID);
  }
}

class _SendChatRequestButtonState extends State<SendChatRequestButton> {
  // NOTE: changing opacity to 0.0 will result in button
  // not displaying if Chats page is refreshed
  double _widgetOpacity = 1.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('send-chat-request-button'),
      onVisibilityChanged: (VisibilityInfo info) {
        if (!mounted) return;
        if (info.visibleFraction > 0) {
          setState(() {
            _widgetOpacity = 1.0;
          });
          return;
        }

        setState(() {
          _widgetOpacity = 0.0;
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _widgetOpacity,
          child: FloatingActionButton(
            onPressed: () =>
                SendChatRequestButton.showAddChatRequestDialog(context),
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
