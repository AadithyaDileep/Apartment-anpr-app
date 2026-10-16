import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data.dart';
import '../theme.dart';
import '../visitor_store.dart';
import '../widgets.dart';

/// Visitors — each visitor has a limited time to exit.
/// When the time is up they are deleted automatically (see visitor_store.dart).
///  • pending visitors as pass rows with a live countdown
///  • swipe right to approve · swipe left to deny
///  • history as a timeline
///  • "Add visitor" opens a bottom sheet with purpose / arrival / time-limit chips
class VisitorsScreen extends StatefulWidget {
  const VisitorsScreen({super.key});
  @override
  State<VisitorsScreen> createState() => _VisitorsScreenState();
}

class _VisitorsScreenState extends State<VisitorsScreen> {
  bool showPending = true;

  @override
  void initState() {
    super.initState();
    // start the auto-delete timer once the first frame is drawn
    WidgetsBinding.instance.addPostFrameCallback((_) => startVisitorCleanup());
  }

  String _initials(String n) {
    final w = n.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (w.isEmpty) return '?';
    if (w.length == 1) return w[0][0].toUpperCase();
    return (w[0][0] + w[1][0]).toUpperCase();
  }

  void _decide(List<String> p, String status) {
    HapticFeedback.mediumImpact();
    final expiry = p.length > pendingExpiryIdx ? p[pendingExpiryIdx] : ''; // keep the same deadline
    pending.value = pending.value.where((e) => !identical(e, p)).toList();
    past.value = [
      [p[0], p[1], 'Just now', status, expiry],
      ...past.value,
    ];
    toast(context, '${p[0]} ${status.toLowerCase()}');
  }

  Future<void> _addVisitor() async {
    final r = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: cCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => const _AddVisitorSheet(),
    );
    if (r == null || !mounted) return;
    final limit = visitDurations[r[3]] ?? visitDurations[defaultVisitDuration]!;
    final expiresAt = DateTime.now().add(limit).millisecondsSinceEpoch;
    pending.value = [
      ...pending.value,
      [r[0], r[1], r[2], '$expiresAt', r[3]],
    ];
    setState(() => showPending = true);
    toast(context, '${r[0]} added · must exit within ${r[3]}');
  }

  // ── pieces ──────────────────────────────────────────────────────────
  Widget _glow() => IgnorePointer(
        child: Container(
          width: 340,
          height: 340,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [cGold.withValues(alpha: .22), cGold.withValues(alpha: 0)]),
          ),
        ),
      );

  Widget _tab(String label, int count, bool on, VoidCallback f) => Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.selectionClick();
            f();
          },
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(label, style: TextStyle(color: on ? Colors.white : cMute, fontWeight: FontWeight.w700, fontSize: 15)),
              if (count > 0) ...[
                const SizedBox(width: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: on ? cGold : Colors.white.withValues(alpha: .10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('$count', style: TextStyle(color: on ? Colors.black : cMute, fontSize: 11, fontWeight: FontWeight.w800)),
                ),
              ],
            ]),
            const SizedBox(height: 10),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              height: 3,
              decoration: BoxDecoration(color: on ? cGold : Colors.white.withValues(alpha: .08), borderRadius: BorderRadius.circular(3)),
            ),
          ]),
        ),
      );

  Widget _avatar(String name, Color c) => Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [c.withValues(alpha: .55), c.withValues(alpha: .15)]),
          border: Border.all(color: c.withValues(alpha: .55)),
        ),
        child: Center(child: Text(_initials(name), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, letterSpacing: .5))),
      );

  Widget _roundBtn(IconData i, Color c, VoidCallback f) => Padding(
        padding: const EdgeInsets.only(left: 10),
        child: InkWell(
          onTap: f,
          customBorder: const CircleBorder(),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: c, width: 1.5), color: c.withValues(alpha: .10)),
            child: Icon(i, color: c, size: 20),
          ),
        ),
      );

  Widget _swipeBg(String text, IconData i, Color c, Alignment a) => Container(
        alignment: a,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (a == Alignment.centerLeft) Icon(i, color: c),
          if (a == Alignment.centerLeft) const SizedBox(width: 8),
          Text(text, style: TextStyle(color: c, fontWeight: FontWeight.w700)),
          if (a == Alignment.centerRight) const SizedBox(width: 8),
          if (a == Alignment.centerRight) Icon(i, color: c),
        ]),
      );

  Widget _pendingRow(List<String> p) {
    final exp = expiryOf(p, isPast: false);
    return Dismissible(
      key: ValueKey('pend|${p.join('|')}'),
      background: _swipeBg('Approve', Icons.check_circle_outline, cSage, Alignment.centerLeft),
      secondaryBackground: _swipeBg('Deny', Icons.cancel_outlined, cRed, Alignment.centerRight),
      onDismissed: (dir) => _decide(p, dir == DismissDirection.startToEnd ? 'Approved' : 'Denied'),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: .08)))),
        child: Row(children: [
          _avatar(p[0], cGold),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p[0], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 3),
              Row(children: [
                const Icon(Icons.schedule, size: 13, color: cMute),
                const SizedBox(width: 5),
                Expanded(child: Text('${p[1]} · ${p[2]}', style: muted.copyWith(fontSize: 12.5), overflow: TextOverflow.ellipsis)),
              ]),
              if (exp != null) ...[
                const SizedBox(height: 3),
                Row(children: [
                  const Icon(Icons.timer_outlined, size: 13, color: cAccent),
                  const SizedBox(width: 5),
                  _Countdown(exp, prefix: 'Must exit · '),
                ]),
              ],
            ]),
          ),
          _roundBtn(Icons.check, cSage, () => _decide(p, 'Approved')),
          _roundBtn(Icons.close, cRed, () => _decide(p, 'Denied')),
        ]),
      ),
    );
  }

  Widget _historyRow(List<String> p, {required bool last}) {
    final ok = p[3] == 'Approved';
    final col = ok ? cSage : cRed;
    final exp = expiryOf(p, isPast: true);
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SizedBox(
          width: 30,
          child: Column(children: [
            const SizedBox(height: 4),
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(shape: BoxShape.circle, color: col, boxShadow: [BoxShadow(color: col.withValues(alpha: .5), blurRadius: 10)]),
            ),
            if (!last) Expanded(child: Container(width: 2, margin: const EdgeInsets.only(top: 6), color: Colors.white.withValues(alpha: .10))),
          ]),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: last ? 0 : 22),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(p[0], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
                Text(p[3].toUpperCase(), style: TextStyle(color: col, fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
              ]),
              const SizedBox(height: 3),
              Text('${p[1]} · ${p[2]}', style: muted.copyWith(fontSize: 12.5)),
              if (exp != null) ...[
                const SizedBox(height: 3),
                Row(children: [
                  const Icon(Icons.auto_delete_outlined, size: 13, color: cAccent),
                  const SizedBox(width: 5),
                  _Countdown(exp, prefix: 'Removed in · '),
                ]),
              ],
            ]),
          ),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext c) => ListenableBuilder(
        listenable: Listenable.merge([pending, past]),
        builder: (c, _) {
          final pend = pending.value;
          final hist = past.value;
          return Stack(children: [
            Positioned(top: -120, right: -100, child: _glow()),
            SafeArea(
              child: ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 110), children: [
                const Text('COMMUNITY', style: TextStyle(color: cAccent, letterSpacing: 2.5, fontSize: 10)),
                GradText('Visitors', style: serifStyle(30), glow: true),
                const SizedBox(height: 20),
                Row(children: [
                  _tab('Pending', pend.length, showPending, () => setState(() => showPending = true)),
                  const SizedBox(width: 16),
                  _tab('History', 0, !showPending, () => setState(() => showPending = false)),
                ]),
                const SizedBox(height: 14),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  child: KeyedSubtree(
                    key: ValueKey(showPending),
                    child: showPending
                        ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            if (pend.isEmpty)
                              const Empty('No pending visitors.\nTap "Add visitor" to expect someone.')
                            else ...[
                              const Text('Swipe right to approve · swipe left to deny', style: TextStyle(color: Colors.white38, fontSize: 11)),
                              const SizedBox(height: 4),
                              for (final p in pend) _pendingRow(p),
                            ],
                          ])
                        : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            if (hist.isEmpty) const Empty('No visitor history yet'),
                            const SizedBox(height: 6),
                            for (var i = 0; i < hist.length; i++) _historyRow(hist[i], last: i == hist.length - 1),
                          ]),
                  ),
                ),
              ]),
            ),
            Positioned(
              right: 20,
              bottom: 20,
              child: FloatingActionButton.extended(
                backgroundColor: cGold,
                foregroundColor: Colors.black,
                onPressed: _addVisitor,
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text('Add visitor', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ]);
        },
      );
}

/// Live "1h 12m left" text; turns red in the last 5 minutes.
class _Countdown extends StatefulWidget {
  const _Countdown(this.expiresMs, {this.prefix = ''});
  final int expiresMs;
  final String prefix;
  @override
  State<_Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<_Countdown> {
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final left = Duration(milliseconds: widget.expiresMs - nowMs());
    final urgent = left.inMinutes < 5;
    return Text(
      '${widget.prefix}${formatLeft(left)}',
      style: TextStyle(color: urgent ? cRed : cAccent, fontSize: 12, fontWeight: FontWeight.w600),
    );
  }
}

/// Bottom sheet: name + purpose / arrival / time-limit chips.
/// Returns [name, purpose, arrival, durationLabel].
class _AddVisitorSheet extends StatefulWidget {
  const _AddVisitorSheet();
  @override
  State<_AddVisitorSheet> createState() => _AddVisitorSheetState();
}

class _AddVisitorSheetState extends State<_AddVisitorSheet> {
  static const _purposes = ['Family visit', 'Friend', 'Delivery', 'Cab / Taxi', 'Maintenance'];
  static const _arrivals = ['Arriving now', 'In 1 hour', 'This evening', 'Tomorrow'];

  final _name = TextEditingController();
  final _other = TextEditingController();
  String? _purpose = _purposes.first;
  int _arrival = 0;
  String _limit = defaultVisitDuration;
  String? _err;

  @override
  void dispose() {
    _name.dispose();
    _other.dispose();
    super.dispose();
  }

  Widget _chip(String label, bool on, VoidCallback f) => GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          f();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: on ? cGold.withValues(alpha: .18) : Colors.transparent,
            border: Border.all(color: on ? cGold : cLine),
          ),
          child: Text(label, style: TextStyle(color: on ? Colors.white : cMute, fontSize: 13, fontWeight: FontWeight.w600)),
        ),
      );

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 10),
        child: Text(t.toUpperCase(), style: const TextStyle(color: cAccent, letterSpacing: 2, fontSize: 10.5)),
      );

  void _submit() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _err = 'Please enter the visitor\'s name');
      return;
    }
    final other = _other.text.trim();
    final purpose = other.isNotEmpty ? other : (_purpose ?? 'Visitor');
    Navigator.pop(context, [name, purpose, _arrivals[_arrival], _limit]);
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 0, 24, 20 + MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              GradText('New visitor', style: serifStyle(24)),
              const SizedBox(height: 4),
              const Text('They stay in Pending until you approve.', style: muted),
              const SizedBox(height: 18),
              TextField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                onChanged: (_) {
                  if (_err != null) setState(() => _err = null);
                },
                decoration: InputDecoration(
                  labelText: 'Visitor name',
                  errorText: _err,
                  prefixIcon: const Icon(Icons.person_outline, color: cGold),
                ),
              ),
              _label('Purpose'),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final p in _purposes)
                  _chip(p, _purpose == p && _other.text.trim().isEmpty, () => setState(() {
                        _purpose = p;
                        _other.clear();
                      })),
              ]),
              const SizedBox(height: 12),
              TextField(
                controller: _other,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(labelText: 'Something else? (optional)', prefixIcon: Icon(Icons.edit_outlined, color: cMute)),
              ),
              _label('In'),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (var i = 0; i < _arrivals.length; i++) _chip(_arrivals[i], _arrival == i, () => setState(() => _arrival = i)),
              ]),
              _label('Out by'),
              Wrap(spacing: 8, runSpacing: 8, children: [
                for (final d in visitDurations.keys) _chip(d, _limit == d, () => setState(() => _limit = d)),
              ]),
              const SizedBox(height: 8),
              const Text('After this time the visitor is deleted automatically.', style: TextStyle(color: Colors.white38, fontSize: 11)),
              const SizedBox(height: 22),
              Row(children: [
                Expanded(child: GoldBtn('Cancel', () => Navigator.pop(context), outline: true, color: cMute)),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: GoldBtn('Add visitor', _submit, icon: Icons.person_add_alt_1)),
              ]),
            ]),
          ),
        ),
      );
}