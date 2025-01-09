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
import 'dart:io';

import 'package:ermis_client/client/client.dart';
import 'package:ermis_client/constants/app_constants.dart';
import 'package:ermis_client/main_ui/splash_screen.dart';
import 'package:ermis_client/util/notifications_util.dart';
import 'package:ermis_client/util/settings_json.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

import 'client/app_event_bus.dart';
import 'client/common/chat_session.dart';
import 'client/common/message.dart';
import 'client/common/message_types/content_type.dart';
import 'client/message_events.dart';
import 'main_ui/chats/chat_requests_screen.dart';
import 'main_ui/settings/profile_settings.dart';
import 'theme/app_theme.dart';
import 'main_ui/chats/chats_interface.dart';
import 'main_ui/settings/settings_interface.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;

void fucking(ServiceInstance instance) async {
  for (;;) {
    await AppEventBus.instance.on<MessageReceivedEvent>().listen((event) {
      ChatSession chatSession = event.chatSession;

      Message msg = event.message;

      SettingsJson settingsJson = SettingsJson();
      settingsJson.loadSettingsJson();

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
          body = utf8.decode(msg.text!);
          break;
        case MessageContentType.file || MessageContentType.image:
          body = "Send file ${utf8.decode(msg.fileName!)}";
          break;
      }

      NotificationService.showInstantNotification(
        icon: chatSession.getMembers[0].getIcon,
        body: "Message by ${msg.getUsername}",
        contentText: body,
          contentTitle: msg.getUsername,
          summaryText: event.chatSession.toString(),
          chatSessionIndex:  chatSession.chatSessionIndex);
    }).asFuture();
  }
}

void main() async {
  // Ensure that Flutter bindings are initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();
  print("object");

  final address = InternetAddress("192.168.10.103");
  final port = 9090;

  UDPSocket _udpSocket = UDPSocket();
  await _udpSocket.initialize(address, port, 0);
  _udpSocket.send(0, 0, Uint8List(5));

  AudioRecorder audioRecord = AudioRecorder();
  String audioFilePath =
      '${(await getApplicationCacheDirectory()).path}/recording5.wav';
  await audioRecord.start(
    RecordConfig(encoder: AudioEncoder.wav),
    path: audioFilePath,
  );

  await Future.delayed(Duration(seconds: 3));

  await audioRecord.stop();

  File file = File(audioFilePath);
  Uint8List bytes = await file.readAsBytes();

  try {
    FlutterSoundPlayer _player = FlutterSoundPlayer();
    await _player.openPlayer();
    await _player.startPlayerFromStream(
      codec: Codec.pcm16,
      sampleRate: 44100,
      numChannels: 2,
    );
    print("IMMENSING");
    await _player.feedFromStream(bytes);
  } on Exception {
    print("exception!");
  }

  // print("now second");

  //   double calculateRMS(Uint8List audioChunk) {
  //   Int16List audioSamples = audioChunk.buffer.asInt16List();
  //   num sumOfSquares = audioSamples
  //       .map((int sample) => pow(sample, 2))
  //       .reduce((num a, num b) => a + b);
  //   return sqrt(sumOfSquares / audioSamples.length);
  // }

  // print(Uint8List.fromList([...bytes, 5]).length);
  // print(calculateRMS(Uint8List.fromList([...bytes, 5])));

  // AudioPlayer _audioPlayer = AudioPlayer();
  // await _audioPlayer.play(BytesSource(bytes));
  // _audioPlayer.onPlayerComplete.listen((event) {
  //   print('Audio playback completed');
  // });

  // Initialize the background service
  // Initialize the foreground task
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'foreground_service_channel',
      channelName: 'Foreground Service Channel',
      channelDescription: 'This channel is used for the foreground service notification.',
      channelImportance: NotificationChannelImportance.LOW,
      priority: NotificationPriority.LOW,
    ),
    iosNotificationOptions: IOSNotificationOptions(
      showNotification: true,
    ),
    foregroundTaskOptions: ForegroundTaskOptions(eventAction: ForegroundTaskEventAction.once()),
  );

  // Start the foreground task when the app runs
  await FlutterForegroundTask.startService(
      notificationTitle: 'App is running in the background',
      notificationText: 'Ermis is listening for messages in the background...',
      callback: () => print("Flutter foreground service callback"));

  // FlutterBackgroundService().configure(
  //   androidConfiguration: AndroidConfiguration(
  //     onStart: fucking,
  //     autoStartOnBoot: true,
  //     autoStart: true, // Automatically start the service when the app is launched
  //     isForegroundMode: true, // Keep the service running in the background
  //   ),
  //   iosConfiguration: IosConfiguration(),
  // );

  await NotificationService.init();
  tz.initializeTimeZones();

  final jsonSettings = SettingsJson();
  await jsonSettings.loadSettingsJson();

  ThemeMode themeData;

  if (jsonSettings.useSystemDefaultTheme) {
    themeData = ThemeMode.system;
  } else {
    if (jsonSettings.isDarkModeEnabled) {
      themeData = ThemeMode.dark;
    } else {
      themeData = ThemeMode.light;
    }
  }

  runApp(_MyApp(
    lightAppColors: lightAppColors,
    darkAppColors: darkAppColors,
    themeMode: themeData,
  ));
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
    if (kDebugMode) debugPrint("App is ${state.name}");
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
        FlutterBackgroundService().startService();
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
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  Future<String?> loadAppState(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
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

class MyTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    print("Foreground task started at $timestamp");

    // You can add the logic here that will run in the background
    while (true) {
      // Perform periodic tasks here
      await Future.delayed(Duration(seconds: 5));
      print("Running background task...");
    }
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    print("i like sucking thick booty latinas");
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    print("repeating fucking of thick booty latinas");
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
    Settings(),
    ProfileSettings()
  ];

  late List<BottomNavigationBarItem> _barItems;
  late PageController _pageController;

  int _selectedPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedPageIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  BottomNavigationBarItem _buildNavItem(IconData activeIcon, IconData inActiveIcon, String label, int index) {
    return BottomNavigationBarItem(
      icon: _selectedPageIndex == index ? Icon(activeIcon) : Icon(inActiveIcon),
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
      _buildNavItem(Icons.person_add_alt_1, Icons.person_add_alt_1_outlined,
          "Requests", 1),
      _buildNavItem(Icons.settings, Icons.settings_outlined, "Settings", 2),
      _buildNavItem(
          Icons.account_circle, Icons.account_circle_outlined, "Account", 3),
    ];

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onItemTapped,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
          fixedColor: appColors.primaryColor,
          backgroundColor: appColors.secondaryColor,
          unselectedItemColor: appColors.inferiorColor,
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedPageIndex,
          onTap: (int newPageIndex) {
            _onItemTapped(newPageIndex);

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
