import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data.dart';
import '../session.dart';
import '../theme.dart';
import '../widgets.dart';
import 'main_shell.dart';

void _showGateSheet(BuildContext c) => showModalBottomSheet<void>(
      context: c,
      backgroundColor: cCard,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const _GateSheet(),
    );

/// Bottom sheet with the Open / Close controls for the main gate.
class _GateSheet extends StatefulWidget {
  const _GateSheet();
  @override
  State<_GateSheet> createState() => _GateSheetState();
}

class _GateSheetState extends State<_GateSheet> {
  bool _busy = false;

  Future<void> _send(bool open) async {
    if (_busy) return;
    if (gateOpen.value == open) {
      toast(context, open ? 'Gate is already open' : 'Gate is already closed');
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() => _busy = true);
    await Future.delayed(const Duration(seconds: 2)); 
    if (!mounted) return;
    gateOpen.value = open;
    toast(context, open ? 'Gate opened' : 'Gate closed');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: ValueListenableBuilder<bool>(
            valueListenable: gateOpen,
            builder: (c, isOpen, _) => Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                IconBadge(isOpen ? Icons.lock_open : Icons.lock_outline, color: isOpen ? cSage : cGold, size: 48),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Main Gate', style: serifStyle(22)),
                    const Text('Open / close main gate', style: muted),
                  ]),
                ),
                Pill(isOpen ? 'Open' : 'Closed', isOpen ? cSage : cGold),
              ]),
              const SizedBox(height: 22),
              if (_busy)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else ...[
                GoldBtn('Open Gate', () => _send(true), icon: Icons.lock_open, wide: true),
                const SizedBox(height: 12),
                GoldBtn('Close Gate', () => _send(false), icon: Icons.lock_outline, wide: true, outline: true),
              ],
            ]),
          ),
        ),
      );
}

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  Widget _h(String t) => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 10),
        child: Text(t.toUpperCase(), style: const TextStyle(color: cMute, letterSpacing: 2.5, fontSize: 12)),
      );

  @override
  Widget build(BuildContext c) => TabPage('Account', 'More', [
        ValueListenableBuilder<AppUser>(
          valueListenable: currentUser,
          builder: (c, u, _) => AppCard(
            onTap: () => Navigator.pushNamed(c, '/profile'),
            child: Row(children: [
              const IconBadge(Icons.person, size: 56),
              const SizedBox(width: 16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(u.name, style: serifStyle(20)),
                  Text(u.email, style: muted, overflow: TextOverflow.ellipsis),
                  Text(u.address, style: const TextStyle(color: cAccent, fontSize: 13), overflow: TextOverflow.ellipsis),
                ]),
              ),
            ]),
          ),
        ),
        _h('Account'),
        Tile(Icons.account_circle_outlined, 'Profile', 'Personal details', iconSize: 34, onTap: () => Navigator.pushNamed(c, '/profile')),
        Tile(Icons.edit_note, 'Edit Profile', 'Update information', iconSize: 34, onTap: () => Navigator.pushNamed(c, '/edit-profile')),
        _h('Security & Access'),
        Tile(Icons.directions_car_outlined, 'Gate Control', 'Open / close main gate', iconSize: 34, onTap: () => _showGateSheet(c)),
        Tile(Icons.crop_free, 'Detection History', 'ANPR log', iconSize: 34, onTap: () => Navigator.pushNamed(c, '/history')),
        Tile(Icons.warning_amber, 'Emergency SOS', 'Trigger alert', color: cRed, iconSize: 34, onTap: () => Navigator.pushNamed(c, '/sos')),
        _h('Preferences'),
        Tile(Icons.settings_outlined, 'Settings', 'Notifications & privacy', iconSize: 34, onTap: () => Navigator.pushNamed(c, '/settings')),
        const SizedBox(height: 8),
        GoldBtn('Sign Out', () {
          tab.value = 0; // so the next login starts on Home
          Navigator.pushNamedAndRemoveUntil(c, '/login', (r) => false);
        }, icon: Icons.logout, outline: true, wide: true, color: cRed),
        const SizedBox(height: 16),
        const Center(child: Text('SmartGate v1.0 · Willow Estates', style: muted)),
      ]);
}