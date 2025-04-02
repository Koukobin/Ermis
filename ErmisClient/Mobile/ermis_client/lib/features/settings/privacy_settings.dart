import 'package:flutter/material.dart';

class PrivacySettingsPage extends StatefulWidget {
  const PrivacySettingsPage({super.key});

  @override
  State<PrivacySettingsPage> createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends State<PrivacySettingsPage> {
  bool _profileVisibility = true;
  bool _locationSharing = false;
  bool _dataCollection = true;
  bool _targetedAds = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Settings', style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.grey[900], // Dark background for modern look
      ),
      backgroundColor: Colors.grey[850], // Slightly lighter dark background
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Profile Privacy',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            _buildSettingTile(
              'Profile Visibility',
              'Control who can see your profile.',
              _profileVisibility,
              (value) {
                setState(() {
                  _profileVisibility = value;
                });
              },
            ),
            Divider(color: Colors.grey[700]),
            const SizedBox(height: 20),
            Text(
              'Location Services',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            _buildSettingTile(
              'Location Sharing',
              'Allow or disallow sharing your location.',
              _locationSharing,
              (value) {
                setState(() {
                  _locationSharing = value;
                });
              },
            ),
            Divider(color: Colors.grey[700]),
            const SizedBox(height: 20),
            Text(
              'Data & Personalization',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            _buildSettingTile(
              'Data Collection',
              'Allow or disallow data collection for personalized experiences.',
              _dataCollection,
              (value) {
                setState(() {
                  _dataCollection = value;
                });
              },
            ),
            _buildSettingTile(
              'Targeted Ads',
              'Allow or disallow personalized ads based on your data.',
              _targetedAds,
              (value) {
                setState(() {
                  _targetedAds = value;
                });
              },
            ),
            Divider(color: Colors.grey[700]),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[400])),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.blueAccent, // Modern blue accent
      ),
    );
  }
}