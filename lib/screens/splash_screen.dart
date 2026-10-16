import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../theme.dart';

/// Full-screen portrait (9:16) video splash: assets/splash.mp4
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final VideoPlayerController _v = VideoPlayerController.asset('assets/splash.mp4');
  Timer? _timer;
  bool _done = false;
  bool _showText = false;

  @override
  void initState() {
    super.initState();
    _v.addListener(_onTick);
    _timer = Timer(const Duration(seconds: 9), _next); // safety net (video is ~7 s)
    _init();
  }

  Future<void> _init() async {
    try {
      await _v.initialize();
      if (!mounted) return;
      await _v.setVolume(0);
      await _v.setLooping(false);
      setState(() {});
      await _v.play();
    } catch (_) {
      // Video failed to load: show the text, then continue.
      if (!mounted) return;
      setState(() => _showText = true);
      _timer?.cancel();
      _timer = Timer(const Duration(seconds: 2), _next);
    }
  }

  void _onTick() {
    final val = _v.value;
    if (!val.isInitialized) return;
    if (!_showText && val.position >= const Duration(seconds: 3)) {
      setState(() => _showText = true);
    }
    if (val.duration > Duration.zero && val.position >= val.duration) _next();
  }

  void _next() {
    if (_done || !mounted) return;
    _done = true;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    _timer?.cancel();
    _v.removeListener(_onTick);
    _v.dispose();
    super.dispose();
  }

  Widget _background() {
    if (!_v.value.isInitialized) return const SizedBox.shrink();
    return FittedBox(
      fit: BoxFit.cover,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(width: _v.value.size.width, height: _v.value.size.height, child: VideoPlayer(_v)),
    );
  }

  /// Text filled with a colour gradient and a soft glow.
  Widget _gradText(String text, TextStyle style, List<Color> colors) => ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (r) => LinearGradient(colors: colors).createShader(r),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: style.copyWith(
            color: Colors.white,
            shadows: [Shadow(color: cGold.withValues(alpha: .6), blurRadius: 18)],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: cSplash,
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _next, // tap to skip
          child: Stack(fit: StackFit.expand, children: [
            _background(),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  // matches the theme backdrop cSplash (0xFF000104)
                  colors: [Color(0xB3000104), Colors.transparent, Colors.transparent, Color(0xCC000104)],
                  stops: [0, .35, .7, 1],
                ),
              ),
            ),
            SafeArea(
              child: Column(children: [
                const SizedBox(height: 40), // title block sits at the top, above the car
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 1600),
                  builder: (c, o, child) => Opacity(opacity: o, child: child),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    // ── Reserved space for the app symbol ──
                    // Put your logo here, e.g.  Image.asset('assets/logo.png', height: 80)
                    const SizedBox(height: 80),
                    const SizedBox(height: 12),
                    // app name: white -> light blue -> blue
                    _gradText('SMARTGATE', serifStyle(32).copyWith(letterSpacing: 7), const [Colors.white, cAccent, cGold]),
                    const SizedBox(height: 14),
                    Container(
                      width: 64,
                      height: 2,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        gradient: const LinearGradient(colors: [Colors.transparent, cAccent, cGold, Colors.transparent]),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // tagline directly below the app name
                    _gradText(
                      'Secure Access · Elevated Living',
                      const TextStyle(fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w600),
                      const [cAccent, cGold, cSage],
                    ),
                  ]),
                ),
                const Spacer(),
                AnimatedOpacity(
                  opacity: _showText ? 1 : 0,
                  duration: const Duration(milliseconds: 900),
                  // apartment name now fades in at the bottom
                  child: _gradText('WILLOW ESTATES · PRIVATE RESIDENCE', serifStyle(10).copyWith(letterSpacing: 2.5 ), const [cAccent, cGold]),
                ),
                const SizedBox(height: 72), // apartment name sits a little above the bottom edge
              ]),
            ),
          ]),
        ),
      );
}