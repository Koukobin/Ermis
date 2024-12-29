import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../client/client.dart';
import '../../client/common/chat_request.dart';
import '../../theme/app_theme.dart';
import '../../util/buttons_utils.dart';
import '../../util/top_app_bar_utils.dart';
import '../loading_state.dart';
import 'user_avatar.dart';

class ChatRequests extends StatefulWidget {
  const ChatRequests({super.key});

  @override
  State<ChatRequests> createState() => ChatRequestsState();
}

class ChatRequestsState extends LoadingState<ChatRequests> {
  List<ChatRequest>? _chatRequests = Client.getInstance().chatRequests;

  ChatRequestsState() {
    if (_chatRequests != null) {
      super.isLoading = false;
    }
  }

  @override
  void initState() {
    super.initState();
    Client.getInstance().whenChatRequestsReceived((List<ChatRequest> chatRequests) {
      updateChatRequests(chatRequests);
    });
  }

  @override
  Widget build0(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
        backgroundColor: appColors.secondaryColor,
        appBar: const ErmisAppBar(),
        body: RefreshIndicator(
          // if user scrolls downwards refresh chat requests
          onRefresh: _refreshContent,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: _chatRequests!.isNotEmpty
                ? ListView.separated(
                    itemCount: _chatRequests!.length,
                    itemBuilder: (context, index) =>
                        buildChatRequestButton(index),
                    separatorBuilder: (context, index) => Divider(
                      color: appColors.tertiaryColor.withOpacity(0.0),
                      thickness: 1,
                      height: 16,
                    ),
                  )
                :
                // Wrap in a list view to ensure it is scrollable for refresh indicator
                ListView(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height -
                            150, // Substract number to center
                        child: Center(
                          child: Text(
                            "No chat requests available",
                            style: TextStyle(
                              color: appColors.inferiorColor,
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
          ),
        ));
  }

  @override
  Widget buildLoadingScreen() {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      appBar: const ErmisAppBar(),
      backgroundColor: appColors.secondaryColor,
      body: Center(child: CircularProgressIndicator()),
    );
  }

  Widget buildChatRequestButton(int index) {
    return createOutlinedButton(
        context: context,
        text: Text(_chatRequests![index].toString()),
        avatar: UserAvatar(
            imageBytes: Uint8List.fromList(List.empty()), isOnline: false),
        otherWidgets: [
          GestureDetector(
            onTap: () => Client.getInstance()
                .commands
                .acceptChatRequest(_chatRequests![index].clientID),
            child: Icon(
              Icons.check,
              color: Colors.greenAccent,
            ),
          ),
          GestureDetector(
            onTap: () => Client.getInstance()
                .commands
                .declineChatRequest(_chatRequests![index].clientID),
            child: Icon(
              Icons.cancel_outlined,
              color: Colors.redAccent,
            ),
          ),
        ],
        onTap: () {});
  }

  Future<void> _refreshContent() async {
    Client.getInstance().commands.fetchChatRequests();
    setState(() {
      isLoading = true;
    });
  }

  void updateChatRequests(List<ChatRequest> chatRequests) {
    setState(() {
      _chatRequests = chatRequests;
      isLoading = false;
    });
  }
}
