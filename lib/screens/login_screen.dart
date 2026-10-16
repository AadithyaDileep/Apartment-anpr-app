import 'package:flutter/material.dart';

import '../session.dart';
import '../theme.dart';
import '../widgets.dart';
import 'main_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Demo credentials are pre-filled. Remove the text: values before release.
  final email = TextEditingController(text: 'alex@smartgate.com');
  final pass = TextEditingController(text: 'password');

  @override
  void dispose() {
    email.dispose();
    pass.dispose();
    super.dispose();
  }

  void _login() {
    FocusScope.of(context).unfocus();
    final a = accounts[email.text.trim().toLowerCase()];
    if (a == null || a.password != pass.text) {
      toast(context, 'Invalid email or password');
      return;
    }
    currentUser.value = a.user;
    tab.value = 0;
    Navigator.pushReplacementNamed(context, '/home');
  }

  /// Gradient-filled text with a soft glow: same look as the splash screen.
  Widget _gradText(String text, TextStyle style, List<Color> colors, {bool glow = true, TextAlign align = TextAlign.start}) => ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (r) => LinearGradient(colors: colors).createShader(r),
        child: Text(
          text,
          textAlign: align,
          style: style.copyWith(
            color: Colors.white,
            shadows: glow ? [Shadow(color: cGold.withValues(alpha: .55), blurRadius: 16)] : null,
          ),
        ),
      );

  /// Name block, coloured like the splash screen.
  Widget _wordmark() => Column(children: [
        _gradText('SMARTGATE', serifStyle(32).copyWith(letterSpacing: 7), const [Colors.white, cAccent, cGold]),
        const SizedBox(height: 12),
        Container(
          width: 64,
          height: 2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: const LinearGradient(colors: [Colors.transparent, cAccent, cGold, Colors.transparent]),
          ),
        ),
        const SizedBox(height: 12),
        _gradText(
          'WILLOW ESTATES · PRIVATE RESIDENCE',
          const TextStyle(fontSize: 10.5, letterSpacing: 2, fontWeight: FontWeight.w600),
          const [cAccent, cGold, cSage],
          glow: false,
          align: TextAlign.center,
        ),
      ]);

  Widget _glow() => IgnorePointer(
        child: Container(
          width: 420,
          height: 420,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [cGold.withValues(alpha: .20), cGold.withValues(alpha: 0)]),
          ),
        ),
      );

  @override
  Widget build(BuildContext c) => Scaffold(
        body: Stack(children: [
          // soft blue glow behind the name, so the top is never an empty black block
          Positioned(top: 40, left: 0, right: 0, child: Center(child: _glow())),
          SafeArea(
            // Name + form are grouped in the middle (no empty gap); scrolls when the keyboard opens.
            child: CustomScrollView(slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Spacer(flex: 2),
                    Center(child: _wordmark()),
                    const SizedBox(height: 44),
                    _gradText('Welcome back!', serifStyle(28), const [Colors.white, cAccent]),
                    const SizedBox(height: 6),
                    const Text('Sign in to manage your residence', style: TextStyle(color: cAccent, fontSize: 13)),
                    const SizedBox(height: 22),
                    AppField('Email', ctrl: email, keyboard: TextInputType.emailAddress),
                    AppField('Password', ctrl: pass, obscure: true),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(onPressed: () => Navigator.pushNamed(c, '/forgot'), child: const Text('Forgot password?')),
                    ),
                    const SizedBox(height: 4),
                    GoldBtn('Log In', _login, wide: true),
                    const SizedBox(height: 10),
                    Center(child: TextButton(onPressed: () => Navigator.pushNamed(c, '/register'), child: const Text('New here? Create account'))),
                    const Spacer(flex: 3),
                  ]),
                ),
              ),
            ]),
          ),
        ]),
      );
}