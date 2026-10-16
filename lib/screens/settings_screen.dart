import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final on = {'push': true, 'unknown': true, 'auto': false, 'bio': true};

  Widget _sw(String k, String t, String s) => SwitchListTile(
        value: on[k]!,
        title: Text(t),
        subtitle: Text(s, style: muted),
        onChanged: (v) => setState(() => on[k] = v),
      );

  @override
  Widget build(BuildContext c) => SubPage('Settings', [
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(children: [
            _sw('push', 'Push notifications', 'Detections and visitors'),
            _sw('unknown', 'Unknown vehicle alerts', 'Instant alert'),
            _sw('auto', 'Auto-open gate', 'For registered vehicles'),
            _sw('bio', 'Biometric login', 'Face or fingerprint'),
          ]),
        ),
        Tile(Icons.lock_outline, 'Change password', '', onTap: () => Navigator.pushNamed(c, '/forgot')),
        Tile(Icons.language, 'Language', 'English', onTap: () => toast(c, 'More languages coming soon')),
        Tile(Icons.privacy_tip_outlined, 'Privacy policy', '', onTap: () => toast(c, 'Privacy policy would open')),
        const Tile(Icons.info_outline, 'App version', '1.0.0'),
      ]);
}