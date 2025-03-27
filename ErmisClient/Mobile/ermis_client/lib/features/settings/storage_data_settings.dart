/* Copyright (C) 2025 Ilias Koukovinis <ilias.koukovinis@gmail.com>
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

import 'package:flutter/material.dart';

class StorageAndDataScreen extends StatefulWidget {
  const StorageAndDataScreen({super.key});

  @override
  State<StorageAndDataScreen> createState() => _StorageAndDataScreenState();
}

class _StorageAndDataScreenState extends State<StorageAndDataScreen> {
  bool useLessDataForCalls = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Storage and Data")),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.storage),
            title: Text("Manage Storage"),
            subtitle: Text("1.2 GB used"),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.network_check),
            title: Text("Network Usage"),
            subtitle: Text("200 MB sent • 1.5 GB received"),
            onTap: () {},
          ),
          Divider(),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Media Auto-Download", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            title: Text("When using mobile data"),
            subtitle: Text("Photos"),
            onTap: () {
              a(title: "When using mobile data", tiles: [
                RadioListTile(title: Text("balls"),
                    value: "value", groupValue: "groupValue", onChanged: (e) {})
              ]);
            },
          ),
          ListTile(
            title: Text("When connected on Wi-Fi"),
            subtitle: Text("All media"),
            onTap: () {},
          ),
          ListTile(
            title: Text("When roaming"),
            subtitle: Text("No media"),
            onTap: () {},
          ),
          Divider(),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Call Settings", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          SwitchListTile(
            title: Text("Use less data for calls"),
            value: useLessDataForCalls,
            onChanged: (bool value) {
              setState(() {
                useLessDataForCalls = value;
              });
            },
          ),
        ],
      ),
    );
  }

  void a({required String title, required List<RadioListTile> tiles}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: tiles
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Cancel
              child: const Text("Cancel", style: TextStyle(fontSize: 18)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Confirm
              child: const Text("OK", style: TextStyle(fontSize: 18)),
            ),
          ],
        );
      },
    );
  }
}