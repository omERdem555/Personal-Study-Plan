import 'package:flutter/material.dart';
import 'package:study_planner_app/screens/home_dashboard.dart';
import 'package:study_planner_app/screens/test_input_screen.dart';
import 'package:study_planner_app/screens/analysis_screen.dart';
import 'package:study_planner_app/screens/recommendation_screen.dart';
import 'package:study_planner_app/screens/reports_screen.dart';
import 'package:study_planner_app/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeDashboardPlaceholder(),
    TestInputScreen(),
    AnalysisScreen(),
    RecommendationScreen(),
    ReportsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages.map((page) {
          if (page is HomeDashboardPlaceholder) {
            return HomeDashboard(
              onNavigate: _onItemTapped,
              onSettings: _openSettings,
            );
          }
          return page;
        }).toList(),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Ana Sayfa'),
          NavigationDestination(icon: Icon(Icons.edit_outlined), label: 'Test'),
          NavigationDestination(icon: Icon(Icons.analytics_outlined), label: 'Analiz'),
          NavigationDestination(icon: Icon(Icons.schedule_outlined), label: 'Plan'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), label: 'Rapor'),
        ],
      ),
    );
  }
}

class HomeDashboardPlaceholder extends StatelessWidget {
  const HomeDashboardPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
