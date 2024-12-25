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
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'main_ui/custom_textfield.dart';
import 'main_ui/settings/profile_settings.dart';
import 'theme/app_theme.dart';
import 'main_ui/chats/chat_interface.dart';
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
    if (jsonSettings.useDarkMode) {
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
        print("App is paused");
        // App is moved to the background
        break;
      case AppLifecycleState.resumed:
        print("App is resumed");
        // App is moved to the foreground (resumed)
        break;
      case AppLifecycleState.detached:
        // App is being terminated
        break;
      case AppLifecycleState.inactive:
        // App is inactive (e.g., a phone call or overlay)
        break;
      case AppLifecycleState.hidden:
        print("App is hidden");
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

  ThemeData buildDarkThemeData() {
    return ThemeData(
      brightness: Brightness.dark,
      extensions: [widget.darkAppColors],
      visualDensity: VisualDensity.adaptivePlatformDensity, // Adapts to platform
      splashFactory: InkRipple.splashFactory, // Smooth ripple
      primaryColor: widget.darkAppColors.primaryColor,
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: widget.darkAppColors.primaryColor,
          textStyle: const TextStyle(fontSize: 15),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: const TextStyle(color: Colors.grey),
        labelStyle: const TextStyle(color: Colors.green),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.green),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green, width: 2),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: widget.darkAppColors.tertiaryColor.withOpacity(1.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        titleTextStyle: TextStyle(
          color: widget.darkAppColors.primaryColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: TextStyle(
          color: widget.darkAppColors.inferiorColor,
          fontSize: 16,
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Colors.green, // Color of the blinking text cursor
        selectionColor: Colors.greenAccent.withOpacity(0.5), // Color of the selected text background
        selectionHandleColor: Colors.green, // Color of the selection handles
      ),
      checkboxTheme: CheckboxThemeData(
        checkColor: WidgetStateProperty.all(Colors.white), // Checkmark color
        splashRadius: 20,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(widget.darkAppColors.secondaryColor),
          backgroundColor: WidgetStateProperty.all(Colors.green),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.green.withOpacity(0.2); // Splash effect color
            }
            return null; // Default for other states
          }),
        )),
        progressIndicatorTheme:
            ProgressIndicatorThemeData(color: Colors.grey),
        bottomSheetTheme: BottomSheetThemeData(
            backgroundColor: widget.darkAppColors.tertiaryColor.withOpacity(1.0)),
      popupMenuTheme: PopupMenuThemeData(
        color: Colors.grey[900],
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color.fromARGB(195, 19, 19, 19),
        contentTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: const Color.fromARGB(195, 10, 10, 10), width: 1.25),
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 1,
          behavior: SnackBarBehavior.floating,
        ),
        switchTheme: SwitchThemeData(
          trackColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) {
              return widget.darkAppColors.primaryColor; // Active color
            }
            return widget.darkAppColors.secondaryColor; // Inactive color
          }),
          thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
            return widget.darkAppColors.quaternaryColor; // Thumb color
          }),
        ));
  }

  ThemeData buildWhiteThemeData() {
    return ThemeData(
      brightness: Brightness.light,
      extensions: [widget.lightAppColors],
      visualDensity: VisualDensity.adaptivePlatformDensity, // Adapts to platform
      splashFactory: InkRipple.splashFactory, // Smooth ripple
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.green,
          textStyle: const TextStyle(fontSize: 15),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: widget.lightAppColors.tertiaryColor),
        labelStyle: TextStyle(color: widget.lightAppColors.primaryColor),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: widget.lightAppColors.primaryColor),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: widget.lightAppColors.primaryColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: widget.lightAppColors.primaryColor),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: widget.lightAppColors.tertiaryColor.withOpacity(1.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        titleTextStyle: TextStyle(
          color: widget.lightAppColors.primaryColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: TextStyle(
          color: widget.lightAppColors.inferiorColor,
          fontSize: 16,
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Colors.green, // Color of the blinking text cursor
        selectionColor: Colors.greenAccent.withOpacity(0.5), // Color of the selected text background
        selectionHandleColor: Colors.green, // Color of the selection handles
      ),
      checkboxTheme: CheckboxThemeData(
        checkColor: WidgetStateProperty.all(Colors.white), // Checkmark color
        splashRadius: 20,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: Colors.grey),
      bottomSheetTheme: BottomSheetThemeData(
          backgroundColor:
              widget.darkAppColors.tertiaryColor.withOpacity(1.0)),
      popupMenuTheme: PopupMenuThemeData(
        color: Colors.grey[400],
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.black87,
        contentTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        behavior: SnackBarBehavior.floating,
      ),
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

  BottomNavigationBarItem _buildNavItem(IconData activeIcon, IconData inActiveIcon, String label, int index) {
    return BottomNavigationBarItem(
      icon: _selectedIndex == index ? Icon(activeIcon) : Icon(inActiveIcon),
      label: label,
    );
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
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
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
          fixedColor: appColors.primaryColor,
          backgroundColor: appColors.secondaryColor,
          unselectedItemColor: appColors.inferiorColor,
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: _barItems),
    );
  }
}
