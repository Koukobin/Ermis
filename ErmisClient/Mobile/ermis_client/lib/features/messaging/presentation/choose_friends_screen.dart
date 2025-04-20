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

import 'package:ermis_client/core/data_sources/api_client.dart';
import 'package:ermis_client/core/extensions/iterable_extensions.dart';
import 'package:ermis_client/core/models/member.dart';
import 'package:ermis_client/core/util/transitions_util.dart';
import 'package:ermis_client/features/chats/widgets/user_avatar.dart';
import 'package:ermis_client/generated/l10n.dart';
import 'package:flutter/material.dart';

import '../../../core/models/chat_session.dart';
import '../../../theme/app_colors.dart';

Future<List<Member>> showChooseFriendsScreen(
  BuildContext context, {
  List<Member> membersToExclude = const [],
}) async {
  List<Member> members = await pushSlideTransition(
    context,
    ChooseFriendScreen(membersToExclude: membersToExclude),
  );

  return members;
}

class ChooseFriendScreen extends StatefulWidget {
  final List<Member> membersToExclude;
  const ChooseFriendScreen({
    super.key,
    this.membersToExclude = const [],
  });

  @override
  State<ChooseFriendScreen> createState() => _ChooseFriendScreenState();
}

class _ChooseFriendScreenState extends State<ChooseFriendScreen> {
  late final List<Member> friends;
  final Set<Member> selectedFriends = {};
  late List<Member> results;

  @override
  void initState() {
    friends = Client.instance()
      .chatSessions!
      .map((ChatSession session) => session.members)
      .expand((List<Member> members) => members.toList())
      .where((member) {
        return !widget.membersToExclude.map((m) => m.clientID).toList().contains(member.clientID);
      })
      .toHashOnlySet() // Remove duplicates
      .toList();

    results = friends;
    super.initState();
  }

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      appBar: AppBar(
          leading: BackButton(
            onPressed: () => Navigator.pop(context, <Member>[]),
          ),
          title: Text(S.current.choose_friends)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: S.current.search,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => _controller.text = '',
                  )
              ),
              onChanged: (query) {
                setState(() {
                  if (_controller.text.isEmpty) {
                    results = friends;
                  } else {
                    results = friends
                        .where((friend) =>
                            friend.toString().toLowerCase().contains(query.toLowerCase()))
                        .toList();
                  }
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                final friend = results[index];
                int startingIndex = friend.toString().toLowerCase().indexOf(_controller.text);
                int endIndex;

                if (startingIndex == -1) {
                  startingIndex = 0;
                  endIndex = 0;
                } else {
                  endIndex = startingIndex + _controller.text.length;
                }
                return CheckboxListTile(
                  title: Text.rich(TextSpan(
                    text: friend.toString().substring(0, startingIndex),
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                    children: [
                      TextSpan(
                        text: friend.toString().substring(startingIndex, endIndex),
                        style: TextStyle(
                            color: appColors.inferiorColor,
                            fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: friend.toString().substring(endIndex),
                      ),
                    ],
                  )),
                  secondary: UserAvatar(imageBytes: friend.icon.profilePhoto, status: friend.status),
                  value: selectedFriends.contains(friend),
                  activeColor: Colors.green,
                  onChanged: (selected) {
                    setState(() {
                      if (selected == true) {
                        selectedFriends.add(friend);
                      } else {
                        selectedFriends.remove(friend);
                      }
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context, selectedFriends.toList());
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}


// Example usage within a widget:
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Friend Example')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            showChooseFriendsScreen(context);
            // final result = await showSearch(
            //     context: context,
            //     delegate: FriendSearchDelegate(friends),
            //   );
          },
          child: const Text('Choose Friends'),
        ),
      ),
    );
  }
}

// class FriendSearchDelegate extends SearchDelegate<String?> {
//   final List<String> friends;

//   FriendSearchDelegate(this.friends);

//   @override
//   List<Widget>? buildActions(BuildContext context) {
//     return [
//       if (query.isNotEmpty)
//         IconButton(
//           icon: Icon(Icons.clear),
//           onPressed: () => query = '',
//         ),
//     ];
//   }

//   @override
//   Widget? buildLeading(BuildContext context) {
//     return IconButton(
//       icon: Icon(Icons.arrow_back),
//       onPressed: () => close(context, null),
//     );
//   }

//   @override
//   Widget buildResults(BuildContext context) {
//     return _buildFriendList();
//   }

//   @override
//   Widget buildSuggestions(BuildContext context) {
//     return _buildFriendList();
//   }

//   Widget _buildFriendList() {
//     final results = friends
//         .where((String friend) => friend.toLowerCase().contains(query.toLowerCase()))
//         .toList();

//     return ListView.builder(
//       itemCount: results.length,
//       itemBuilder: (context, index) {
//         final friend = results[index];
//         return ListTile(
//           leading: CircleAvatar(child: Text(friend[0])),
//           title: Text(friend),
//           onTap: () => close(context, friend),
//         );
//       },
//     );
//   }
// }
