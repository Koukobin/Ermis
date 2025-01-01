import 'dart:typed_data';

import 'package:ermis_client/client/app_event_bus.dart';
import 'package:ermis_client/client/message_events.dart';
import 'package:flutter/material.dart';

import '../../client/client.dart';
import '../../client/common/chat_request.dart';
import '../../theme/app_theme.dart';
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
    AppEventBus.instance.on<ChatRequestsEvent>().listen((event) async {
      _updateChatRequests(event.requests);
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
            UserAvatar(
              imageBytes: Uint8List.fromList(List.empty()),
              isOnline: false,
            ),
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
                  onPressed: () => Client.getInstance()
                      .commands
                      .acceptChatRequest(_chatRequests![index].clientID),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text("Accept"),
                ),
                SizedBox(width: 10), // Add space between buttons
                OutlinedButton(
                  onPressed: () => Client.getInstance()
                      .commands
                      .declineChatRequest(_chatRequests![index].clientID),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text("Decline"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> _refreshContent() async {
    Client.getInstance().commands.fetchChatRequests();
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
