import 'package:flutter/material.dart';

import '../data.dart';
import '../session.dart';
import '../widgets.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});
  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final plate = TextEditingController();
  final model = TextEditingController();
  late final owner = TextEditingController(text: currentUser.value.name); // pre-filled, editable
  final colour = TextEditingController();
  final phone = TextEditingController();
  String type = 'SUV';

  @override
  void dispose() {
    plate.dispose();
    model.dispose();
    owner.dispose();
    colour.dispose();
    phone.dispose();
    super.dispose();
  }

  void _save() {
    final p = plate.text.trim().toUpperCase();
    if (p.isEmpty) {
      toast(context, 'Enter plate number');
      return;
    }
    if (vehicles.value.any((v) => v['plate'] == p)) {
      toast(context, 'This plate is already added');
      return;
    }
    vehicles.value = [
      ...vehicles.value,
      {
        'plate': p,
        'name': model.text.trim().isEmpty ? type : model.text.trim(),
        'owner': owner.text.trim().isEmpty ? currentUser.value.name : owner.text.trim(),
        'color': colour.text.trim().isEmpty ? '—' : colour.text.trim(),
        'phone': phone.text.trim(),
        'active': '1',
      },
    ];
    toast(context, 'Vehicle added');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext c) => SubPage('Add vehicle', [
        AppField('Plate number', ctrl: plate),
        AppField('Make & model', ctrl: model),
        AppField('Owner name', ctrl: owner),
        AppField('Colour', ctrl: colour),
        AppField('Phone (optional)', ctrl: phone, keyboard: TextInputType.phone),
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: DropdownButtonFormField<String>(
            initialValue: type,
            decoration: const InputDecoration(labelText: 'Type'),
            items: ['SUV', 'Sedan', 'Hatchback', 'Bike'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => type = v ?? type),
          ),
        ),
        GoldBtn('Save vehicle', _save, wide: true),
      ]);
}