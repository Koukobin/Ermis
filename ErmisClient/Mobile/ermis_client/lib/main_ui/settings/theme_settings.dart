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


import 'package:ermis_client/util/dialogs_utils.dart';
import 'package:ermis_client/util/settings_json.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../client/common/exceptions/EnumNotFoundException.dart';
import '../../theme/app_theme.dart';

class ThemeSettingsPage extends StatefulWidget {
  const ThemeSettingsPage({super.key});

  @override
  State<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

enum ChatBackDrop {
  monotone(name: "Default/Monotone", id: 0),
  abstract(name: "Abstract", id: 1),
  gradient(name: "Gradient", id: 2),
  custom(name: "Custom", id: 3);

  final String name;

  /// This is used to identify each chat backdrop by its id
  final int id;
  
  const ChatBackDrop({required this.name, required this.id});

  static ChatBackDrop fromId(int id) {
    try {
      return ChatBackDrop.values.firstWhere((type) => type.id == id);
    } catch (e) {
      throw EnumNotFoundException('No ChatBackDrop found for id $id');
    }
  }
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
    showSnackBarDialog(context: context, content: "Settings saved");
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat Theme Settings"),
        backgroundColor: appColors.primaryColor,
        actions: [
          IconButton(
            onPressed: _saveSettingsJson,
            icon: Icon(Icons.save),
            tooltip: "Save Settings",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Theme Mode",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SwitchListTile(
              title: Text("System Default"),
              secondary: Icon(Icons.settings,
                  color: appColors.primaryColor),
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
                  title: Text(_isDarkMode ? "Dark Mode" : "Light Mode"),
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
            SizedBox(height: 20),
            Text(
              "Chat Backdrop",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              SizedBox(height: 20),
              Text("Upload Custom Image"),
              OutlinedButton.icon(
                onPressed: () {
                  // Implement file picker or upload functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Custom image upload coming soon!')),
                  );
                },
                icon: Icon(Icons.upload_file),
                label: Text("Choose Image"),
              ),
            ] else if (_selectedBackdrop == ChatBackDrop.gradient) ...[
              SizedBox(height: 20),
              Text(
                "Select Gradient Colors",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
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
                    child: Text("Start Color"),
                  ),
                  SizedBox(width: 10),
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
                    child: Text("End Color"),
                  ),
                ],
              ),
              SizedBox(height: 20),
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
                    "Gradient Preview",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _saveSettingsJson,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text("Save Changes"),
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
        title: const Text('Pick a color!'),
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
            child: const Text('Cancel'),
            onPressed: () {
              chosenColor = null; // Unselect color
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: const Text('OK'),
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
