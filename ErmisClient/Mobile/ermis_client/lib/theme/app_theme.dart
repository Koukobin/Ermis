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

import 'package:ermis_mobile/constants/app_constants.dart';
import 'package:ermis_mobile/generated/l10n.dart';
import 'package:ermis_mobile/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import '../core/services/locale_provider.dart';
import '../core/services/navigation_service.dart';

class AppTheme extends StatefulWidget {
  final Widget home;
  final AppColors darkAppColors;
  final AppColors lightAppColors;
  final ThemeMode theme;

  const AppTheme({
    required this.home,
    required this.darkAppColors,
    required this.lightAppColors,
    required this.theme,
    super.key,
  });

  @override
  State<AppTheme> createState() => AppThemeState();

  // Static method to access the theme changer from the context
  static AppThemeState of(BuildContext context) {
    final state = context.findAncestorStateOfType<AppThemeState>();
    if (state == null) {
      throw FlutterError(
          "$AppTheme.of() called with a context that does not contain an $AppTheme.");
    }
    return state;
  }
}

class AppThemeState extends State<AppTheme> {
  static late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.theme;
  }

  void setThemeMode(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  ThemeData buildThemeData(Brightness brightness) {
    AppColors appColors = switch (brightness) {
      Brightness.dark => widget.darkAppColors,
      Brightness.light => widget.lightAppColors,
    };

    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: appColors.primaryColor,
        brightness: brightness,
      ),
      brightness: brightness,
      extensions: [appColors],
      visualDensity: VisualDensity.adaptivePlatformDensity, // Adapts to platform
      splashFactory: InkRipple.splashFactory, // Smooth ripple
      primaryColor: appColors.primaryColor,
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: appColors.primaryColor,
        foregroundColor: appColors.secondaryColor,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: appColors.primaryColor,
          textStyle: const TextStyle(fontSize: 15),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: appColors.quaternaryColor,
        hintStyle: const TextStyle(color: Colors.grey),
        labelStyle: TextStyle(color: appColors.primaryColor),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: appColors.primaryColor),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: appColors.primaryColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: appColors.primaryColor),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: appColors.tertiaryColor.withValues(alpha: 1.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        titleTextStyle: TextStyle(
          color: appColors.inferiorColor,
          fontSize: 20,
        ),
        contentTextStyle: TextStyle(
          color: appColors.inferiorColor,
          fontSize: 16,
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: appColors.primaryColor, // Color of the blinking text cursor
        selectionColor: Colors.greenAccent.withValues(alpha: 0.5), // Color of the selected text background
        selectionHandleColor: appColors.primaryColor, // Color of the selection handles
      ),
      radioTheme: RadioThemeData(
          fillColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return appColors.primaryColor; // Active color
        }
        return appColors.quaternaryColor; // Inactive color
      })),
      checkboxTheme: CheckboxThemeData(
        checkColor: WidgetStateProperty.all(appColors.inferiorColor), // Checkmark color
        splashRadius: 20,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(appColors.secondaryColor),
          backgroundColor: WidgetStateProperty.all(appColors.primaryColor),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return appColors.primaryColor.withValues(alpha: 0.2); // Splash effect color
            }
            return null; // Default for other states
          }),
        )),
        progressIndicatorTheme:
            const ProgressIndicatorThemeData(color: Colors.grey),
        bottomSheetTheme: BottomSheetThemeData(
            backgroundColor: appColors.tertiaryColor.withValues(alpha: 1.0)),
      popupMenuTheme: PopupMenuThemeData(
        color: switch (brightness) {
          Brightness.dark => const Color.fromARGB(255, 25, 25, 25),
          Brightness.light => const Color.fromARGB(255, 210, 210, 210),
        },
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: switch (brightness) {
            Brightness.dark => const Color(0xFF333333),
            Brightness.light => const Color.fromARGB(255, 172, 172, 172),
          },
        contentTextStyle: TextStyle(
          color: switch (brightness) {
            Brightness.dark => Colors.white,
            Brightness.light => Colors.black,
          },
          fontSize: 16,
        ),
        closeIconColor: Colors.grey,
        showCloseIcon: true,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: switch (brightness) {
              Brightness.dark => Color.fromARGB(195, 10, 10, 10),
              Brightness.light => Color.fromARGB(195, 220, 220, 220),
            },
            width: 1.25,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 1,
        behavior: SnackBarBehavior.fixed,
      ),
      switchTheme: SwitchThemeData(
          trackColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) {
              return appColors.primaryColor; // Active color
            }
            return appColors.secondaryColor; // Inactive color
          }),
          thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
            return appColors.quaternaryColor; // Thumb color
          }),
        ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LocaleProvider(),
        )
      ],
      child: Consumer<LocaleProvider>(
        builder: (BuildContext context, LocaleProvider localeProvider, Widget? child) {
          return MaterialApp(
            locale: localeProvider.locale,
            supportedLocales: AppConstants.availableLanguages,
            localizationsDelegates: const [
              S.delegate,

              LatinMaterialLocalizationsDelegate(),
              AncientGreekMaterialLocalizationsDelegate(),
              LatinCupertinoLocalizationsDelegate(),
              AncientGreekCupertinoLocalizationsDelegate(),

              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            // initialRoute: '/',
            // routes: {
            //   '/': (context) => const SplashScreen(),
            //   '/main_interface': (context) => const MainInterface(),
            //   '/choose_server': (context) => const SplashScreen(),
            //   '/settings': (context) => const SettingsScreen(),
            //   '/account_settings': (context) => const AccountSettings(),
            //   '/help_settings': (context) => const HelpSettings(),
            //   '/linked_devices_settings': (context) => const LinkedDevicesScreen(),
            //   '/notification_settings': (context) => const NotificationSettings(),
            //   '/profile_settings': (context) => const ProfileSettings(),
            //   '/storage_data_settings': (context) => const StorageAndDataScreen(),
            //   '/theme_settings': (context) => const ThemeSettingsPage(),
            //   '/chat_requests_screen': (context) => const ChatRequests(),
            //   '/conversations_screen': (context) => const Chats(),
            //   '/auth_login': (context) => const LoginInterface(),
            //   '/auth_register': (context) => const CreateAccountInterface(),
            // },
            // onGenerateRoute: (RouteSettings settings) {
            //   if (settings.name == '/choose_server') {
            //     return CupertinoPageRoute(
            //       builder: (context) => const SplashScreen(),
            //     );
            //   } else if (settings.name == '/messaging_interface') {
            //     final args = settings.arguments as Map<String, dynamic>;

            //     return CupertinoPageRoute(
            //       builder: (context) => MessagingInterface(
            //         chatSessionIndex: args['chat_session_index'],
            //         chatSession: args['chatSession'],
            //       ),
            //     );
            //   }
            //   return null; // Result to default behavior
            // },
            navigatorKey: NavigationService.navigatorKey, // Set global context of Material App
            themeMode: _themeMode,
            darkTheme: buildThemeData(Brightness.dark),
            theme: buildThemeData(Brightness.light),
            home: widget.home,
          );
        },
      ),
    );
  }
}

class LatinMaterialLocalizations extends DefaultMaterialLocalizations {
  const LatinMaterialLocalizations();
}

class LatinMaterialLocalizationsDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const LatinMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'la';

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    return LatinMaterialLocalizations();
  }

  @override
  bool shouldReload(LatinMaterialLocalizationsDelegate old) => false;
}

// Ancient Greek Material Localizations
class AncientGreekMaterialLocalizations extends DefaultMaterialLocalizations {
  const AncientGreekMaterialLocalizations();
}

class AncientGreekMaterialLocalizationsDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const AncientGreekMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'grc';

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    return AncientGreekMaterialLocalizations();
  }

  @override
  bool shouldReload(AncientGreekMaterialLocalizationsDelegate old) => false;
}

// Latin Cupertino Localizations
class LatinCupertinoLocalizations extends DefaultCupertinoLocalizations {
  const LatinCupertinoLocalizations();
}

class LatinCupertinoLocalizationsDelegate extends LocalizationsDelegate<CupertinoLocalizations> {
  const LatinCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'la';

  @override
  Future<CupertinoLocalizations> load(Locale locale) async {
    return LatinCupertinoLocalizations();
  }

  @override
  bool shouldReload(LatinCupertinoLocalizationsDelegate old) => false;
}

// Ancient Greek Cupertino Localizations
class AncientGreekCupertinoLocalizations extends DefaultCupertinoLocalizations {
  const AncientGreekCupertinoLocalizations();
}

class AncientGreekCupertinoLocalizationsDelegate extends LocalizationsDelegate<CupertinoLocalizations> {
  const AncientGreekCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'grc';

  @override
  Future<CupertinoLocalizations> load(Locale locale) async {
    return AncientGreekCupertinoLocalizations();
  }

  @override
  bool shouldReload(AncientGreekCupertinoLocalizationsDelegate old) => false;
}

