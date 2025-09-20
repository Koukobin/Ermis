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
import 'package:ermis_mobile/core/networking/common/message_types/voice_call_history_status.dart';
import 'package:ermis_mobile/core/networking/user_info_manager.dart';
import 'package:ermis_mobile/core/util/custom_date_formatter.dart';
import 'package:ermis_mobile/generated/l10n.dart';
import 'package:flutter/material.dart';

import '../../constants/app_constants.dart';
import '../../core/util/datetime_utils.dart';
import '../../core/widgets/scroll/custom_scroll_view.dart';
import '../../theme/app_colors.dart';

class CallHistoryPage extends StatefulWidget {
  final VoiceCallHistory? historyToHighlight;

  const CallHistoryPage({
    super.key,
    this.historyToHighlight,
  });

  @override
  State<CallHistoryPage> createState() => _CallHistoryPageState();
}

class _CallHistoryPageState extends State<CallHistoryPage> {
  late final List<VoiceCallHistory> _callHistory;

  @override
  void initState() {
    super.initState();
    _callHistory = UserInfoManager.chatSessionIDSToVoiceCallHistory.values
        .expand((list) => list)
        .toList();
  }

  String formatDateTime(String pattern, DateTime dateTime) {
    return CustomDateFormatter.formatDate(dateTime, pattern);
  }

  String formatDuration(Duration duration) {
    String minutes = (duration.inMinutes % 60).toString();
    String seconds = (duration.inSeconds % 60).toString();

    if (duration.inHours > 0) {
      return '${duration.inHours} ${S().hours} $minutes ${S().minutes} $seconds ${S().seconds}';
    }

    if (duration.inMinutes > 0) {
      return '$minutes ${S().minutes} $seconds ${S().seconds}';
    }

    return '$seconds ${S().seconds}';
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: Text(S().call_history_app_title),
      ),
      body: _callHistory.isEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Image.asset(
                    AppConstants.ermisCallingPath,
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: appColors.primaryColor,
                    borderRadius: const BorderRadius.all(Radius.circular(24)),
                    border: Border.all(color: appColors.secondaryColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 5,
                    children: [
                      Text(
                        S().voice_calls_history,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: appColors.secondaryColor,
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: appColors.secondaryColor),
                        ),
                        child: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : ScrollViewFixer.createScrollViewWithAppBarSafety(scrollView: ListView.separated(
              itemCount: _callHistory.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
              ),
              itemBuilder: (context, index) {
                final entry = _callHistory[index];
                bool highlight = entry == widget.historyToHighlight;

                final startDate = EpochDateTime.fromSecondsSinceEpoch(entry.tsDebuted);
                final endDate = EpochDateTime.fromSecondsSinceEpoch(entry.tsEnded);

                return ListTile(
                  selected: highlight,
                  selectedTileColor: Colors.deepPurpleAccent.shade700,
                  selectedColor: Colors.white,
                  contentPadding: const EdgeInsets.all(10),
                  leading: Icon(
                    switch (entry.status) {
                      VoiceCallHistoryStatus.created => Icons.phone_in_talk,
                      VoiceCallHistoryStatus.accepted => Icons.call,
                      VoiceCallHistoryStatus.ignored => Icons.phone_missed,
                    },
                    color: switch (entry.status) {
                      VoiceCallHistoryStatus.created => Colors.white,
                      VoiceCallHistoryStatus.accepted => Colors.green,
                      VoiceCallHistoryStatus.ignored => Colors.red,
                    },
                  ),
                  title: Text(
                    '${S().session_capitalized} '
                    '(ID: ${entry.chatSessionID}): '
                    '${UserInfoManager.chatSessionIDSToChatSessions[entry.chatSessionID]!.toString()}',
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${S().caller_capitalized}: ${entry.callerUsername}'),
                      Text(
                        '${formatDateTime('MMM d, yyyy', startDate)}, ${formatDateTime('MMM d, yyyy', endDate)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '${S().duration_capitalized}: ${formatDuration(endDate.difference(startDate))}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () {
                      // Handle tapping for more call details if needed
                    },
                  ),
                );
              },
            )),
    );
  }
}
