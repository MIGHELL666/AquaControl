import 'package:flutter/material.dart';
import '../widgets/aqua_background.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/zoom_container.dart';
import 'admin_dashboard_screen.dart';
import 'supply_points_screen.dart';
import 'worker_history_table_screen.dart';

enum UserRole { admin, worker }

class AppShell extends StatefulWidget {
  final UserRole initialRole;
  final int initialTabIndex;

  const AppShell({
    super.key,
    this.initialRole = UserRole.admin,
    this.initialTabIndex = 0,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AquaBackground(
        child: AquaZoomContainer(
          child: IndexedStack(
            index: _currentIndex,
            children: [
              AdminDashboardScreen(
                onNavigateToPoints: () => _onTabSelected(1),
                onNavigateToHistory: () => _onTabSelected(2),
              ),
              const SupplyPointsScreen(),
              const WorkerHistoryTableScreen(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AquaBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}
