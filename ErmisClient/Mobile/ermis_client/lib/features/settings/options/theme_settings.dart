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

import 'package:ermis_client/enums/chat_back_drop_enum.dart';
import 'package:ermis_client/generated/l10n.dart';
import 'package:ermis_client/theme/app_colors.dart';
import 'package:ermis_client/core/util/dialogs_utils.dart';
import 'package:ermis_client/core/services/settings_json.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../../theme/app_theme.dart';

class ThemeSettingsPage extends StatefulWidget {
  const ThemeSettingsPage({super.key});

  @override
  State<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage> {
  final SettingsJson _settingsJson = SettingsJson();

  bool _isDarkMode = false;
  bool _useSystemDefault = false;
  ChatBackDrop _selectedBackdrop = ChatBackDrop.abstract;
  List<Color> _gradientColors = [Colors.red, Colors.green];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    if (_settingsJson.isJsonNotLoaded) await _settingsJson.loadSettingsJson();
    setState(() {
      _isDarkMode = _settingsJson.isDarkModeEnabled;
      _useSystemDefault = _settingsJson.useSystemDefaultTheme;
      _selectedBackdrop = _settingsJson.chatsBackDrop;
      _gradientColors = _settingsJson.gradientColors;
    });
  }

  void _saveSettingsJson() async {
    _settingsJson.saveSettingsJson();
    showSnackBarDialog(context: context, content: S.current.settings_saved);
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.chat_theme_settings),
        backgroundColor: appColors.primaryColor,
        actions: [
          IconButton(
            onPressed: _saveSettingsJson,
            icon: const Icon(Icons.save),
            tooltip: S.current.settings_save,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.current.theme_mode,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SwitchListTile(
              title: Text(S.current.theme_system_default),
              secondary: Icon(Icons.settings, color: appColors.primaryColor),
              value: _useSystemDefault,
              onChanged: (bool value) {
                setState(() {
                  _useSystemDefault = value;
                });
                _settingsJson.setUseSystemDefaultTheme(_useSystemDefault);

                if (_useSystemDefault) {
                  AppTheme.of(context).setThemeMode(ThemeMode.system);
                  return;
                }

                AppTheme.of(context).setThemeMode(_isDarkMode ? ThemeMode.dark : ThemeMode.light);
              },
            ),
            Stack(
              children: [
                SwitchListTile(
                  title: Text(_isDarkMode ? S.current.theme_dark : S.current.theme_light),
                  secondary: Icon(
                      _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      color: Theme.of(context).primaryColor),
                  value: _isDarkMode,
                  onChanged: (bool value) {
                    if (_useSystemDefault) {
                      return;
                    }

                    setState(() {
                      _isDarkMode = value;
                    });

                    _settingsJson.setDarkMode(_isDarkMode);
                    AppTheme.of(context).setThemeMode(
                        _isDarkMode ? ThemeMode.dark : ThemeMode.light);
                  },
                ),
                if (_useSystemDefault)
                  Positioned.fill(
                    child: Container(
                        color: Colors.white70.withOpacity(0.3), // Semi-transparent overlay
                        child: null),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              S.current.chat_backdrop,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            DropdownButtonFormField<ChatBackDrop>(
              value: _selectedBackdrop,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: ChatBackDrop.values
                  .map<DropdownMenuItem<ChatBackDrop>>((ChatBackDrop backdrop) {
                return DropdownMenuItem<ChatBackDrop>(
                  value: backdrop,
                  child: Text(backdrop
                      .name),
                );
              }).toList(),
              onChanged: (ChatBackDrop? value) {
                setState(() {
                  _selectedBackdrop = value!;
                });
                _settingsJson.setChatBackDrop(_selectedBackdrop.id);
              },
            ),
            if (_selectedBackdrop == ChatBackDrop.custom) ...[
              const SizedBox(height: 20),
              Text(S.current.chat_backdrop_upload_custom),
              OutlinedButton.icon(
                onPressed: () {
                  // Implement file picker or upload functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(S.current.chat_backdrop_upload_coming_soon)),
                  );
                },
                icon: const Icon(Icons.upload_file),
                label: Text(S.current.chat_backdrop_choose_image),
              ),
            ] else if (_selectedBackdrop == ChatBackDrop.gradient) ...[
              const SizedBox(height: 20),
              Text(
                S.current.chat_backdrop_select_gradient,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      Color? chosenColor = await showColorPickerDialog();
                      if (chosenColor == null) {
                        return;
                      }

                      List<Color> newGradientColors = [chosenColor ,_gradientColors[1]];
                      setState(() {
                        _gradientColors = newGradientColors;
                      });

                      _settingsJson.setGradientColors(_gradientColors);
                    },
                    child: Text(S.current.chat_backdrop_gradient_start_color),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () async {
                      Color? chosenColor = await showColorPickerDialog();
                      if (chosenColor == null) {
                        return;
                      }

                      List<Color> newGradientColors = [_gradientColors[0], chosenColor];
                      setState(() {
                        _gradientColors = newGradientColors;
                      });

                      _settingsJson.setGradientColors(_gradientColors);
                    },
                    child: Text(S.current.chat_backdrop_gradient_end_color),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _gradientColors,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Text(
                    S.current.chat_backdrop_gradient_preview,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _saveSettingsJson,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(S.current.settings_save),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<Color?> showColorPickerDialog() async {
    Color? chosenColor;
    await showDialog(
      builder: (context) => AlertDialog(
        title: Text(S.current.chat_backdrop_color_pick),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: Colors.red,
            colorPickerWidth: 250,
            onColorChanged: (color) {
              chosenColor = color;
            },
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            child: Text(S.current.cancel),
            onPressed: () {
              chosenColor = null; // Unselect color
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: Text(S.current.ok),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      context: context,
    );

    return chosenColor;
  }
}
