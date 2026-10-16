import 'package:flutter/foundation.dart';

/// Registered vehicles: plate, name, owner, color, phone, active ('1' / '0').
final vehicles = ValueNotifier<List<Map<String, String>>>([
  {'plate': 'KL 09 AB 1234', 'name': 'Toyota Fortuner', 'owner': 'Alex Morgan', 'color': 'Pearl White', 'phone': '+91 98765 43210', 'active': '1'},
  {'plate': 'KL 08 CD 5678', 'name': 'Honda City', 'owner': 'Alex Morgan', 'color': 'Silver', 'phone': '+91 90876 54321', 'active': '1'},
]);

/// Pending visitors: [name, purpose, time]
final pending = ValueNotifier<List<List<String>>>([
  ['Rahul Menon', 'Family visit', 'Today, 6:30 PM'],
  ['Delivery Rider', 'Food delivery', 'Expected'],
]);

/// Visitor history: [name, purpose, when, status]
final past = ValueNotifier<List<List<String>>>([
  ['Anita Joseph', 'Guest', 'Yesterday', 'Approved'],
  ['Courier', 'Parcel', 'Mon', 'Denied'],
]);

/// ANPR detections: [plate, time, gate, status]
const detections = <List<String>>[
  ['KL 09 AB 1234', 'Today, 8:12 AM', 'Main Entrance', 'Allowed'],
  ['KL 08 CD 5678', 'Today, 7:05 AM', 'Main Entrance', 'Allowed'],
  ['KL 55 ZX 4821', 'Yesterday, 11:40 PM', 'Main Entrance', 'Unknown'],
  ['KL 09 AB 1234', 'Yesterday, 6:18 PM', 'Main Entrance', 'Allowed'],
];

/// Shared gate state (used by More → Gate Control and anywhere else that needs it).
final gateOpen = ValueNotifier<bool>(false);