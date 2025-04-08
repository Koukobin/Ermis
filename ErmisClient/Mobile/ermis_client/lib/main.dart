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
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:encrypt/encrypt.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:ermis_client/core/data_sources/api_client.dart';
import 'package:ermis_client/core/models/chat_session.dart';
import 'package:ermis_client/core/models/message.dart';
import 'package:ermis_client/client/common/message_types/content_type.dart';
import 'package:ermis_client/constants/app_constants.dart';
import 'package:ermis_client/core/util/message_notification.dart';
import 'package:ermis_client/features/authentication/domain/client_status.dart';
import 'package:ermis_client/generated/l10n.dart';
import 'package:ermis_client/features/splash_screen/splash_screen.dart';
import 'package:ermis_client/theme/app_colors.dart';
import 'package:ermis_client/core/services/database_service.dart';
import 'package:ermis_client/core/util/notifications_util.dart';
import 'package:ermis_client/core/services/settings_json.dart';
import 'package:ermis_client/web_rtc/main.dart' as MyApp;
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
// import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:http/http.dart' as http;
import 'package:vibration/vibration.dart';

import 'core/event_bus/app_event_bus.dart';
import 'core/models/message_events.dart';
import 'features/chats/chat_requests_screen.dart';
import 'features/settings/profile_settings.dart';
import 'theme/app_theme.dart';
import 'features/chats/chats_interface.dart';
import 'features/settings/settings_interface.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'core/util/dialogs_utils.dart';

import 'dart:io' show Platform;

void main() async {
  // Ensure that Flutter bindings are initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid | Platform.isIOS) {
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

  final random = Random();
  final key = encrypt.Key(Uint8List.fromList(List.generate(32, (int index) {
    return random.nextInt(192);  // Generate a 16-byte IV for AES
  })));  // 256-bit key
  final iv = IV(Uint8List.fromList(List.generate(12, (int index) {
    return random.nextInt(192);  // Generate a 16-byte IV for AES
  })));

  final encrypter = Encrypter(AES(key, mode: AESMode.gcm));  // Use CBC mode

  final Encrypted encrypted = encrypter.encryptBytes(
    ['h'.codeUnitAt(0), 'i'.codeUnitAt(0)],  // 'h' and 'i' as byte list
    iv: iv,
  );

  print('Encrypted bytes: ${encrypted.bytes}');
  print('Encrypted size: ${encrypted.bytes.length}');  // Should print the length of the encrypted data

  // Future<void> startWebRTC() async {
  //   RTCPeerConnection peerConnection = await createPeerConnection({
  //     'iceServers': [
  //       {'urls': 'stun:stun.l.google.com:19302'}
  //     ]
  //   });

  //   RTCSessionDescription offer = await peerConnection.createOffer();
  //   await peerConnection.setLocalDescription(offer);

  //   var response = await http.post(Uri.parse('http://localhost:1984/streams'),
  //       body: jsonEncode({'sdp': offer.sdp, 'type': offer.type}),
  //       headers: {'Content-Type': 'application/json'});

  //   var answer = jsonDecode(response.body);
  //   await peerConnection.setRemoteDescription(
  //       RTCSessionDescription(answer['sdp'], answer['type']));

  //   peerConnection.onTrack = (event) {
  //     // Handle incoming video/audio stream
  //   };
  // }
  // startWebRTC();

// var options = JitsiMeetConferenceOptions(
//       serverURL: "https://192.168.10.103/meet.hermis.org",
//       room: "jitsiIsAwesomeWithFlutter",
//       configOverrides: {
//         "startWithAudioMuted": false,
//         "startWithVideoMuted": false,
//         "subject" : "Jitsi with Flutter",
//       },
//       featureFlags: {
//         "unsaferoomwarning.enabled": false
//       },
//       userInfo: JitsiMeetUserInfo(
//           displayName: "Flutter user",
//           email: "user@example.com"
//       ),
//     );

//   JitsiMeet().join(options);

  // MyApp.main();
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
    Client.instance().commands.setAccountStatus(ClientStatus.offline);

    AppEventBus.instance.on<MessageReceivedEvent>().listen((event) {
      ChatSession chatSession = event.chatSession;
      Message msg = event.message;
      handleChatMessageNotificationBackground(chatSession, msg, settingsJson, (String text) {
        Client.instance().sendMessageToClient(text, chatSession.chatSessionIndex);
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

class MainInterface extends StatefulWidget {
  const MainInterface({super.key});

  @override
  State<MainInterface> createState() => MainInterfaceState();
}

class MainInterfaceState extends State<MainInterface> {
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
