import 'package:flutter/material.dart';

import '../session.dart';
import '../widgets.dart';
import 'main_shell.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final name = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final villaNo = TextEditingController();
  final villaName = TextEditingController();
  final pass = TextEditingController();
  final confirm = TextEditingController();

  @override
  void dispose() {
    for (final c in [name, email, phone, villaNo, villaName, pass, confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  void _register() {
    final e = email.text.trim().toLowerCase();
    if (name.text.trim().isEmpty || e.isEmpty) {
      toast(context, 'Enter your name and email');
      return;
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(e)) {
      toast(context, 'Enter a valid email');
      return;
    }
    if (villaNo.text.trim().isEmpty || villaName.text.trim().isEmpty) {
      toast(context, 'Enter villa number and villa name');
      return;
    }
    if (pass.text.length < 6) {
      toast(context, 'Password must be at least 6 characters');
      return;
    }
    if (pass.text != confirm.text) {
      toast(context, 'Passwords do not match');
      return;
    }
    if (accounts.containsKey(e)) {
      toast(context, 'This email is already registered');
      return;
    }
    final u = AppUser(
      name.text.trim(),
      e,
      phone.text.trim().isEmpty ? '—' : phone.text.trim(),
      'Villa ${villaNo.text.trim()}, ${villaName.text.trim()}',
    );
    accounts[e] = Account(pass.text, u);
    currentUser.value = u;
    tab.value = 0;
    toast(context, 'Account created');
    Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
  }

  @override
  Widget build(BuildContext c) => SubPage('Create account', [
        AppField('Full name', ctrl: name),
        AppField('Email', ctrl: email, keyboard: TextInputType.emailAddress),
        AppField('Phone', ctrl: phone, keyboard: TextInputType.phone),
        AppField('Villa number', ctrl: villaNo),
        AppField('Villa name', ctrl: villaName),
        AppField('Password', ctrl: pass, obscure: true),
        AppField('Confirm password', ctrl: confirm, obscure: true),
        const SizedBox(height: 8),
        GoldBtn('Register', _register, wide: true),
      ]);
}