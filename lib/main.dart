import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/add_vehicle_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/detection_history_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/emergency_sos_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'screens/more_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/register_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/vehicles_screen.dart';
import 'screens/visitors_screen.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: cCard,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const SmartGateApp());
}

class SmartGateApp extends StatelessWidget {
  const SmartGateApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'SmartGate',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: const SplashScreen(),
        routes: {
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/forgot': (_) => const ForgotPasswordScreen(),
          '/home': (_) => const MainShell(),
          '/dashboard': (_) => const DashboardScreen(),
          '/vehicles': (_) => const VehiclesScreen(),
          '/visitors': (_) => const VisitorsScreen(),
          '/more': (_) => const MoreScreen(),
          '/profile': (_) => const ProfileScreen(),
          '/edit-profile': (_) => const EditProfileScreen(),
          '/add-vehicle': (_) => const AddVehicleScreen(),
          '/history': (_) => const DetectionHistoryScreen(),
          '/sos': (_) => const EmergencySosScreen(),
          '/settings': (_) => const SettingsScreen(),
        },
      );
}