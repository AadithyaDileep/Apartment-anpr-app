import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final email = TextEditingController();

  @override
  void dispose() {
    email.dispose();
    super.dispose();
  }

  void _send() {
    final e = email.text.trim();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(e)) {
      toast(context, 'Enter a valid email');
      return;
    }
    toast(context, 'Reset link sent to $e');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext c) => SubPage('Forgot password', [
        const Text("Enter your email and we'll send you a link to reset your password.", style: muted),
        const SizedBox(height: 20),
        AppField('Email', ctrl: email, keyboard: TextInputType.emailAddress),
        const SizedBox(height: 8),
        GoldBtn('Send reset link', _send, wide: true),
      ]);
}