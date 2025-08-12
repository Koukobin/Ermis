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


import 'package:ermis_mobile/core/models/voice_call_history.dart';
import 'package:ermis_mobile/features/messaging/presentation/message_bubble.dart';
import 'package:ermis_mobile/generated/l10n.dart';
import 'package:flutter/material.dart';

import '../../../core/data_sources/api_client.dart';
import '../../../core/networking/common/message_types/voice_call_history_status.dart';
import '../../../core/util/custom_date_formatter.dart';
import '../../../core/util/datetime_utils.dart';
import '../../../core/util/transitions_util.dart';
import '../../../theme/app_colors.dart';
import '../../call_history_screen/call_history_screen.dart';

class VoiceCallBubble extends MessageBubble {
  final VoiceCallHistory entry;
  final VoidCallback pushVoiceCall;
  final int? previousMessageEpochSecond;
  final int? previousMessageClientID;

  const VoiceCallBubble({
    super.key,
    required this.entry,
    required this.pushVoiceCall,
    required this.previousMessageEpochSecond,
    required this.previousMessageClientID,
    required super.chatSession,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    final bool isMessageOwner = entry.initiatorClientID == Client.instance().clientID;

    const int millisPerSecond = 1000;
    final DateTime currentMessageDate = DateTime.fromMillisecondsSinceEpoch(
            entry.tsDebuted * millisPerSecond /* Convert seconds to millis */,
            isUtc: true)
        .toLocal();

    final DateTime previousMessageDate = DateTime.fromMillisecondsSinceEpoch(
            (previousMessageEpochSecond ?? 0) * millisPerSecond /* Convert seconds to millis */,
            isUtc: true)
        .toLocal();

    return Column(
      children: [
        buildNewDayLabel(
          previousMessageDate: previousMessageDate,
          currentMessageDate: currentMessageDate,
        ),
        buildUserProfile(
          currentMessageClientID: entry.initiatorClientID,
          previousMessageClientID: previousMessageClientID,
          isMessageOwner: isMessageOwner,
        ),
        Align(
          alignment: isMessageOwner ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            padding: const EdgeInsets.all(10),
            constraints: const BoxConstraints(maxWidth: 225, maxHeight: 300),
            decoration: BoxDecoration(
              gradient: isMessageOwner
                  ? const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 0, 70, 0),
                        Color.fromARGB(255, 0, 255, 0)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.topRight,
                    )
                  : const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 70, 70, 70),
                        Color.fromARGB(255, 40, 40, 40)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.topRight,
                    ),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isMessageOwner ? 10 : 2),
                  topRight: Radius.circular(isMessageOwner ? 2 : 10),
                  bottomLeft: const Radius.circular(10),
                  bottomRight: const Radius.circular(10)),
            ),
            child: GestureDetector(
              onTap: () {
                pushSlideTransition(
                  context,
                  CallHistoryPage(historyToHighlight: entry),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: appColors.secondaryColor.withAlpha(100),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    IconButton.filled(
                      style: IconButton.styleFrom(
                        backgroundColor: appColors.tertiaryColor.withAlpha(100),
                        foregroundColor: switch(entry.status) {
                          VoiceCallHistoryStatus.created => Colors.white,
                          VoiceCallHistoryStatus.accepted => Colors.green,
                          VoiceCallHistoryStatus.ignored => Colors.red,
                        },
                      ),
                      onPressed: pushVoiceCall,
                      icon: Icon(
                        switch (entry.status) {
                          VoiceCallHistoryStatus.created => Icons.phone_in_talk,
                          VoiceCallHistoryStatus.accepted => Icons.call,
                          VoiceCallHistoryStatus.ignored => Icons.phone_missed,
                        },
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        spacing: 4,
                        children: [
                          Text(
                            S.current.voice_call,
                            style: Theme.of(context).textTheme.titleSmall,
                            softWrap: true,
                          ),
                          Text(
                            S().started_at_time(CustomDateFormatter.formatDate(
                              EpochDateTime.fromSecondsSinceEpoch(entry.tsDebuted),
                              'HH:mm',
                            )),
                            softWrap: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

}