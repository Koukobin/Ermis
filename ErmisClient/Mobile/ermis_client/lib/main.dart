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
import 'package:ermis_mobile/core/models/chat_session.dart';
import 'package:ermis_mobile/core/models/message.dart';
import 'package:ermis_mobile/constants/app_constants.dart';
import 'package:ermis_mobile/core/services/database/extensions/chat_messages_extension.dart';
import 'package:ermis_mobile/core/services/database/extensions/servers_extension.dart';
import 'package:ermis_mobile/core/services/database/extensions/unread_messages_extension.dart';
import 'package:ermis_mobile/core/services/database/models/server_info.dart';
import 'package:ermis_mobile/core/services/ermis_backgroud_service.dart';
import 'package:ermis_mobile/core/util/message_notification.dart';
import 'package:ermis_mobile/core/util/transitions_util.dart';
import 'package:ermis_mobile/features/authentication/domain/entities/client_session_setup.dart';
import 'package:ermis_mobile/features/voice_call/web_rtc/voice_call_webrtc.dart';
import 'package:ermis_mobile/generated/l10n.dart';
import 'package:ermis_mobile/features/splash_screen/splash_screen.dart';
import 'package:ermis_mobile/mixins/event_bus_subscription_mixin.dart';
import 'package:ermis_mobile/theme/app_colors.dart';
import 'package:ermis_mobile/core/services/database/database_service.dart';
import 'package:ermis_mobile/core/util/notifications_util.dart';
import 'package:ermis_mobile/core/services/settings_json.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sql.dart';

import 'core/event_bus/app_event_bus.dart';
import 'core/models/message_events.dart';
import 'core/networking/user_info_manager.dart';
import 'core/util/glitching_overlay.dart';
import 'features/chat_requests_screen/chat_requests_screen.dart';
import 'features/messaging/presentation/messaging_interface.dart';
import 'features/settings/options/profile_settings.dart';
import 'features/voice_call/web_rtc/incoming_voice_call_screen.dart';
import 'theme/app_theme.dart';
import 'features/chats/chats_interface.dart';
import 'features/settings/primary_settings_interface.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as timezones;

import 'core/util/dialogs_utils.dart';

import 'dart:io' show Platform, Socket;

void main() async {
  // Ensure that Flutter bindings are initialized before running the app
  // (necessary for specifying things such as screen orientation).
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid || Platform.isIOS) {
    ErmisBackgroudService.startBackgroundService();
  }

  await AppConstants.initialize();
  await NotificationService.init();
  timezones.initializeTimeZones();

  final jsonSettings = SettingsJson();
  await jsonSettings.loadSettingsJson();

  ThemeMode themeData;
  if (jsonSettings.useSystemDefaultTheme) {
    themeData = ThemeMode.system;
  } else if (jsonSettings.isDarkModeEnabled) {
    themeData = ThemeMode.dark;
  } else {
    themeData = ThemeMode.light;
  }

  // Restrict app orientation to portrait mode only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) => runApp(_MyApp(
        lightAppColors: AppConstants.lightAppColors,
        darkAppColors: AppConstants.darkAppColors,
        themeMode: themeData,
      )));
}

class _MyApp extends StatefulWidget {
  final AppColors lightAppColors;
  final AppColors darkAppColors;
  final ThemeMode themeMode;

  const _MyApp({
    required this.lightAppColors,
    required this.darkAppColors,
    required this.themeMode,
  });

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<_MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    debugPrint("App is ${state.name}");
    switch (state) {
      case AppLifecycleState.paused:
        // App is moved to the background
        break;
      case AppLifecycleState.resumed:
        // App is brought back to the foreground
        break;
      case AppLifecycleState.detached:
        // App is being terminated
        break;
      case AppLifecycleState.inactive:
        // App is temporarily inactive
        break;
      case AppLifecycleState.hidden:
        // App is hidden
        break;
    }
  }


  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AppTheme(
        darkAppColors: widget.darkAppColors,
        lightAppColors: widget.lightAppColors,
        theme: widget.themeMode,
        home: const SplashScreen(),
      ),
    );
  }
}

class MainInterface extends StatefulWidget {
  const MainInterface({super.key});

  @override
  State<MainInterface> createState() => MainInterfaceState();
}

class MainInterfaceState extends State<MainInterface> with EventBusSubscriptionMixin {
  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  static const Chats _chatsWidget = Chats();
  static const ChatRequests _chatRequestsWidget = ChatRequests();
  static const SettingsScreen _settingsScreenWidget = SettingsScreen();
  static const ProfileSettings _profileSettingsWidget = ProfileSettings();

  static const List<Widget> _widgetOptions = <Widget>[
    _chatsWidget,
    _chatRequestsWidget,
    _settingsScreenWidget,
    _profileSettingsWidget,
  ];

  late List<NavigationDestination> _barItems;
  late PageController _pageController;

  int _selectedPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedPageIndex);

    subscribe(AppEventBus.instance.on<DataReceivedEvent>(), (event) {
      ErmisDB.getConnection().insertDataBytesReceived(
        UserInfoManager.serverInfo,
        event.dataSizeBytes,
      );
    });

    subscribe(AppEventBus.instance.on<ServerMessageInfoEvent>(), (event) {
      showToastDialog(event.message);
    });

    subscribe(AppEventBus.instance.on<ConnectionResetEvent>(), (event) {
      showToastDialog(S.current.connection_reset);
      setState(() {});
    });

    subscribe(AppEventBus.instance.on<MessageDeletionUnsuccessfulEvent>(), (event) {
      showToastDialog(S.current.message_deletion_unsuccessful);
    });

    subscribe(AppEventBus.instance.on<WrittenTextEvent>(), (event) async {
      List<Message> messages = event.chatSession.messages;

      ServerInfo serverInfo = UserInfoManager.serverInfo;
      DBConnection conn = ErmisDB.getConnection();

      for (final Message message in messages) {
        int resultUpdate = await conn.insertChatMessage(
          serverInfo: serverInfo,
          message: message,
          onConflict: ConflictAlgorithm.ignore,
        );

        if (resultUpdate > 0 && message.clientID != UserInfoManager.clientID) {
          conn.insertUnreadMessage(
            serverInfo,
            message.chatSessionID,
            message.messageID,
          );
        }

        await conn.insertChatMessage(
          serverInfo: serverInfo,
          message: message,
          onConflict: ConflictAlgorithm.replace,
        );
      }
    });

    subscribe(AppEventBus.instance.on<MessageReceivedEvent>(), (event) async {
      ChatSession chatSession = event.chatSession;
      Message msg = event.message;

      ServerInfo serverInfo = UserInfoManager.serverInfo;
      DBConnection conn = ErmisDB.getConnection();

      conn.insertChatMessage(
        serverInfo: serverInfo,
        message: msg,
      );

      // This predicament could occur if a client is connected
      // on a given ermis server from multiple devices with
      // the same account.
      if (msg.clientID == Client.instance().clientID) {
        return;
      }

      // If instance is active let it handle the message received event
      if (MessageInterfaceTracker.isScreenInstanceActive) return;

      conn.insertUnreadMessage(serverInfo, msg.chatSessionID, msg.messageID);

      SettingsJson settingsJson = SettingsJson();
      settingsJson.loadSettingsJson();
      handleChatMessageNotificationForeground(
        chatSession,
        msg,
        settingsJson,
        (text) => Client.instance().sendMessageToClient(text, chatSession.chatSessionIndex),
      );
    });

    subscribe(AppEventBus.instance.on<MessageDeliveryStatusEvent>(), (event) {
      Message message = event.message;

      ServerInfo serverInfo = UserInfoManager.serverInfo;
      DBConnection conn = ErmisDB.getConnection();

      conn.insertChatMessage(
        serverInfo: serverInfo,
        message: message,
      );
    });

    subscribe(AppEventBus.instance.on<VoiceCallIncomingEvent>(), (incomingEvent) async {
      void pushVoiceCall() {
        pushVoiceCallWebRTC(
          context,
          chatSessionID: incomingEvent.chatSessionID,
          chatSessionIndex: incomingEvent.chatSessionIndex,
          member: incomingEvent.member,
          isInitiator: false,
        );
      }

      StreamSubscription<CancelVoiceCallIncomingEvent>? subscription;

      int notificationID = await NotificationService.showVoiceCallNotification(
        icon: incomingEvent.member.icon.profilePhoto,
        callerName: incomingEvent.member.username,
        onAccept: () {
          // Pop incoming call screen which is pushed below
          Navigator.pop(context);

          // Actually push call
          pushVoiceCall();

          subscription!.cancel();
        },
      );

      Completer completer = Completer();

      subscription = AppEventBus.instance
          .on<CancelVoiceCallIncomingEvent>()
          .listen((cancelEvent) {
        if (cancelEvent.chatSessionID == incomingEvent.chatSessionID) {
          // Pop incoming call screen which is pushed below - if still displayed
          if (!completer.isCompleted) {
            Navigator.pop(context);
          }

          // Cancel notification
          NotificationService.cancelNotification(notificationID);

          subscription!.cancel();
        }
      });

      bool? didAccept = await navigateWithFade(context, IncomingCallScreen(member: incomingEvent.member));
      completer.complete();

      if (kDebugMode) {
        debugPrint(didAccept.toString());
        debugPrint(didAccept.toString());
        debugPrint(didAccept.toString());
        debugPrint(didAccept.toString());
        debugPrint(didAccept.toString());
        debugPrint(didAccept.toString());
      }

      if (didAccept == true) {
        pushVoiceCall();
        NotificationService.cancelNotification(notificationID);
        subscription.cancel();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    GlitchingOverlay.removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    _barItems = <NavigationDestination>[
      NavigationDestination(
        icon: Badge.count(
          isLabelVisible: _chatsWidget.getTotalUnreadMessagesCount() > 0,
          count: _chatsWidget.getTotalUnreadMessagesCount(),
          child: const Icon(Icons.chat_outlined),
        ),
        selectedIcon: Badge.count(
          isLabelVisible: _chatsWidget.getTotalUnreadMessagesCount() > 0,
          count: _chatsWidget.getTotalUnreadMessagesCount(),
          child: const Icon(Icons.chat),
        ),
        label: S.current.chats,
      ),
      NavigationDestination(
        icon: Badge.count(
          isLabelVisible: UserInfoManager.chatRequests?.isNotEmpty ?? false,
          count: UserInfoManager.chatRequests?.length ?? 0,
          child: const Icon(Icons.person_add_alt_1_outlined),
        ),
        selectedIcon: Badge.count(
          isLabelVisible: UserInfoManager.chatRequests?.isNotEmpty ?? false,
          count: UserInfoManager.chatRequests?.length ?? 0,
          child: const Icon(Icons.person_add_alt_1),
        ),
        label: S.current.requests,
      ),
      NavigationDestination(
        icon: const Icon(Icons.settings_outlined),
        selectedIcon: const Icon(Icons.settings),
        label: S.current.settings,
      ),
      NavigationDestination(
        icon: const Icon(Icons.account_circle_outlined),
        selectedIcon: const Icon(Icons.account_circle),
        label: S.current.account,
      )
    ];

    void onItemTapped(int newPageIndex) {
      setState(() {
        _selectedPageIndex = newPageIndex;
      });
    }

    Widget body = Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: onItemTapped,
        children: _widgetOptions,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: const Color(0xffAEADB2).withValues(alpha: 0.4),
              width: 0.2,
            ),
          ),
        ),
        child: NavigationBar(
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          indicatorColor: appColors.primaryColor.withValues(alpha: 0.6),
          backgroundColor: appColors.secondaryColor,
          selectedIndex: _selectedPageIndex,
          onDestinationSelected: (int newPageIndex) {
            // Have to manually animate to next page
            _pageController.animateToPage(
              newPageIndex,
              duration: const Duration(milliseconds: 300),
              curve: Curves.fastEaseInToSlowEaseOut,
            );
          },
          destinations: _barItems,
        ),
      ),
    );

    if (Client.instance().isConnectionReset() ||
        Client.instance().isConnectionRefused()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        GlitchingOverlay.showOverlay(context);

        Future.doWhile(() async {
          ServerInfo serverInfo = UserInfoManager.serverInfo;

          Future<bool> hasInternet() async {
            try {
              final socket = await Socket.connect(
                serverInfo.address!.host,
                serverInfo.port!,
                timeout: const Duration(seconds: 5),
              );
              socket.destroy();

              return true;
            } catch (e) {
              if (kDebugMode) debugPrint('$e');
              return false;
            }
          }

          bool isConnected() {
            return !Client.instance().isConnectionReset() &&
                !Client.instance().isConnectionRefused();
          }

          return await Future.delayed(const Duration(seconds: 10), () async {
            if (isConnected()) return false;
            if (!await hasInternet()) return true;

            await Client.instance().disconnect();
            try {
              await Client.instance().initialize(
                serverInfo.serverUrl,
                ServerCertificateVerification.ignore,
              );
            } catch (e) {
              if (kDebugMode) debugPrint('$e');
              return true;
            }

            if (context.mounted) setupClientSession(context);

            return false;
          });
        });
      });

      body = Transform.translate(
        offset: const Offset(15, 5),
        child: body,
      );
    }

    return body;
  }
}

