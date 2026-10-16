import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';
import '../widgets.dart';

class EmergencySosScreen extends StatelessWidget {
  const EmergencySosScreen({super.key});

  @override
  Widget build(BuildContext c) => SubPage('Emergency SOS', [
        const Text('Press and hold to alert security and your emergency contacts with your location.', textAlign: TextAlign.center, style: muted),
        const SizedBox(height: 36),
        Center(
          child: GestureDetector(
            onTap: () => toast(c, 'Hold to send SOS'),
            onLongPress: () {
              HapticFeedback.heavyImpact();
              toast(c, 'SOS alert sent'); 
            },
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFC0392B),
                boxShadow: [BoxShadow(color: cRed.withValues(alpha: .35), blurRadius: 40, spreadRadius: 14)],
              ),
              child: Center(child: Text('SOS', style: serifStyle(44))),
            ),
          ),
        ),
        const SizedBox(height: 50),
        const Tile(Icons.shield, 'Security desk', 'Notified instantly', trailing: Pill('On', cSage)),
        const Tile(Icons.family_restroom, 'Family contacts', '2 people', trailing: Pill('On', cSage)),
        Tile(Icons.call, 'Call emergency services', '112', color: cRed, onTap: () => toast(c, 'Dialer would open here')),
      ]);
}