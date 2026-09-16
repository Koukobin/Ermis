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
import 'package:ermis_mobile/core/services/custom_http_service.dart';
import 'package:ermis_mobile/core/services/database/extensions/servers_extension.dart';
import 'package:ermis_mobile/core/services/database/models/server_info.dart';
import 'package:ermis_mobile/generated/l10n.dart';
import 'package:ermis_mobile/theme/app_colors.dart';
import 'package:ermis_mobile/core/services/database/database_service.dart';
import 'package:ermis_mobile/core/util/dialogs_utils.dart';
import 'package:flutter/material.dart';

import '../../core/services/settings_json.dart';
import '../../core/widgets/profile_photos/avatar_glow.dart';

class ServersDropdownMenu extends StatefulWidget {
  final Set<ServerInfo> cachedServerUrls;
  final Set<ServerInfo> verifiedServers;
  final ValueNotifier<String?> selectedServerUrl;
  const ServersDropdownMenu({
    super.key,
    required this.cachedServerUrls,
    required this.verifiedServers,
    required this.selectedServerUrl,
  });

  @override
  State<ServersDropdownMenu> createState() => _DropdownMenuState();
}

class _DropdownMenuState extends State<ServersDropdownMenu> {
  /// [UniqueKey] used to refresh dropdown menu (i.e force rebuild) when a URL is deleted
  Key _widgetKey = UniqueKey();

  Set<ServerInfo> get cachedServerUrls => widget.cachedServerUrls;
  Set<ServerInfo> get verifiedServers  => widget.verifiedServers;

  String? get selectedServerUrl => widget.selectedServerUrl.value;
  set selectedServerUrl(String? url) => widget.selectedServerUrl.value = url;

  Future<String?> showServerPicker(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: S.current.chooseServerUrl,
                  prefixIcon: const Icon(Icons.search),
                ),
                onSubmitted: (url) async {
                  if (url.isEmpty) return;

                  ServerInfo serverInfo;
                  try {
                    serverInfo = ServerInfo(url);
                  } on InvalidServerUrlException catch (e) {
                    showExceptionDialog(context, e.message);
                    return;
                  }

                  await ErmisDB.getConnection().insertServerInfo(serverInfo);

                  // Feedback
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(S.current.serverAddedSuccess)),
                  );

                  setState(() {
                    cachedServerUrls.add(serverInfo);
                    selectedServerUrl = url;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                children: [
                  if (verifiedServers.isNotEmpty) ...[
                    _SectionHeader(S().Verified),
                    ...verifiedServers.map((s) => _VerifiedServerTile(
                          server: s,
                          onTap: () {
                            setState(() {
                              selectedServerUrl = s.toString();
                            });
                            Navigator.pop(context);
                          },
                        )),
                  ],
                  if (cachedServerUrls.isNotEmpty) ...[
                    _SectionHeader(S().Recent),
                    ...cachedServerUrls.map((s) => Dismissible(
                          key: ValueKey(s),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => removeServer(s),
                          background: Container(color: Colors.red),
                          child: _CachedServerTile(
                            server: s,
                            onTap: () {
                              setState(() {
                                selectedServerUrl = s.toString();
                              });
                              Navigator.pop(context);
                            },
                            onSave: (newServerInfo) async {
                              await ErmisDB.getConnection().updateServerInfo(s, newServerInfo);

                              cachedServerUrls.add(newServerInfo);
                              cachedServerUrls.remove(s);
                            },
                            onDelete: () => removeServer(s),
                          ),
                        )),
                  ],
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  void removeServer(ServerInfo server) {
    ErmisDB.getConnection().removeServerInfo(server);
    setState(() {
      widget.cachedServerUrls.remove(server);
      if (selectedServerUrl == server.toString()) {
        selectedServerUrl = null;
      }
      _widgetKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final colorScheme = Theme.of(context).colorScheme;

    Widget showServerPickerButton = IconButton(
          onPressed: () => showServerPicker(context),
          icon: Icon(Icons.dns, color: Colors.lightGreenAccent) // TODO: change color dynamically using color scheme
        );

    if (!SettingsJson().whatsNewStatus.hasSeen) {
      showServerPickerButton = AvatarGlow(
        glowColor: colorScheme.primary,
        glowRadiusFactor: 0.3,
        child: showServerPickerButton,
      );
    }

    return DropdownMenu<String>(
      key: _widgetKey,
      initialSelection: selectedServerUrl,
      expandedInsets: EdgeInsets.zero,
      hintText: S.current.chooseServerUrl,
      textStyle: TextStyle(
        color: appColors.primaryColor,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      trailingIcon: Icon(
        Icons.arrow_drop_down,
        color: appColors.primaryColor,
      ),
      selectedTrailingIcon: Icon(
        Icons.arrow_drop_up,
        color: appColors.primaryColor,
      ),
      leadingIcon: showServerPickerButton,
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(
          color: appColors.primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(
          appColors.secondaryColor.withValues(alpha: 0.9),
        ),
      ),
      onSelected: (String? selectedUrl) {
        setState(() {
          selectedServerUrl = selectedUrl!;
        });
      },
      dropdownMenuEntries: [
        ...widget.verifiedServers.map((ServerInfo server) {
          const goldGradient = [
            Color(0xFFFFF6BA),
            Color(0xFFFFBD3C),
            Color(0xFFB8860B),
            Color(0xFFFFBD3C),
          ];
          return DropdownMenuEntry<String>(
            value: "$server",
            label: server.toString(),
            labelWidget: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: goldGradient,
                stops: [0.0, 0.4, 0.7, 1.0],
              ).createShader(bounds),
              child: Text(
                server.toString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  shadows: [
                    Shadow(blurRadius: 15.0, color: Color(0xFFFFBD3C)),
                    Shadow(blurRadius: 10.0, color: Color(0xFFFFF6BA)),
                  ],
                ),
              ),
            ),
            trailingIcon: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: goldGradient,
                stops: [0.0, 0.4, 0.7, 1.0],
              ).createShader(bounds),
              child: IconButton(
                icon: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: goldGradient,
                    stops: [0.0, 0.4, 0.7, 1.0],
                  ).createShader(bounds),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 28,
                    shadows: [
                      Shadow(blurRadius: 20.0, color: goldGradient[1]),
                      Shadow(blurRadius: 8.0, color: goldGradient[0]),
                    ],
                  ),
                ),
                onPressed: () {
                  showServerPicker(context);
                },
              ),
            ),
          );
        }),
        ...widget.cachedServerUrls.map((ServerInfo server) {
          return DropdownMenuEntry<String>(
            value: server.toString(),
            label: server.toString(),
            labelWidget: Text(
              server.toString(),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: appColors.primaryColor),
            ),
            trailingIcon: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              splashRadius: 20,
              onPressed: () => removeServer(server),
            ),
          );
        }),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _VerifiedServerTile extends StatelessWidget {
  final ServerInfo server;
  final VoidCallback onTap;
  const _VerifiedServerTile({required this.server, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const goldGradient = [
      Color(0xFFFFF6BA),
      Color(0xFFFFBD3C),
      Color(0xFFB8860B),
      Color(0xFFFFBD3C),
    ];

    return ListTile(
      onTap: onTap,
      leading: _ServerStatusIndicator(server: server),
      title: ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          colors: goldGradient,
          stops: [0.0, 0.4, 0.7, 1.0],
        ).createShader(bounds),
        child: Text(
          server.toString(),
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
            shadows: [
              Shadow(blurRadius: 15.0, color: Color(0xFFFFBD3C)),
              Shadow(blurRadius: 10.0, color: Color(0xFFFFF6BA)),
            ],
          ),
        ),
      ),
      trailing: ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: goldGradient,
          stops: [0.0, 0.4, 0.7, 1.0],
        ).createShader(bounds),
        child: const Icon(
          Icons.verified,
          color: Colors.white,
          size: 24,
          shadows: [
            Shadow(blurRadius: 20.0, color: Color(0xFFFFBD3C)),
            Shadow(blurRadius: 8.0, color: Color(0xFFFFF6BA)),
          ],
        ),
      ),
    );
  }
}

class _CachedServerTile extends StatefulWidget {
  final ServerInfo server;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final ValueChanged<ServerInfo> onSave;
  const _CachedServerTile({
    required this.server,
    required this.onTap,
    required this.onDelete,
    required this.onSave,
  });

  @override
  State<_CachedServerTile> createState() => _CachedServerTileState();
}

class _CachedServerTileState extends State<_CachedServerTile> {
  bool _editing = false;
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.server.toString());
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _cancel() {
    setState(() {
      _controller.text = widget.server.toString();
      _errorText = null;
      _editing = false;
    });
  }

  void _commit() {
    final value = _controller.text.trim();

    ServerInfo newServerInfo;
    try {
      newServerInfo = ServerInfo(value);
    } on InvalidServerUrlException catch (e) {
      setState(() => _errorText = e.message);
      return;
    }

    widget.onSave(newServerInfo);
    setState(() {
      _errorText = null;
      _editing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return GestureDetector(
      onLongPress: () {
        setState(() {
          _editing = !_editing;
        });
      },
      child: ListTile(
        onTap: widget.onTap,
        leading: _ServerStatusIndicator(server: widget.server),
        title: _editing
            ? TextField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: true,
                keyboardType: TextInputType.url,
                style: TextStyle(color: appColors.primaryColor),
                cursorColor: appColors.primaryColor,
                onChanged: (_) {
                  if (_errorText != null) setState(() => _errorText = null);
                },
                onSubmitted: (_) => _commit(),
                decoration: InputDecoration(
                  isDense: true,
                  errorText: _errorText,
                  border: const UnderlineInputBorder(),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: appColors.primaryColor.withValues(alpha: 0.4)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: appColors.primaryColor, width: 2),
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        color: Colors.red,
                        splashRadius: 16,
                        onPressed: _cancel,
                      ),
                      IconButton(
                        icon: const Icon(Icons.check, size: 18),
                        color: Colors.green,
                        splashRadius: 16,
                        onPressed: _commit,
                      ),
                    ],
                  ),
                ),
              )
            : Text(
                widget.server.toString(),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: appColors.primaryColor),
              ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          splashRadius: 20,
          onPressed: widget.onDelete,
        ),
      ),
    );
  }
}

/// Small colored dot signaling reachability: grey while checking,
/// green if reachable, red if not.
class _ServerStatusIndicator extends StatefulWidget {
  final ServerInfo server;
  const _ServerStatusIndicator({required this.server});

  @override
  State<_ServerStatusIndicator> createState() => _ServerStatusIndicatorState();
}

class _ServerStatusIndicatorState extends State<_ServerStatusIndicator> {
  late final Future<bool> _reachable;

  @override
  void initState() {
    super.initState();
    _reachable = CustomHttpClient().pingServer(widget.server.toString());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _reachable,
      builder: (context, snapshot) {
        Color color;
        if (!snapshot.hasData) {
          color = Colors.grey;
        } else {
          color = snapshot.data! ? Colors.green : Colors.red;
        }
        return Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
