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

import 'dart:async';

import 'package:ermis_mobile/core/data_sources/api_client.dart';
import 'package:ermis_mobile/core/event_bus/app_event_bus.dart';
import 'package:ermis_mobile/core/models/message.dart';
import 'package:ermis_mobile/core/models/message_events.dart';
import 'package:ermis_mobile/core/util/dialogs_utils.dart';
import 'package:ermis_mobile/core/util/file_utils.dart';
import 'package:ermis_mobile/generated/l10n.dart';
import 'package:ermis_mobile/mixins/event_bus_subscription_mixin.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

import '../../../../../theme/app_colors.dart';

class FileMessageBubble extends StatefulWidget {
  final AppColors appColors;
  final Message message;

  const FileMessageBubble({
    super.key,
    required this.appColors,
    required this.message,
  });

  @override
  State<FileMessageBubble> createState() => _FileMessageBubbleState();
}

class _FileMessageBubbleState extends State<FileMessageBubble> with EventBusSubscriptionMixin {
  Message get message => widget.message;
  bool get isFetched => message.fileBytes != null;

  bool isFetching = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> fetchFile() async {
    setState(() {
      isFetching = true;
    });
    Client.instance().commands?.downloadFile(
          message.messageID,
          message.chatSessionIndex,
        );

    Completer completer = Completer();

    StreamSubscription<FileDownloadedEvent>? sub;
    sub = AppEventBus.instance.on<FileDownloadedEvent>().listen((event) async {
      if (event.messageID == widget.message.messageID) {
        setState(() {
          isFetching = false;
        });

        sub!.cancel().then((_) {
          completer.complete();
        });
      }
    });

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () async {
            if (!isFetched) await fetchFile();
    
            String filePath = (await createTempFile(
              message.fileBytes!,
              message.fileName,
            ))
                .path;
    
            OpenFilex.open(filePath);
          },
          child: Container(
            decoration: BoxDecoration(
              color: widget.appColors.secondaryColor.withAlpha(100),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    if (!isFetched) await fetchFile();
                
                    bool success = await saveFileToDownloads(
                      message.fileName,
                      message.fileBytes!,
                    );
                
                    if (!context.mounted) return;
                
                    if (success) {
                      showSnackBarDialog(
                        context: context,
                        content: S.current.downloaded_file,
                      );
                      return;
                    }
                
                    showExceptionDialog(
                      context,
                      S.current.error_saving_file,
                    );
                  },
                  child: isFetching
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        )
                      : const Icon(Icons.download),
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message.fileName,
                        softWrap: true, // Enable text wrapping
                        overflow: TextOverflow.clip,
                        maxLines: null,
                      ),
                      Text(S.current.unknown_size),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Text(
          message.fileName,
          softWrap: true, // Enable text wrapping
          overflow: TextOverflow.clip,
          maxLines: null,
        ),
      ],
    );
  }
}