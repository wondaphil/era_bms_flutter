import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/app_svg_icon.dart';

import '../../features/dashboard/dashboard_page.dart';
import '../../features/bridges/bridges_page.dart';
import '../../features/culverts/culverts_page.dart';
import '../../features/reports/reports_page.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    BridgesPage(),
    CulvertsPage(),
    ReportsPage(), // your merged page
  ];

  void _onTap(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: AppSvgIcon(asset: 'assets/icons/bridge.svg'),
            label: 'Bridges',
          ),
          BottomNavigationBarItem(
            icon: AppSvgIcon(asset: 'assets/icons/culvert.svg'),
            label: 'Culverts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            label: 'Reports',
          ),
        ],
      ),
    );
  }
}