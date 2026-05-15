import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../screens/settings_screen.dart';
import '../utils/helpers.dart';

class AiAnalysisScreen extends StatelessWidget {
  const AiAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final testResults = context.watch<AppProvider>().testResults;
    final user = context.watch<AppProvider>().user;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Calculate statistics
    final totalTests = testResults.length;
    final averageNet = totalTests > 0
        ? testResults.map((r) => r.actualNet).reduce((a, b) => a + b) / totalTests
        : 0.0;
    final averageAccuracy = totalTests > 0
        ? testResults.map((r) => MathUtils.calculateAccuracy(r.correct, r.totalQuestions)).reduce((a, b) => a + b) / totalTests
        : 0.0;

    // Group by subject
    final subjectStats = <String, List<double>>{};
    for (final result in testResults) {
      if (!subjectStats.containsKey(result.subject)) {
        subjectStats[result.subject] = [];
      }
      subjectStats[result.subject]!.add(result.actualNet);
    }

    final subjectAverages = subjectStats.map((subject, nets) {
      final avg = nets.reduce((a, b) => a + b) / nets.length;
      return MapEntry(subject, avg);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Analiz'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: testResults.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.analytics_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Henüz test sonucu yok',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Test sonuçları girerek analizlerinizi görün',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
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
                    'Performans Özeti',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _AnalysisCard(
                    title: 'Toplam Test',
                    value: '$totalTests',
                    subtitle: 'Tamamlanan test sayısı',
                    icon: Icons.assignment,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _AnalysisCard(
                    title: 'Ortalama Net',
                    value: averageNet.toStringAsFixed(1),
                    subtitle: 'Tüm testlerdeki ortalama',
                    icon: Icons.trending_up,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 12),
                  _AnalysisCard(
                    title: 'Başarı Oranı',
                    value: '${averageAccuracy.toStringAsFixed(1)}%',
                    subtitle: 'Doğru cevap yüzdesi',
                    icon: Icons.percent,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Ders Bazlı Analiz',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...subjectAverages.entries.map((entry) {
                    final progress = (entry.value / user.targetNet).clamp(0.0, 1.0);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _SubjectAnalysisCard(
                        subject: entry.key,
                        averageNet: entry.value,
                        progress: progress,
                        targetNet: user.targetNet,
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  Text(
                    'AI Önerileri',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _RecommendationCard(
                    title: 'Zayıf Dersler',
                    recommendations: _getWeakSubjects(subjectAverages, user.targetNet),
                    icon: Icons.warning,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 12),
                  _RecommendationCard(
                    title: 'Gelişim Alanları',
                    recommendations: _getImprovementAreas(testResults),
                    icon: Icons.lightbulb,
                    color: Colors.amber,
                  ),
                ],
              ),
            ),
    );
  }

  List<String> _getWeakSubjects(Map<String, double> subjectAverages, double targetNet) {
    final weakSubjects = subjectAverages.entries
        .where((entry) => entry.value < targetNet * 0.7)
        .map((entry) => '${entry.key}: ${entry.value.toStringAsFixed(1)} net')
        .toList();

    return weakSubjects.isEmpty
        ? ['Tüm derslerde iyi performans gösteriyorsunuz!']
        : weakSubjects;
  }

  List<String> _getImprovementAreas(List testResults) {
    final recommendations = <String>[];

    // Analyze study time vs performance
    final avgStudyTime = testResults.isNotEmpty
        ? testResults.map((r) => r.studyTime).reduce((a, b) => a + b) / testResults.length
        : 0;

    if (avgStudyTime < 60) {
      recommendations.add('Günlük çalışma sürenizi artırmayı düşünün');
    }

    // Analyze wrong answers
    final avgWrong = testResults.isNotEmpty
        ? testResults.map((r) => r.wrong).reduce((a, b) => a + b) / testResults.length
        : 0;

    if (avgWrong > 5) {
      recommendations.add('Hata analizi yaparak zayıf konuları belirleyin');
    }

    if (recommendations.isEmpty) {
      recommendations.add('Mevcut stratejinizle devam edin');
    }

    return recommendations;
  }
}

class _AnalysisCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _AnalysisCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                    ),
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

class _SubjectAnalysisCard extends StatelessWidget {
  final String subject;
  final double averageNet;
  final double progress;
  final double targetNet;

  const _SubjectAnalysisCard({
    required this.subject,
    required this.averageNet,
    required this.progress,
    required this.targetNet,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  subject,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${averageNet.toStringAsFixed(1)} / ${targetNet.toStringAsFixed(1)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                progress > 0.7 ? Colors.green : progress > 0.4 ? Colors.orange : Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(progress * 100).toStringAsFixed(1)}% hedefe ulaşma',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final String title;
  final List<String> recommendations;
  final IconData icon;
  final Color color;

  const _RecommendationCard({
    required this.title,
    required this.recommendations,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...recommendations.map((rec) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Text(
                      rec,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}