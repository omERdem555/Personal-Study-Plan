import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/progress_card.dart';
import '../utils/helpers.dart';
import 'test_input_screen.dart';
import 'ai_analysis_screen.dart';
import 'study_plan_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeDashboard(onNavigate: _onItemTapped),
      TestInputScreen(),
      AiAnalysisScreen(),
      StudyPlanScreen(),
      ReportsScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: 'Test Gir',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'AI Analiz',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Çalışma Planı',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Raporlar',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class HomeDashboard extends StatelessWidget {
  final Function(int) onNavigate;

  const HomeDashboard({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppProvider>().user;
    final testResults = context.watch<AppProvider>().testResults;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final latestResult = testResults.isNotEmpty ? testResults.last : null;
    final progress = user.currentNet / user.targetNet;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ana Sayfa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Merhaba, ${user.name}!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            ProgressCard(
              title: 'Hedef İlerleme',
              value: '${user.currentNet.toStringAsFixed(1)} / ${user.targetNet.toStringAsFixed(1)}',
              subtitle: '${(progress * 100).toStringAsFixed(1)}% tamamlandı',
              progress: progress.clamp(0.0, 1.0),
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            if (latestResult != null) ...[
              Text(
                'Son Test Sonucu',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${latestResult.subject} - ${AppDateUtils.formatDate(latestResult.date)}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Doğru: ${latestResult.correct}'),
                          Text('Yanlış: ${latestResult.wrong}'),
                          Text('Net: ${latestResult.predictedNet.toStringAsFixed(1)}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Çalışma Süresi: ${latestResult.studyTime} dk'),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Text(
              'Hızlı İşlemler',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.edit,
                    title: 'Test Gir',
                    onTap: () => onNavigate(1),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.analytics,
                    title: 'AI Analiz',
                    onTap: () => onNavigate(2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.schedule,
                    title: 'Çalışma Planı',
                    onTap: () => onNavigate(3),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.bar_chart,
                    title: 'Raporlar',
                    onTap: () => onNavigate(4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}