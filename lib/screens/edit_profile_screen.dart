import 'package:flutter/material.dart';

import '../session.dart';
import '../widgets.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final AppUser u = currentUser.value;
  late final TextEditingController name = TextEditingController(text: u.name);
  late final TextEditingController phone = TextEditingController(text: u.phone);
  late final TextEditingController address = TextEditingController(text: u.address);

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    address.dispose();
    super.dispose();
  }

  void _save() {
    if (name.text.trim().isEmpty) {
      toast(context, 'Name cannot be empty');
      return;
    }
    final nu = u.copy(
      name: name.text.trim(),
      phone: phone.text.trim().isEmpty ? '—' : phone.text.trim(),
      address: address.text.trim(),
    );
    final acc = accounts[u.email];
    if (acc != null) accounts[u.email] = Account(acc.password, nu);
    currentUser.value = nu;
    toast(context, 'Profile updated');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext c) => SubPage('Edit profile', [
        const Center(child: IconBadge(Icons.person, size: 72)),
        Center(child: TextButton(onPressed: () => toast(c, 'Photo picker would open'), child: const Text('Change photo'))),
        const SizedBox(height: 8),
        AppField('Full name', ctrl: name),
        AppField('Phone', ctrl: phone, keyboard: TextInputType.phone),
        AppField('Address', ctrl: address),
        GoldBtn('Save changes', _save, wide: true),
      ]);
}