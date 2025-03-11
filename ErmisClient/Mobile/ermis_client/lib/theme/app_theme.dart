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
import 'package:ermis_client/generated/l10n.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import '../util/locale_provider.dart';

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
      throw FlutterError("AppTheme.of() called with a context that does not contain an AppTheme.");
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
          color: widget.darkAppColors.inferiorColor,
          fontSize: 20,
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
      radioTheme: RadioThemeData(
          fillColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return widget.darkAppColors.primaryColor; // Active color
        }
        return widget.darkAppColors.quaternaryColor; // Inactive color
      })),
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
          color: const Color.fromARGB(255, 25, 25, 25),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF333333),
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        closeIconColor: Colors.grey,
        showCloseIcon: true,
        shape: RoundedRectangleBorder(
          side: const BorderSide(
              color: Color.fromARGB(195, 10, 10, 10), width: 1.25),
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 1,
        behavior: SnackBarBehavior.fixed,
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
        ),
    );
  }

  ThemeData buildLightThemeData() {
    return ThemeData(
      brightness: Brightness.light,
      extensions: [widget.lightAppColors],
      visualDensity: VisualDensity.adaptivePlatformDensity, // Adapts to platform
      splashFactory: InkRipple.splashFactory, // Smooth ripple
      primaryColor: widget.lightAppColors.primaryColor,
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: widget.lightAppColors.primaryColor,
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
        backgroundColor: widget.lightAppColors.tertiaryColor.withOpacity(1.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        titleTextStyle: TextStyle(
          color: widget.lightAppColors.inferiorColor,
          fontSize: 20,
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
      radioTheme: RadioThemeData(
          fillColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return widget.lightAppColors.primaryColor; // Active color
        }
        return widget.lightAppColors.quaternaryColor; // Inactive color
      })),
      checkboxTheme: CheckboxThemeData(
        checkColor: WidgetStateProperty.all(Colors.black), // Checkmark color
        splashRadius: 20,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(widget.lightAppColors.secondaryColor),
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
            backgroundColor: widget.lightAppColors.tertiaryColor.withOpacity(1.0)),
      popupMenuTheme: PopupMenuThemeData(
          color: const Color.fromARGB(255, 210, 210, 210),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF333333),
        contentTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 16,
        ),
        closeIconColor: Colors.grey,
        showCloseIcon: true,
        shape: RoundedRectangleBorder(
          side: const BorderSide(
              color: Color.fromARGB(195, 220, 220, 220), width: 1.25),
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 1,
        behavior: SnackBarBehavior.fixed,
      ),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return widget.lightAppColors.primaryColor; // Active color
          }
          return widget.lightAppColors.secondaryColor; // Inactive color
        }),
        thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
          return widget.lightAppColors.quaternaryColor; // Thumb color
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
            localizationsDelegates: [
              S.delegate,
              
              LatinMaterialLocalizationsDelegate(),
              AncientGreekMaterialLocalizationsDelegate(),
              LatinCupertinoLocalizationsDelegate(),
              AncientGreekCupertinoLocalizationsDelegate(),

              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            themeMode: _themeMode,
            darkTheme: buildDarkThemeData(),
            theme: buildLightThemeData(),
            home: widget.home,
          );
        },
      ),
    );
  }
}

class LatinMaterialLocalizations extends DefaultMaterialLocalizations {}

class LatinMaterialLocalizationsDelegate extends LocalizationsDelegate<MaterialLocalizations> {
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
class AncientGreekMaterialLocalizations extends DefaultMaterialLocalizations {}

class AncientGreekMaterialLocalizationsDelegate extends LocalizationsDelegate<MaterialLocalizations> {
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
class LatinCupertinoLocalizations extends DefaultCupertinoLocalizations {}

class LatinCupertinoLocalizationsDelegate extends LocalizationsDelegate<CupertinoLocalizations> {
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
class AncientGreekCupertinoLocalizations extends DefaultCupertinoLocalizations {}

class AncientGreekCupertinoLocalizationsDelegate extends LocalizationsDelegate<CupertinoLocalizations> {
  @override
  bool isSupported(Locale locale) => locale.languageCode == 'grc';

  @override
  Future<CupertinoLocalizations> load(Locale locale) async {
    return AncientGreekCupertinoLocalizations();
  }

  @override
  bool shouldReload(AncientGreekCupertinoLocalizationsDelegate old) => false;
}


class AppColors extends ThemeExtension<AppColors> {
  final Color primaryColor;
  final Color secondaryColor;
  final Color tertiaryColor;
  final Color quaternaryColor;
  final Color inferiorColor;

  const AppColors({
    required this.primaryColor,
    required this.secondaryColor,
    required this.tertiaryColor,
    required this.quaternaryColor,
    required this.inferiorColor,
  });

  @override
  AppColors copyWith({
    Color? primaryColor,
    Color? secondaryColor,
    Color? tertiaryColor,
    Color? quaternaryColor,
    Color? inferiorColor,
  }) {
    return AppColors(
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      tertiaryColor: tertiaryColor ?? this.tertiaryColor,
      quaternaryColor: quaternaryColor ?? this.quaternaryColor,
      inferiorColor: inferiorColor ?? this.inferiorColor,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      primaryColor: Color.lerp(primaryColor, other.primaryColor, t)!,
      secondaryColor: Color.lerp(secondaryColor, other.secondaryColor, t)!,
      tertiaryColor: Color.lerp(tertiaryColor, other.tertiaryColor, t)!,
      quaternaryColor: Color.lerp(quaternaryColor, other.quaternaryColor, t)!,
      inferiorColor: Color.lerp(inferiorColor, other.inferiorColor, t)!,
    );
  }
}
