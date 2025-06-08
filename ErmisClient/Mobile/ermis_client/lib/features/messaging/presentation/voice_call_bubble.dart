
import 'package:ermis_client/core/models/voice_call_history.dart';
import 'package:ermis_client/generated/l10n.dart';
import 'package:flutter/material.dart';

import '../../../core/data_sources/api_client.dart';
import '../../../core/util/custom_date_formatter.dart';
import '../../../core/util/datetime_utils.dart';
import '../../../core/util/transitions_util.dart';
import '../../../theme/app_colors.dart';
import '../../call_history_screen/call_history_screen.dart';

class VoiceCallBubble extends StatelessWidget {
  final VoiceCallHistory entry;
  final VoidCallback pushVoiceCall;

  const VoiceCallBubble({
    super.key,
    required this.entry,
    required this.pushVoiceCall,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    final bool isMessageOwner = entry.initiatorClientID == Client.instance().clientID;

    return Align(
      alignment: isMessageOwner ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(10),
        constraints: const BoxConstraints(maxWidth: 225, maxHeight: 300),
        decoration: BoxDecoration(
          gradient: isMessageOwner
              ? LinearGradient(
                  colors: [
                    Color.fromARGB(255, 0, 70, 0),
                    Color.fromARGB(255, 0, 255, 0)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.topRight,
                )
              : null,
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
                    foregroundColor: Colors.white,
                  ),
                  onPressed: pushVoiceCall,
                  icon: const Icon(Icons.phone),
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
                        "Started at: ${CustomDateFormatter.formatDate(EpochDateTime.fromSecondsSinceEpoch(entry.tsDebuted), 'HH:mm')}",
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
    );
  }

}