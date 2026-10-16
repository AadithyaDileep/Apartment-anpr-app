import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data.dart';
import '../theme.dart';
import '../widgets.dart';

// Accent comes from theme.dart (cGold / cAccent = electric blue).
const _accent = cGold;
const _accentSoft = cAccent;
const _onAccent = Color(0xFF04121F);

/// Card-free dashboard:
///  • a glowing gate "orb" you tap to open / close (pick Entry or Exit above it)
///  • a borderless stat strip with a today's-traffic bar
///  • a vertical timeline for recent detections (swipe left to clear)
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))..repeat(reverse: true);

  static const _gateNames = ['Entry Gate', 'Exit Gate'];
  final List<bool> _open = [false, false];
  final List<bool> _busy = [false, false];
  int _sel = 0; // which gate the orb controls
  final Set<String> _cleared = {}; // swiped-away detections

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'GOOD MORNING';
    if (h < 17) return 'GOOD AFTERNOON';
    return 'GOOD EVENING';
  }

  Future<void> _toggleGate(int i) async {
    if (_busy[i]) return;
    HapticFeedback.mediumImpact();
    setState(() => _busy[i] = true);
    await Future.delayed(const Duration(seconds: 2)); 
    if (!mounted) return;
    setState(() {
      _open[i] = !_open[i];
      _busy[i] = false;
    });
    HapticFeedback.lightImpact();
    toast(context, '${_gateNames[i]} ${_open[i] ? 'opened' : 'closed'}');
  }

  // Fade + rise entrance.
  Widget _in(int i, Widget w) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Duration(milliseconds: 520 + i * 130),
        curve: Curves.easeOutCubic,
        builder: (c, v, child) => Opacity(opacity: v, child: Transform.translate(offset: Offset(0, (1 - v) * 24), child: child)),
        child: w,
      );

  Widget _glow(Color color, double size, double alpha) => IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [color.withValues(alpha: alpha), color.withValues(alpha: 0)]),
          ),
        ),
      );

  // ───────────────────────── Gate orb ─────────────────────────
  Widget _gateChip(int i) {
    final on = _sel == i;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _sel = i);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: on ? _accent.withValues(alpha: .18) : Colors.transparent,
          border: Border.all(color: on ? _accent : Colors.white24),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 7, height: 7, decoration: BoxDecoration(shape: BoxShape.circle, color: _open[i] ? cSage : cRed)),
          const SizedBox(width: 8),
          Text(_gateNames[i],
              style: TextStyle(color: on ? Colors.white : Colors.white60, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: .5)),
        ]),
      ),
    );
  }

  Widget _orb() {
    final open = _open[_sel];
    final busy = _busy[_sel];
    final col = open ? cSage : _accent;
    return GestureDetector(
      onTap: busy ? null : () => _toggleGate(_sel),
      child: SizedBox(
        width: 260,
        height: 260,
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (c, _) {
            final p = _pulse.value;
            Widget ring(double size, double a) => Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: col.withValues(alpha: a), width: 1.4),
                    gradient: RadialGradient(colors: [col.withValues(alpha: a * .30), col.withValues(alpha: 0)]),
                  ),
                );
            return Stack(alignment: Alignment.center, children: [
              ring(248 + 10 * p, .16 - .08 * p),
              ring(204 + 6 * p, .26),
              ring(164, .40),
              Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [col, col.withValues(alpha: .55)]),
                  boxShadow: [BoxShadow(color: col.withValues(alpha: .45), blurRadius: 32, spreadRadius: 2 + 4 * p)],
                ),
                child: busy
                    ? const Center(child: SizedBox(width: 34, height: 34, child: CircularProgressIndicator(strokeWidth: 3, color: _onAccent)))
                    : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(open ? Icons.lock_open_rounded : Icons.lock_outline_rounded, size: 38, color: _onAccent),
                        const SizedBox(height: 6),
                        Text(open ? 'CLOSE' : 'OPEN',
                            style: const TextStyle(color: _onAccent, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 2)),
                      ]),
              ),
            ]);
          },
        ),
      ),
    );
  }

  Widget _gateHub() {
    final open = _open[_sel];
    final busy = _busy[_sel];
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [_gateChip(0), _gateChip(1)]),
      const SizedBox(height: 6),
      _orb(),
      Text(open ? 'GATE OPEN' : 'GATE CLOSED',
          style: TextStyle(color: open ? cSage : Colors.white, fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 3.5)),
      const SizedBox(height: 6),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 7, height: 7, decoration: const BoxDecoration(shape: BoxShape.circle, color: cSage)),
        const SizedBox(width: 6),
        Text('${_gateNames[_sel]} online · Camera online', style: const TextStyle(color: Colors.white60, fontSize: 12)),
      ]),
      const SizedBox(height: 4),
      Text(busy ? 'Working…' : (open ? 'Tap the orb to close' : 'Tap the orb to open'), style: const TextStyle(color: Colors.white38, fontSize: 11)),
    ]);
  }

  // ─────────────────── Stat strip + traffic bar ───────────────────
  Widget _stat(IconData icon, String label, int value, Color color) => Expanded(
        child: Column(children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text('$value', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54, fontSize: 10.5, height: 1.2)),
        ]),
      );

  Widget _vDivider() => Container(width: 1, height: 58, color: Colors.white.withValues(alpha: .10));

  Widget _trafficBar(int ok, int bad) => Column(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 8,
            child: (ok + bad) == 0
                ? Container(color: Colors.white12)
                : Row(children: [
                    if (ok > 0) Expanded(flex: ok, child: Container(color: cSage)),
                    if (ok > 0 && bad > 0) const SizedBox(width: 2),
                    if (bad > 0) Expanded(flex: bad, child: Container(color: cRed)),
                  ]),
          ),
        ),
        const SizedBox(height: 6),
        Row(children: [
          Text('$ok allowed', style: const TextStyle(color: cSage, fontSize: 11, fontWeight: FontWeight.w600)),
          const Spacer(),
          Text('$bad denied', style: const TextStyle(color: cRed, fontSize: 11, fontWeight: FontWeight.w600)),
        ]),
      ]);

  Widget _statStrip(int vehiclesCount, int ok, int bad) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.symmetric(horizontal: BorderSide(color: Colors.white.withValues(alpha: .10))),
        ),
        child: Column(children: [
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            _stat(Icons.directions_car_outlined, 'Registered\nVehicles', vehiclesCount, Colors.white),
            _vDivider(),
            _stat(Icons.document_scanner_outlined, "Today's\nEntries", ok, cSage),
            _vDivider(),
            _stat(Icons.car_crash_outlined, "Today's\nDenied", bad, cRed),
            _vDivider(),
            _stat(Icons.fence, 'Active\nGates', 2, _accentSoft),
          ]),
          const SizedBox(height: 16),
          _trafficBar(ok, bad),
        ]),
      );

  // ───────────────────── Detection timeline ─────────────────────
  Widget _section(String title, {String action = '', VoidCallback? onTap, String hint = ''}) => Padding(
        padding: const EdgeInsets.only(top: 26, bottom: 14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              GradText(title, style: serifStyle(18)),
              if (hint.isNotEmpty) Text(hint, style: const TextStyle(color: Colors.white38, fontSize: 11)),
            ]),
          ),
          if (action.isNotEmpty)
            GestureDetector(onTap: onTap, child: Text(action, style: const TextStyle(color: _accent, fontSize: 13, fontWeight: FontWeight.w600))),
        ]),
      );

  Widget _detection(List<String> d, {required bool last}) {
    final ok = d[3] == 'Allowed';
    final col = ok ? cSage : cRed;
    final time = d[1].contains(', ') ? d[1].split(', ').last : d[1];
    final key = '${d[0]}|${d[1]}';
    return Dismissible(
      key: ValueKey(key),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        HapticFeedback.selectionClick();
        setState(() => _cleared.add(key));
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 12),
        child: const Text('Clear', style: TextStyle(color: cRed, fontWeight: FontWeight.w700)),
      ),
      child: IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SizedBox(
            width: 30,
            child: Column(children: [
              const SizedBox(height: 4),
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: col,
                  boxShadow: [BoxShadow(color: col.withValues(alpha: .55), blurRadius: 10, spreadRadius: 1)],
                ),
              ),
              if (!last) Expanded(child: Container(width: 2, margin: const EdgeInsets.only(top: 6), color: Colors.white.withValues(alpha: .10))),
            ]),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: last ? 0 : 22),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(d[0], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: .6)),
                  const SizedBox(width: 10),
                  Text(ok ? 'AUTHORIZED' : 'DENIED', style: TextStyle(color: col, fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
                  const Spacer(),
                  Text(time, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                ]),
                const SizedBox(height: 3),
                Row(children: [
                  const Icon(Icons.directions_car_outlined, size: 14, color: Colors.white38),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${d[2]} · ${ok ? 'Plate recognised, gate opened' : 'Plate not registered, entry denied'}',
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ]),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext c) => ListenableBuilder(
        listenable: Listenable.merge([vehicles]),
        builder: (c, _) {
          final entries = detections.where((d) => d[3] == 'Allowed').length;
          final denied = detections.length - entries;
          final shown = detections.where((d) => !_cleared.contains('${d[0]}|${d[1]}')).take(4).toList();

          return Stack(children: [
            Positioned(top: 60, left: 0, right: 0, child: Center(child: _glow(_accent, 420, .20))),
            Positioned(bottom: -140, right: -90, child: _glow(_accentSoft, 320, .10)),
            SafeArea(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _in(
                    0,
                    Row(children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(_greeting(), style: const TextStyle(color: cAccent, letterSpacing: 2.5, fontSize: 10)),
                          GradText('Willow Estates', style: serifStyle(26), glow: true),
                        ]),
                      ),
                      GestureDetector(
                        onTap: () => toast(c, 'No new notifications'),
                        child: Stack(clipBehavior: Clip.none, children: [
                          const Icon(Icons.notifications_none_rounded, size: 28, color: Colors.white),
                          Positioned(
                            right: 1,
                            top: 0,
                            child: Container(width: 9, height: 9, decoration: const BoxDecoration(color: cRed, shape: BoxShape.circle)),
                          ),
                        ]),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 6),
                  _in(1, Center(child: _gateHub())),
                  const SizedBox(height: 14),
                  _in(2, _statStrip(vehicles.value.length, entries, denied)),
                  _in(3, _section('Recent Detections', action: 'View all', hint: 'Swipe left to clear', onTap: () => Navigator.pushNamed(c, '/history'))),
                  if (shown.isEmpty) const Empty('No new detections'),
                  for (var i = 0; i < shown.length; i++) _in(4 + i, _detection(shown[i], last: i == shown.length - 1)),
                ]),
              ),
            ),
          ]);
        },
      );
}