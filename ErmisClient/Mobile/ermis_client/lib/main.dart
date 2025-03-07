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
import 'dart:ui';

import 'package:ermis_client/client/client.dart';
import 'package:ermis_client/client/common/chat_session.dart';
import 'package:ermis_client/client/common/message.dart';
import 'package:ermis_client/client/common/message_types/content_type.dart';
import 'package:ermis_client/constants/app_constants.dart';
import 'package:ermis_client/main_ui/splash_screen.dart';
import 'package:ermis_client/util/database_service.dart';
import 'package:ermis_client/util/notifications_util.dart';
import 'package:ermis_client/util/settings_json.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:vibration/vibration.dart';

import 'client/app_event_bus.dart';
import 'client/message_events.dart';
import 'main_ui/chats/chat_requests_screen.dart';
import 'main_ui/settings/profile_settings.dart';
import 'theme/app_theme.dart';
import 'main_ui/chats/chats_interface.dart';
import 'main_ui/settings/settings_interface.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'util/dialogs_utils.dart';

void main() async {
  // Ensure that Flutter bindings are initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();

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

  // SystemChannels.lifecycle.setMessageHandler((String? msg) async {
  //   debugPrint("Lifecycle Event: $msg");

  //   // I despite the fact strings are compared, but this is the
  //   // only way to detect the lifecycle of the application reliably.
  //   // WidgetsBindingObserver - the usual way to detect the lifecycle of a flutter application -
  //   // is absolute HOT garbage at accurately detecting the state of the app.
  //   // Consequently, I had to result to this shitty code.
  //   if (msg == 'AppLifecycleState.inactive' || msg == 'AppLifecycleState.paused') {
  //     Future.delayed(const Duration(seconds: 2), () {
  //       debugPrint("App fully closed! Starting background service...");
  //     });
  //   }

  //   if (msg == 'AppLifecycleState.detached') {
  //     FlutterBackgroundService().startService();
  //     debugPrint("App is fully detached!");
  //   }
    
  //   return null;
  // });

  // runApp(MaterialApp(home: VoiceMyApp()));
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

  service.on("sex").listen((event) async {
    await AppConstants.initialize();
    await NotificationService.init();

    final settingsJson = SettingsJson();
    await settingsJson.loadSettingsJson();

    final DBConnection conn = ErmisDB.getConnection();
    ServerInfo serverInfo = await conn.getServerUrlLastUsed();

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

    Client.instance().startMessageHandler();
    await Client.instance().fetchUserInformation();

    AppEventBus.instance.on<MessageReceivedEvent>().listen((event) {
      ChatSession chatSession = event.chatSession;

      Message msg = event.message;

      if (settingsJson.vibrationEnabled) {
        Vibration.vibrate();
      }

      if (!settingsJson.notificationsEnabled) {
        return;
      }

      if (!settingsJson.showMessagePreview) {
        NotificationService.showSimpleNotification(body: "New message!");
        return;
      }

      String body;
      switch (msg.contentType) {
        case MessageContentType.text:
          body = msg.text;
          break;
        case MessageContentType.file || MessageContentType.image:
          body = "Send file ${msg.fileName}";
          break;
      }

      NotificationService.showInstantNotification(
        icon: event.chatSession.getMembers[0].getIcon,
        body: "Message by ${msg.username}",
        contentText: body,
        contentTitle: msg.username,
        summaryText: event.chatSession.toString(),
        replyCallBack: (String text) => {
          Client.instance().sendMessageToClient(text, chatSession.chatSessionIndex)
        },
      );
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
        saveAppState("appState", "paused");
        break;
      case AppLifecycleState.resumed:
        // App is brought back to the foreground
        loadAppState("appState").then((value) {
          debugPrint("State loaded: $value");
        });
        break;
      case AppLifecycleState.detached:
        // App is being terminated
        print("i like thick booty latinas");
        FlutterBackgroundService().invoke("sex");
        saveAppState("appState", "detached");
        break;
      case AppLifecycleState.inactive:
        // App is temporarily inactive
        break;
      case AppLifecycleState.hidden:
        // App is hidden
        break;
    }
  }

  void saveAppState(String key, String value) async {
    // final prefs = await SharedPreferences.getInstance();
    // prefs.setString(key, value);
  }

  Future<String?> loadAppState(String key) async {
    return null;
  
    // final prefs = await SharedPreferences.getInstance();
    // // return prefs.getString(key);
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
      home: SplashScreen(),
    );
  }
}

// class MyTaskHandler extends TaskHandler {
//   @override
//   Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
//     print("Foreground task started at $timestamp");

//     // You can add the logic here that will run in the background
//     while (true) {
//       // Perform periodic tasks here
//       await Future.delayed(Duration(seconds: 5));
//       print("Running background task...");
//     }
//   }

//   @override
//   Future<void> onDestroy(DateTime timestamp) async {
//     print("i like sucking thick booty latinas");
//   }

//   @override
//   void onRepeatEvent(DateTime timestamp) {
//     print("repeating fucking of thick booty latinas");
//   }
// }

class MainInterface extends StatefulWidget {
  const MainInterface({super.key});

  @override
  State<MainInterface> createState() => MainInterfaceState();
}

class MainInterfaceState extends State<MainInterface> {
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  static const List<Widget> _widgetOptions = <Widget>[
    Chats(),
    ChatRequests(),
    SettingsScreen(),
    ProfileSettings()
  ];

  late List<BottomNavigationBarItem> _barItems;
  late PageController _pageController;

  int _selectedPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedPageIndex);

    AppEventBus.instance.on<ServerMessageInfoEvent>().listen((event) {
      if (!mounted) return;
      showToastDialog(event.message);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  BottomNavigationBarItem _buildNavItem(
    IconData activeIcon,
    IconData inactiveIcon,
    String label,
    int index,
  ) {
    return BottomNavigationBarItem(
      icon: _selectedPageIndex == index ? Icon(activeIcon) : Icon(inactiveIcon),
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

    _barItems = <BottomNavigationBarItem>[
      _buildNavItem(Icons.chat, Icons.chat_outlined, "Chats", 0),
      _buildNavItem(Icons.person_add_alt_1, Icons.person_add_alt_1_outlined, "Requests", 1),
      _buildNavItem(Icons.settings, Icons.settings_outlined, "Settings", 2),
      _buildNavItem(Icons.account_circle, Icons.account_circle_outlined, "Account", 3),
    ];

    return Scaffold(
      body: PageView(
          controller: _pageController,
          onPageChanged: _onItemTapped,
          children: _widgetOptions),
      bottomNavigationBar: BottomNavigationBar(
          fixedColor: appColors.primaryColor,
          backgroundColor: appColors.secondaryColor,
          unselectedItemColor: appColors.inferiorColor,
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedPageIndex,
          onTap: (int newPageIndex) {
            // Have to manually animate to next page
            _pageController.animateToPage(
              newPageIndex,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          items: _barItems),
    );
  }
}
