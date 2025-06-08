import 'package:ermis_client/core/models/voice_call_history.dart';
import 'package:ermis_client/core/networking/common/message_types/voice_call_history_status.dart';
import 'package:ermis_client/core/networking/user_info_manager.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/util/datetime_utils.dart';
import '../../core/widgets/scroll/custom_scroll_view.dart';

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
    return DateFormat(pattern).format(dateTime);
  }
  
  String formatDuration(Duration duration) {
    String minutes = (duration.inMinutes % 60).toString();
    String seconds = (duration.inSeconds % 60).toString();

    if (duration.inHours > 0) {
      return '${duration.inHours} hours $minutes minutes $seconds seconds';
    }

    if (duration.inMinutes > 0) {
      return '$minutes minutes $seconds seconds';
    }

    return '$seconds seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call History'),
      ),
      body: _callHistory.isEmpty
          ? const Center(
              child: Text('No call history available'),
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
                    switch(entry.status) {
                      VoiceCallHistoryStatus.created => Icons.phone_in_talk,
                      VoiceCallHistoryStatus.accepted => Icons.call,
                      VoiceCallHistoryStatus.ignored => Icons.phone_missed,
                    },
                    color: switch(entry.status) {
                      VoiceCallHistoryStatus.created => Colors.white,
                      VoiceCallHistoryStatus.accepted => Colors.green,
                      VoiceCallHistoryStatus.ignored => Colors.red,
                    },
                  ),
                  title: Text('Session (ID: ${entry.chatSessionID}): ${UserInfoManager.chatSessionIDSToChatSessions[entry.chatSessionID]!.toString()}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Caller: ${entry.callerUsername}'),
                      Text(
                        '${formatDateTime('MMM d, yyyy', startDate)} at ${formatDateTime('HH:mm', endDate)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        'Duration: ${formatDuration(endDate.difference(startDate))}',
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
