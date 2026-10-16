import 'package:flutter/material.dart';

import '../session.dart';
import '../theme.dart';
import '../widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext c) => ValueListenableBuilder<AppUser>(
        valueListenable: currentUser,
        builder: (c, u, _) => SubPage('Profile', [
          const Center(child: IconBadge(Icons.person, size: 80)),
          const SizedBox(height: 14),
          Center(child: Text(u.name, style: serifStyle(26))),
          Center(child: Text(u.email, style: muted)),
          const SizedBox(height: 24),
          Tile(Icons.phone_outlined, 'Phone', u.phone),
          Tile(Icons.home_outlined, 'Address', u.address),
          const SizedBox(height: 8),
          GoldBtn('Edit profile', () => Navigator.pushNamed(c, '/edit-profile'), wide: true),
        ]),
      );
}