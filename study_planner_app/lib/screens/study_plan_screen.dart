import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/study_plan.dart';
import '../providers/app_provider.dart';
import '../screens/settings_screen.dart';
import '../services/api_service.dart';
import '../widgets/custom_button.dart';
import '../utils/helpers.dart';

class StudyPlanScreen extends StatefulWidget {
  const StudyPlanScreen({super.key});

  @override
  State<StudyPlanScreen> createState() => _StudyPlanScreenState();
}

class _StudyPlanScreenState extends State<StudyPlanScreen> {
  bool _isLoading = false;
  StudyPlan? _currentPlan;

  @override
  void initState() {
    super.initState();
    _loadLatestPlan();
  }

  void _loadLatestPlan() {
    final plans = context.read<AppProvider>().studyPlans;
    if (plans.isNotEmpty) {
      setState(() => _currentPlan = plans.last);
    }
  }

  Future<void> _generatePlan() async {
    setState(() => _isLoading = true);

    try {
      final user = context.read<AppProvider>().user;
      if (user == null) return;

      final recent = context.read<AppProvider>().latestResult;
      final result = await ApiService.getPlan(
        subject: recent?.subject ?? user.targetSubject,
        totalQuestions: recent?.totalQuestions ?? 40,
        correct: recent?.correct ?? 25,
        wrong: recent?.wrong ?? 15,
        currentNet: recent?.actualNet ?? user.currentNet,
        targetNet: user.targetNet,
      );

      final plan = StudyPlan(
        subject: user.targetSubject,
        studyTime: result['study_time'],
        predictedNet: result['predicted_net'],
        date: DateTime.now(),
      );

      await context.read<AppProvider>().addStudyPlan(plan);
      setState(() => _currentPlan = plan);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yeni çalışma planı oluşturuldu')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Plan oluşturma hatası: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppProvider>().user;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Çalışma Planı'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: _currentPlan == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.schedule,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz çalışma planı yok',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'AI ile kişiselleştirilmiş plan oluşturun',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Plan Oluştur',
                    isLoading: _isLoading,
                    onPressed: _generatePlan,
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Günlük Çalışma Planınız',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 4,
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _currentPlan!.subject,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'AI Önerisi',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onPrimary,
                                        fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _PlanItem(
                            icon: Icons.access_time,
                            title: 'Önerilen Çalışma Süresi',
                            value: '${_currentPlan!.studyTime} dakika',
                            color: Colors.blue,
                          ),
                          const SizedBox(height: 12),
                          _PlanItem(
                            icon: Icons.trending_up,
                            title: 'Tahmini Net Artışı',
                            value: _currentPlan!.predictedNet.toStringAsFixed(1),
                            color: Colors.green,
                          ),
                          const SizedBox(height: 12),
                          _PlanItem(
                            icon: Icons.calendar_today,
                            title: 'Plan Tarihi',
                            value: AppDateUtils.formatDate(_currentPlan!.date),
                            color: Colors.orange,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Plan Detayları',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _PlanDetailCard(
                    title: 'Hedef Analizi',
                    content: 'Mevcut netiniz ${_currentPlan!.predictedNet > user.currentNet ? "artış" : "koruma"} göstermektedir.',
                    icon: Icons.flag,
                  ),
                  const SizedBox(height: 12),
                  _PlanDetailCard(
                    title: 'Zaman Yönetimi',
                    content: '${_currentPlan!.studyTime} dakikalık çalışma süresi, verimli öğrenme için optimize edilmiştir.',
                    icon: Icons.timer,
                  ),
                  const SizedBox(height: 12),
                  _PlanDetailCard(
                    title: 'İlerleme Takibi',
                    content: 'Düzenli test girişleri yaparak ilerlemenizi takip edin.',
                    icon: Icons.track_changes,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Yeni Plan Oluştur',
                          isLoading: _isLoading,
                          onPressed: _generatePlan,
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

class _PlanItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _PlanItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlanDetailCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;

  const _PlanDetailCard({
    required this.title,
    required this.content,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}