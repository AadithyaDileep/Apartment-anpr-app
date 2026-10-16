import 'dart:async';

import 'data.dart';

/// Visitor time limits + automatic deletion.
///
/// Every visitor added from the app gets an expiry time ("time allowed to
/// exit"). When that time passes the visitor is deleted from `pending` / `past`.
///
/// Record layout (extra field appended, old fields unchanged):
///   pending: [name, purpose, arrival, expiresAtMs, durationLabel]
///   past:    [name, purpose, when,    status,  expiresAtMs]
/// Visitors without an expiry (e.g. the demo ones in data.dart) get the default one when the app starts.
const pendingExpiryIdx = 3;
const pastExpiryIdx = 4;

/// Options shown when adding a visitor.
const visitDurations = <String, Duration>{
  '1 min (test)': Duration(minutes: 1), // quick way to see the auto-delete; remove later
  '30 min': Duration(minutes: 30),
  '1 hour': Duration(hours: 1),
  '2 hours': Duration(hours: 2),
  '4 hours': Duration(hours: 4),
  '8 hours': Duration(hours: 8),
  '24 hours': Duration(hours: 24),
};
const defaultVisitDuration = '2 hours';

int nowMs() => DateTime.now().millisecondsSinceEpoch;

/// Expiry (ms since epoch) of a visitor record, or null when it has none.
int? expiryOf(List<String> v, {required bool isPast}) {
  final i = isPast ? pastExpiryIdx : pendingExpiryIdx;
  if (v.length <= i) return null;
  return int.tryParse(v[i]);
}

/// "1h 12m left", "12m 05s left", "40s left".
String formatLeft(Duration d) {
  if (d.isNegative || d.inSeconds <= 0) return 'expired';
  final h = d.inHours, m = d.inMinutes % 60, s = d.inSeconds % 60;
  if (h > 0) return '${h}h ${m}m left';
  if (m > 0) return '${m}m ${s.toString().padLeft(2, '0')}s left';
  return '${s}s left';
}

/// Deletes every visitor whose time is up. Safe to call as often as you like.
void purgeExpiredVisitors() {
  final now = nowMs();
  bool alive(List<String> v, bool isPast) {
    final e = expiryOf(v, isPast: isPast);
    return e == null || e > now;
  }

  final p = pending.value;
  final h = past.value;
  final p2 = p.where((v) => alive(v, false)).toList();
  final h2 = h.where((v) => alive(v, true)).toList();
  if (p2.length != p.length) {
    pending.value = p2; 
  }
  if (h2.length != h.length) {
    past.value = h2; 
  }
}

/// Gives the demo visitors from data.dart (which have no time limit) a default
/// one, so every visitor in the app has a countdown and gets auto-deleted.
void _stampVisitorsWithoutExpiry() {
  final expiry = '${DateTime.now().add(visitDurations[defaultVisitDuration]!).millisecondsSinceEpoch}';
  final p = pending.value;
  if (p.any((v) => expiryOf(v, isPast: false) == null)) {
    pending.value = [
      for (final v in p)
        expiryOf(v, isPast: false) != null ? v : [v[0], v[1], v[2], expiry, defaultVisitDuration],
    ];
  }
  final h = past.value;
  if (h.any((v) => expiryOf(v, isPast: true) == null)) {
    past.value = [
      for (final v in h)
        expiryOf(v, isPast: true) != null ? v : [v[0], v[1], v[2], v[3], expiry],
    ];
  }
}

Timer? _cleanup;

/// Starts the once-per-second cleanup (only ever runs one timer).
void startVisitorCleanup() {
  if (_cleanup == null) _stampVisitorsWithoutExpiry();
  _cleanup ??= Timer.periodic(const Duration(seconds: 1), (_) => purgeExpiredVisitors());
  purgeExpiredVisitors();
}