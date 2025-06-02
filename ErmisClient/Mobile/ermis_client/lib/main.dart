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
import 'dart:convert';
import 'dart:ui';

import 'package:ermis_client/core/data_sources/api_client.dart';
import 'package:ermis_client/core/models/chat_session.dart';
import 'package:ermis_client/core/models/message.dart';
import 'package:ermis_client/constants/app_constants.dart';
import 'package:ermis_client/core/services/database/extensions/accounts_extension.dart';
import 'package:ermis_client/core/services/database/extensions/chat_messages_extension.dart';
import 'package:ermis_client/core/services/database/extensions/servers_extension.dart';
import 'package:ermis_client/core/services/database/extensions/unread_messages_extension.dart';
import 'package:ermis_client/core/services/database/models/local_account_info.dart';
import 'package:ermis_client/core/services/database/models/server_info.dart';
import 'package:ermis_client/core/util/message_notification.dart';
import 'package:ermis_client/core/networking/common/message_types/client_status.dart';
import 'package:ermis_client/core/util/transitions_util.dart';
import 'package:ermis_client/features/voice_call/web_rtc/voice_call_webrtc.dart';
import 'package:ermis_client/generated/l10n.dart';
import 'package:ermis_client/features/splash_screen/splash_screen.dart';
import 'package:ermis_client/mixins/event_bus_subscription_mixin.dart';
import 'package:ermis_client/theme/app_colors.dart';
import 'package:ermis_client/core/services/database/database_service.dart';
import 'package:ermis_client/core/util/notifications_util.dart';
import 'package:ermis_client/core/services/settings_json.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:sqflite/sql.dart';

import 'core/event_bus/app_event_bus.dart';
import 'core/models/file_heap.dart';
import 'core/models/message_events.dart';
import 'core/networking/user_info_manager.dart';
import 'core/util/file_utils.dart';
import 'features/chats/chat_requests_screen.dart';
import 'features/messaging/presentation/messaging_interface.dart';
import 'features/settings/options/profile_settings.dart';
import 'features/voice_call/web_rtc/incoming_voice_call_screen.dart';
import 'theme/app_theme.dart';
import 'features/chats/chats_interface.dart';
import 'features/settings/primary_settings_interface.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'core/util/dialogs_utils.dart';

import 'dart:io' show Platform;

void main() async {
  // Ensure that Flutter bindings are initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid || Platform.isIOS) {
    FlutterBackgroundService().configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onAndroidBackground,
        autoStartOnBoot: false,
        autoStart: false, // Automatically start the service when the app is launched
        isForegroundMode: true, // Keep the service running in the background
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onBackground: onIosBackground,
      ),
    );

    if (await FlutterBackgroundService().isRunning()) {
      stopBackgroundService();
    }

    startBackgroundService();
  }

  await AppConstants.initialize();
  await NotificationService.init();
  tz.initializeTimeZones();

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

  runApp(_MyApp(
    lightAppColors: AppConstants.lightAppColors,
    darkAppColors: AppConstants.darkAppColors,
    themeMode: themeData,
  ));
}

void startBackgroundService() {
  final service = FlutterBackgroundService();
  service.startService();
}

void stopBackgroundService() {
  final service = FlutterBackgroundService();
  service.invoke("stop");
}

@pragma("vm:entry-point")
void onAndroidBackground(ServiceInstance service) {
  maintainWebSocketConnection(service);
}

@pragma("vm:entry-point")
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  maintainWebSocketConnection(service);

  return true;
}

void maintainWebSocketConnection(ServiceInstance service) async {
  debugPrint("BACKGROUND SERVICE IS INITIALIZING...");
  debugPrint("BACKGROUND SERVICE IS INITIALIZING...");
  debugPrint("BACKGROUND SERVICE IS INITIALIZING...");
  debugPrint("BACKGROUND SERVICE IS INITIALIZING...");
  debugPrint("BACKGROUND SERVICE IS INITIALIZING...");
  debugPrint("BACKGROUND SERVICE IS INITIALIZING...");
  debugPrint("BACKGROUND SERVICE IS INITIALIZING...");
  debugPrint("BACKGROUND SERVICE IS INITIALIZING...");
  debugPrint("BACKGROUND SERVICE IS INITIALIZING...");
  debugPrint("BACKGROUND SERVICE IS INITIALIZING...");

  WidgetsFlutterBinding.ensureInitialized();

  service.on("stop").listen((event) {
    service.stopSelf();
    debugPrint("background process is now stopped");
  });

  service.on("start_listening_for_messages").listen((event) async {
    await AppConstants.initialize();
    await NotificationService.init();

    final settingsJson = SettingsJson();
    await settingsJson.loadSettingsJson();

    final DBConnection conn = ErmisDB.getConnection();
    ServerInfo serverInfo = await conn.getServerUrlLastUsed();

    void setupClient() async {
      try {
        await Client.instance().initialize(
          serverInfo.serverUrl,
          ServerCertificateVerification.ignore, // Since user connected once he has no issue connecting again
        );

        await Client.instance().readServerVersion();
        Client.instance().startMessageDispatcher();

        LocalAccountInfo? userInfo = await conn.getLastUsedAccount(serverInfo);
        if (userInfo == null) {
          return;
        }

        bool success = await Client.instance().attemptHashedLogin(userInfo);

        if (!success) {
          return;
        }

        await Client.instance().fetchUserInformation();
        Client.instance().commands?.setAccountStatus(ClientStatus.offline);
      } catch (e) {
        // Attempt to reinitialize client in case of failure
        Future.delayed(const Duration(seconds: 30), setupClient);
      }
    }

    setupClient();

    AppEventBus.instance.on<ConnectionResetEvent>().listen((event) {
      // Attempt to re-establish connection in case of a connection reset
      Future.delayed(const Duration(seconds: 30), setupClient);
    });

    AppEventBus.instance.on<MessageReceivedEvent>().listen((event) {
      ChatSession chatSession = event.chatSession;
      Message msg = event.message;

      DBConnection conn = ErmisDB.getConnection();

      conn.insertChatMessage(
        serverInfo: Client.instance().serverInfo!,
        message: msg,
      );

      conn.insertUnreadMessage(serverInfo, msg.chatSessionID, msg.messageID);

      // Display notification only if message does not originate from one's self
      if (msg.clientID == Client.instance().clientID) return;

      handleChatMessageNotificationBackground(chatSession, msg, settingsJson, (String text) {
        Client.instance().sendMessageToClient(text, chatSession.chatSessionIndex);
      });
    });

    AppEventBus.instance.on<VoiceCallIncomingEvent>().listen((event) {
      NotificationService.showVoiceCallNotification(
          icon: event.member.icon.profilePhoto,
          callerName: event.member.username,
          payload: jsonEncode({
            'chatSessionID': event.chatSessionID,
            'chatSessionIndex': event.chatSessionIndex,
            'member': jsonEncode(event.member.toJson()),
            'isInitiator': false,
          }),
          onAccept: () {
            // Won't get called since app will be brought from background to foreground
          });
    });

    debugPrint("BACKGROUND SERVICE INITIALIZED SUCCESSFULLY!");
    debugPrint("BACKGROUND SERVICE INITIALIZED SUCCESSFULLY!");
    debugPrint("BACKGROUND SERVICE INITIALIZED SUCCESSFULLY!");
    debugPrint("BACKGROUND SERVICE INITIALIZED SUCCESSFULLY!");
    debugPrint("BACKGROUND SERVICE INITIALIZED SUCCESSFULLY!");
    debugPrint("BACKGROUND SERVICE INITIALIZED SUCCESSFULLY!");
    debugPrint("BACKGROUND SERVICE INITIALIZED SUCCESSFULLY!");
    debugPrint("BACKGROUND SERVICE INITIALIZED SUCCESSFULLY!");
    debugPrint("BACKGROUND SERVICE INITIALIZED SUCCESSFULLY!");
    debugPrint("BACKGROUND SERVICE INITIALIZED SUCCESSFULLY!");
  });

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
        FlutterBackgroundService().invoke("start_listening_for_messages");
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
    return AppTheme(
      darkAppColors: widget.darkAppColors,
      lightAppColors: widget.lightAppColors,
      theme: widget.themeMode,
      home: const SplashScreen(),
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

  static const List<Widget> _widgetOptions = <Widget>[
    Chats(),
    ChatRequests(),
    SettingsScreen(),
    ProfileSettings()
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

    subscribe(AppEventBus.instance.on<MessageReceivedEvent>(), (event) async{
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

    subscribe(AppEventBus.instance.on<FileDownloadedEvent>(), (event) async {
      LoadedInMemoryFile file = event.file;
      String? filePath = await saveFileToDownloads(file.fileName, file.fileBytes);

      if (!mounted) return; // Probably impossible but still check just in case
      if (filePath != null) {
        showSnackBarDialog(context: context, content: S.current.downloaded_file);
        return;
      }

      showExceptionDialog(context, S.current.error_saving_file);
    });

    subscribe(AppEventBus.instance.on<VoiceCallIncomingEvent>(), (event) async {
      void pushVoiceCall() {
        pushSlideTransition(
            context,
            VoiceCallWebrtc(
              chatSessionID: event.chatSessionID,
              chatSessionIndex: event.chatSessionIndex,
              member: event.member,
              isInitiator: false,
            ));
      }

      int notificationID = await NotificationService.showVoiceCallNotification(
        icon: event.member.icon.profilePhoto,
        callerName: event.member.username,
        onAccept: pushVoiceCall,
      );

      bool? didAccept = await navigateWithFade(context, IncomingCallScreen(member: event.member));
      print(didAccept);
      print(didAccept);
      print(didAccept);
      print(didAccept);
      print(didAccept);
      print(didAccept);

      if (didAccept == true) {
        pushVoiceCall();
        NotificationService.cancelNotification(notificationID);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  NavigationDestination _buildNavItem(
    IconData activeIcon,
    IconData inactiveIcon,
    String label,
  ) {
    return NavigationDestination(
      icon: Icon(inactiveIcon),
      selectedIcon: Icon(activeIcon),
      label: label,
    );
  }

  void _onItemTapped(int newPageIndex) {
    setState(() {
      _selectedPageIndex = newPageIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    _barItems = <NavigationDestination>[
      _buildNavItem(Icons.chat, Icons.chat_outlined, S.current.chats),
      _buildNavItem(Icons.person_add_alt_1, Icons.person_add_alt_1_outlined, S.current.requests),
      _buildNavItem(Icons.settings, Icons.settings_outlined, S.current.settings),
      _buildNavItem(Icons.account_circle, Icons.account_circle_outlined, S.current.account),
    ];

    return Scaffold(
      body: PageView(
          controller: _pageController,
          onPageChanged: _onItemTapped,
          children: _widgetOptions),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Color(0xffAEADB2).withValues(alpha: 0.4),
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
            destinations: _barItems),
      ),
    );
  }
}
