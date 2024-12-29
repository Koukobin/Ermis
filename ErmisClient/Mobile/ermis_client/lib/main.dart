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

import 'package:ermis_client/constants/app_constants.dart';
import 'package:ermis_client/main_ui/splash_screen.dart';
import 'package:ermis_client/util/notifications_util.dart';
import 'package:ermis_client/util/settings_json.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'main_ui/chats/chat_requests_screen.dart';
import 'main_ui/settings/profile_settings.dart';
import 'theme/app_theme.dart';
import 'main_ui/chats/chats_interface.dart';
import 'main_ui/settings/settings_interface.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  // Ensure that Flutter bindings are initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();

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
  FlutterForegroundTask.startService(
    notificationTitle: 'App is running in the background',
      notificationText: 'Your background task is active',
      callback: () => debugPrint("Flutter foreground service callback"));

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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        debugPrint("App is paused");
        // App is moved to the background
        break;
      case AppLifecycleState.resumed:
        debugPrint("App is resumed");
        // App is moved to the foreground (resumed)
        break;
      case AppLifecycleState.detached:
        // App is being terminated
        break;
      case AppLifecycleState.inactive:
        // App is inactive (e.g., a phone call or overlay)
        break;
      case AppLifecycleState.hidden:
        debugPrint("App is hidden");
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
