import 'package:flutter/material.dart';

import '../data.dart';
import '../theme.dart';
import '../widgets.dart';

class VehiclesScreen extends StatelessWidget {
  const VehiclesScreen({super.key});

  void _toggleActive(Map<String, String> v) {
    vehicles.value = [
      for (final e in vehicles.value)
        identical(e, v)
            ? {...e, 'active': e['active'] == '1' ? '0' : '1'}
            : e,
    ];
  }

  Future<void> _confirmDelete(BuildContext c, Map<String, String> v) async {
    final ok = await showDialog<bool>(
      context: c,
      builder: (d) => AlertDialog(
        title: const Text('Remove vehicle?'),
        content:
            Text('${v['plate']} will no longer be recognised at the gate.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(d, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(d, true),
              child: const Text('Remove', style: TextStyle(color: cRed))),
        ],
      ),
    );
    if (ok == true) {
      vehicles.value = vehicles.value.where((e) => !identical(e, v)).toList();
    }
  }

  // Opens the edit sheet; on save, replaces this vehicle in the list.
  Future<void> _edit(BuildContext c, Map<String, String> v) async {
    final result = await showModalBottomSheet<Map<String, String>>(
      context: c,
      isScrollControlled: true,
      backgroundColor: cCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _EditVehicleSheet(v),
    );
    if (result == null) return;
    vehicles.value = [
      for (final e in vehicles.value) identical(e, v) ? {...e, ...result} : e,
    ];
    if (c.mounted) toast(c, 'Vehicle updated');
  }

  @override
  Widget build(BuildContext c) => Stack(children: [
        ValueListenableBuilder<List<Map<String, String>>>(
          valueListenable: vehicles,
          builder: (c, list, _) => TabPage(
            'Registered',
            'Vehicles',
            [
              if (list.isEmpty)
                const Empty(
                    'No vehicles registered yet.\nTap "Add Vehicle" to add your first one.'),
              for (final v in list)
                AppCard(
                  onTap: () => _toggleActive(v),
                  child: Row(children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                          color: cLine,
                          borderRadius: BorderRadius.circular(16)),
                      child: Icon(Icons.directions_car_outlined,
                          color: v['active'] == '1'
                              ? Colors.white
                              : Colors.white38, // dimmed when paused
                          size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(v['plate']!,
                                style: const TextStyle(
                                    color: cAccent,
                                    letterSpacing: 2,
                                    fontSize: 12)),
                            Text(v['name']!, style: serifStyle(18)),
                            if ((v['owner'] ?? '').isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2, bottom: 1),
                                child: Row(children: [
                                  const Icon(Icons.person_outline,
                                      size: 14, color: cAccent),
                                  const SizedBox(width: 5),
                                  Flexible(
                                    child: Text(v['owner']!,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            color: cAccent,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                ]),
                              ),
                            Text(v['color']!, style: muted),
                            if ((v['phone'] ?? '').isNotEmpty)
                              Text(v['phone']!, style: muted),
                            Row(children: [
                              Icon(Icons.circle,
                                  size: 9,
                                  color: v['active'] == '1' ? cSage : cMute),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                    v['active'] == '1'
                                        ? 'Active for ANPR · tap to pause'
                                        : 'Inactive · tap to activate',
                                    style: muted),
                              ),
                            ]),
                          ]),
                    ),
                    Column(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(
                          tooltip: 'Edit',
                          icon: const Icon(Icons.edit_outlined,
                              color: cGold, size: 20),
                          onPressed: () => _edit(c, v)),
                      IconButton(
                          tooltip: 'Remove',
                          icon: const Icon(Icons.delete_outline,
                              color: cRed, size: 20),
                          onPressed: () => _confirmDelete(c, v)),
                    ]),
                  ]),
                ),
              const SizedBox(height: 70),
            ],
            trailing: IconButton(
                icon: const Icon(Icons.history, color: cGold),
                onPressed: () => Navigator.pushNamed(c, '/history')),
          ),
        ),
        Positioned(
          right: 20,
          bottom: 20,
          child: FloatingActionButton.extended(
            backgroundColor: cGold,
            foregroundColor: Colors.black,
            onPressed: () => Navigator.pushNamed(c, '/add-vehicle'),
            icon: const Icon(Icons.add),
            label: const Text('Add Vehicle'),
          ),
        ),
      ]);
}

/// Bottom sheet form for editing a vehicle's details.
class _EditVehicleSheet extends StatefulWidget {
  final Map<String, String> v;
  const _EditVehicleSheet(this.v);
  @override
  State<_EditVehicleSheet> createState() => _EditVehicleSheetState();
}

class _EditVehicleSheetState extends State<_EditVehicleSheet> {
  late final _plate = TextEditingController(text: widget.v['plate']);
  late final _name = TextEditingController(text: widget.v['name']);
  late final _owner = TextEditingController(text: widget.v['owner'] ?? '');
  late final _color = TextEditingController(text: widget.v['color']);
  late final _phone = TextEditingController(text: widget.v['phone']);
  String? _error;

  @override
  void dispose() {
    _plate.dispose();
    _name.dispose();
    _owner.dispose();
    _color.dispose();
    _phone.dispose();
    super.dispose();
  }

  InputDecoration _dec(String label, IconData icon) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: cMute),
        prefixIcon: Icon(icon, color: cGold, size: 20),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: cLine)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: cGold, width: 1.4)),
      );

  void _save() {
    final plate = _plate.text.trim().toUpperCase();
    final name = _name.text.trim();
    if (plate.isEmpty || name.isEmpty) {
      setState(() => _error = 'Plate number and vehicle name are required');
      return;
    }
    Navigator.pop(context, {
      'plate': plate,
      'name': name,
      'owner': _owner.text.trim(),
      'color': _color.text.trim(),
      'phone': _phone.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GradText('Edit Vehicle', style: serifStyle(22)),
                const SizedBox(height: 16),
                TextField(
                    controller: _plate,
                    textCapitalization: TextCapitalization.characters,
                    decoration: _dec('Plate number', Icons.pin_outlined)),
                const SizedBox(height: 12),
                TextField(
                    controller: _name,
                    decoration:
                        _dec('Vehicle name', Icons.directions_car_outlined)),
                const SizedBox(height: 12),
                TextField(
                    controller: _owner,
                    textCapitalization: TextCapitalization.words,
                    decoration: _dec('Owner name', Icons.person_outline)),
                const SizedBox(height: 12),
                TextField(
                    controller: _color,
                    decoration: _dec('Color', Icons.palette_outlined)),
                const SizedBox(height: 12),
                TextField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    decoration: _dec('Phone', Icons.phone_outlined)),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(_error!,
                        style: const TextStyle(color: cRed, fontSize: 12)),
                  ),
                const SizedBox(height: 18),
                Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                          foregroundColor: cMute,
                          side: const BorderSide(color: cLine),
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _save,
                      style: FilledButton.styleFrom(
                          backgroundColor: cGold,
                          foregroundColor: Colors.black,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: const Text('Save',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ]),
              ]),
        ),
      );
}