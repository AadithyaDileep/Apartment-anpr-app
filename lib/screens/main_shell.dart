import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';
import 'dashboard_screen.dart';
import 'more_screen.dart';
import 'vehicles_screen.dart';
import 'visitors_screen.dart';

/// Lets any screen switch the bottom tab: tab.value = 1;
final tab = ValueNotifier<int>(0);

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<int>(
        valueListenable: tab,
        builder: (c, i, _) => PopScope(
          // Back button returns to Home tab first, then exits.
          canPop: i == 0,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) tab.value = 0;
          },
          child: Scaffold(
            body: IndexedStack(index: i, children: const [DashboardScreen(), VehiclesScreen(), VisitorsScreen(), MoreScreen()]),
            bottomNavigationBar: NavigationBar(
              selectedIndex: i,
              onDestinationSelected: (v) {
                HapticFeedback.selectionClick();
                tab.value = v;
              },
              destinations: const [
                NavigationDestination(icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view, color: cGold), label: 'Home'),
                NavigationDestination(icon: Icon(Icons.directions_car_outlined), selectedIcon: Icon(Icons.directions_car, color: cGold), label: 'Vehicles'),
                NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people, color: cGold), label: 'Visitors'),
                NavigationDestination(icon: Icon(Icons.more_horiz), selectedIcon: Icon(Icons.more_horiz, color: cGold), label: 'More'),
              ],
            ),
          ),
        ),
      );
}