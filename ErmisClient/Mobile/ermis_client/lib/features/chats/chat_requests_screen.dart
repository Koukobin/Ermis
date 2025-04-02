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

import 'package:ermis_client/core/event_bus/app_event_bus.dart';
import 'package:ermis_client/core/models/message_events.dart';
import 'package:ermis_client/languages/generated/l10n.dart';
import 'package:ermis_client/theme/app_colors.dart';
import 'package:flutter/material.dart';

import '../../core/data_sources/api_client.dart';
import '../../constants/app_constants.dart';
import '../../core/models/chat_request.dart';
import '../../core/widgets/scroll/custom_scroll_view.dart';
import '../../core/util/top_app_bar_utils.dart';
import '../../core/widgets/loading_state.dart';
import 'widgets/user_avatar.dart';

class ChatRequests extends StatefulWidget {
  const ChatRequests({super.key});

  @override
  State<ChatRequests> createState() => ChatRequestsState();
}

class ChatRequestsState extends LoadingState<ChatRequests> {
  List<ChatRequest>? _chatRequests = Client.instance().chatRequests;

  bool _isInitialized = false; // Flag to check if it's initialized

  ChatRequestsState() {
    if (_chatRequests != null) {
      super.isLoading = false;
    }
  }

  @override
  void initState() {
    super.initState();
    if (_isInitialized) return;

    AppEventBus.instance.on<ChatRequestsEvent>().listen((event) async {
      _updateChatRequests(event.requests);
    });

    _isInitialized = true;
  }

  @override
  Widget build0(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      backgroundColor: appColors.secondaryColor,
      appBar: ErmisAppBar(),
      body: ScrollViewFixer.createScrollViewWithAppBarSafety(
        scrollView: RefreshIndicator(
          // if user scrolls downwards refresh chat requests
          onRefresh: _refreshContent,
          backgroundColor: Colors.transparent,
          color: appColors.primaryColor,
          child: _chatRequests!.isNotEmpty
              ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ListView.separated(
                    itemCount: _chatRequests!.length,
                    itemBuilder: (context, index) => buildChatRequestButton(index),
                    separatorBuilder: (context, index) => Divider(
                      color: appColors.tertiaryColor.withOpacity(0.0),
                      thickness: 1,
                      height: 16,
                    ),
                  ),
              )
              :
              // Wrap in a list view to ensure it is scrollable for refresh indicator
              ListView(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height - 150, // Substract number to center
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Image.asset(AppConstants.ermisMascotPath),
                          ),
                          const SizedBox(height: 15),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: appColors.primaryColor,
                              borderRadius: const BorderRadius.all(Radius.circular(24)),
                              border: Border.all(
                                color: appColors.secondaryColor
                              ),
                            ),
                            child: Text(
                              S.current.no_chat_requests_available,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: appColors.secondaryColor,
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
        ),
      ),
    );
  }

  @override
  Widget buildLoadingScreen() {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      appBar: ErmisAppBar(),
      backgroundColor: appColors.secondaryColor,
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget buildChatRequestButton(int index) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Container(
      height: 150,
      decoration: BoxDecoration(
        border: Border.all(color: appColors.primaryColor, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            UserAvatar.empty(),
            const SizedBox(height: 5),
            Text(
              _chatRequests![index].toString(),
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => Client.instance()
                      .commands
                      .acceptChatRequest(_chatRequests![index].clientID),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(S.current.accept),
                ),
                const SizedBox(width: 10), // Add space between buttons
                OutlinedButton(
                  onPressed: () => Client.instance()
                      .commands
                      .declineChatRequest(_chatRequests![index].clientID),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(S.current.decline),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> _refreshContent() async {
    Client.instance().commands.fetchChatRequests();
    setState(() {
      isLoading = true;
    });
  }

  void _updateChatRequests(List<ChatRequest> chatRequests) {
    if (!mounted) return;
    setState(() {
      _chatRequests = chatRequests;
      isLoading = false;
    });
  }
}
