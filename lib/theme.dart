import 'package:flutter/material.dart';

// ── Palette: electric blue, matched to assets/splash.mp4 ────────────────
// Near-black backdrop + headlight blue glow, with lifted (not pitch-dark)
// cool-charcoal surfaces so cards and fields stay readable.
// NOTE: the names cGold / cAccent are kept so every screen keeps working;
// they now hold the BLUE values.
const cSplash = Color(0xFF000104); // video backdrop (splash letterbox)
const cBg = Color(0xFF080B10); // app background: black like the video
const cCard = Color(0xFF1A2029); // cards / bars / fields (cool charcoal)
const cTint = Color(0xFF14283F); // blue-tinted surface (was warm orange)
const cLine = Color(0xFF2C3645); // borders / dividers
const cGold = Color(0xFF4DA8FF); // PRIMARY: electric blue
const cAccent = Color(0xFF9FD0FF); // highlight: light blue glow
const cGlow = Color(0xFF9FD0FF); // same glow, named for the splash screen
const cText = Color(0xFFF4F8FC);
const cMute = Color(0xFFB3BCC8);
const cSage = Color(0xFF7EDBA0); // success / approved
const cRed = Color(0xFFFF7E82); // danger / denied / SOS

const muted = TextStyle(color: cMute, fontSize: 13);

TextStyle serifStyle(double size, {Color color = cText}) => TextStyle(
      fontFamily: 'serif',
      fontFamilyFallback: const ['Georgia', 'Times New Roman'],
      fontSize: size,
      fontWeight: FontWeight.w600,
      color: color,
    );

ThemeData buildTheme() {
  const scheme = ColorScheme.dark(
    primary: cGold,
    onPrimary: Colors.black,
    secondary: cAccent,
    onSecondary: Colors.black,
    surface: cCard,
    onSurface: cText,
    onSurfaceVariant: cMute,
    outline: cLine,
    outlineVariant: cLine,
    error: cRed,
    surfaceTint: Colors.transparent,
  );

  OutlineInputBorder border(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: c),
      );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: cBg,
    canvasColor: cBg,
    dividerColor: cLine,
    appBarTheme: const AppBarTheme(
      backgroundColor: cBg,
      foregroundColor: cText,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cCard,
      labelStyle: const TextStyle(color: cMute),
      enabledBorder: border(cLine),
      focusedBorder: border(cGold),
      errorBorder: border(cRed),
      focusedErrorBorder: border(cRed),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: cAccent),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: cGold,
      foregroundColor: Colors.black,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: cGold),
    dialogTheme: DialogThemeData(
      backgroundColor: cCard,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF26303C),
      contentTextStyle: const TextStyle(color: cText),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: cLine),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? Colors.black : cMute),
      trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? cGold : cLine),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: cCard,
      surfaceTintColor: Colors.transparent,
      indicatorColor: cGold.withValues(alpha: .20),
      labelTextStyle: WidgetStateProperty.resolveWith((s) => TextStyle(
            fontSize: 12,
            color: s.contains(WidgetState.selected) ? cGold : cMute,
          )),
    ),
  );
}