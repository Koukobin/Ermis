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

import 'package:ermis_mobile/core/models/chat_session.dart';
import 'package:ermis_mobile/core/util/dialogs_utils.dart';
import 'package:ermis_mobile/core/widgets/profile_photos/interactive_user_avatar.dart';
import 'package:ermis_mobile/features/voice_call/web_rtc/voice_call_webrtc.dart';
import 'package:ermis_mobile/generated/l10n.dart';
import 'package:ermis_mobile/theme/app_colors.dart';
import 'package:flutter/material.dart';

import '../voice_call/web_rtc/call_info.dart';

class ChatUserAvatar extends InteractiveUserAvatar {
  final void Function(BuildContext, ChatSession) pushMessageInterface;

  ChatUserAvatar({
    super.key,
    required super.chatSession,
    required super.member,
    required this.pushMessageInterface,
  }) : super(onAvatarClicked: (BuildContext context, FutureVoidCallback popContext) {
          final appColors = Theme.of(context).extension<AppColors>()!;
          return [
            IconButton(
                onPressed: () async {
                  await popContext();
                  pushMessageInterface(context, chatSession);
                },
                icon: Icon(
                  Icons.chat_outlined,
                  color: appColors.primaryColor,
                )),
            IconButton(
                onPressed: () {
                  popContext();
                  pushVoiceCallWebRTC(
                    context,
                    CallInfo(
                      chatSessionID: chatSession.chatSessionID,
                      chatSessionIndex: chatSession.chatSessionIndex,
                      member: member,
                      isInitiator: true,
                    ),
                  );
                },
                icon: Icon(
                  Icons.phone_outlined,
                  color: appColors.primaryColor,
                )),
            IconButton(
                onPressed: () {
                  popContext();
                  pushVoiceCallWebRTC(
                    context,
                    CallInfo(
                      chatSessionID: chatSession.chatSessionID,
                      chatSessionIndex: chatSession.chatSessionIndex,
                      member: member,
                      isInitiator: true,
                    ),
                  );
                },
                icon: Icon(
                  Icons.video_call_outlined,
                  color: appColors.primaryColor,
                )),
            IconButton(
                onPressed: () {
                  popContext();
                  showSnackBarDialog(
                    context: context,
                    content: S.current.functionality_not_implemented,
                  );
                },
                icon: Icon(
                  Icons.info_outline,
                  color: appColors.primaryColor,
                )),
          ];
        });
}
