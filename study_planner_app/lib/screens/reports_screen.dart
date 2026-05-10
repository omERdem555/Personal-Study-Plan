import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/helpers.dart';
import '../models/test_result.dart';
import '../models/study_plan.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final testResults = context.watch<AppProvider>().testResults;
    final studyPlans = context.watch<AppProvider>().studyPlans;
    final user = context.watch<AppProvider>().user;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Calculate weekly stats
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weeklyResults = testResults.where((r) => r.date.isAfter(weekStart)).toList();

    final totalTests = weeklyResults.length;
    final avgNet = weeklyResults.isNotEmpty
        ? weeklyResults.map((r) => r.predictedNet).reduce((a, b) => a + b) / weeklyResults.length
        : 0.0;
    final totalStudyTime = weeklyResults.isNotEmpty
        ? weeklyResults.map((r) => r.studyTime).reduce((a, b) => a + b)
        : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Raporlar'),
      ),
      body: testResults.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Henüz rapor verisi yok',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Test sonuçları girerek raporlarınızı görün',
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
                    'Haftalık Özet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Test Sayısı',
                          value: '$totalTests',
                          icon: Icons.assignment,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: 'Ort. Net',
                          value: avgNet.toStringAsFixed(1),
                          icon: Icons.trending_up,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Toplam Süre',
                          value: '${totalStudyTime}dk',
                          icon: Icons.access_time,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: 'Hedefe Uzaklık',
                          value: '${(user.targetNet - user.currentNet).toStringAsFixed(1)}',
                          icon: Icons.flag,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Net Artışı Grafiği',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        height: 200,
                        child: _NetProgressChart(testResults: testResults, targetNet: user.targetNet),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Son Test Sonuçları',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...testResults.take(5).map((result) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _TestResultCard(result: result),
                  )).toList(),
                  const SizedBox(height: 24),
                  Text(
                    'Çalışma Planları',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (studyPlans.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Henüz çalışma planı oluşturulmamış'),
                      ),
                    ),
                  if (!studyPlans.isEmpty)
                    ...studyPlans.take(3).map((plan) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _StudyPlanCard(plan: plan),
                    )).toList(),
                ],
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
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
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _NetProgressChart extends StatelessWidget {
  final List testResults;
  final double targetNet;

  const _NetProgressChart({
    required this.testResults,
    required this.targetNet,
  });

  @override
  Widget build(BuildContext context) {
    if (testResults.isEmpty) {
      return const Center(
        child: Text('Grafik için veri yok'),
      );
    }

    // Simple line chart representation
    return CustomPaint(
      painter: _NetChartPainter(testResults, targetNet),
      child: Container(),
    );
  }
}

class _NetChartPainter extends CustomPainter {
  final List testResults;
  final double targetNet;

  _NetChartPainter(this.testResults, this.targetNet);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final targetPaint = Paint()
      ..color = Colors.red.withOpacity(0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    if (testResults.length < 2) return;

    final points = <Offset>[];
    final maxNet = testResults.map((r) => r.predictedNet).reduce((a, b) => a > b ? a : b);
    final minNet = testResults.map((r) => r.predictedNet).reduce((a, b) => a < b ? a : b);

    for (int i = 0; i < testResults.length; i++) {
      final x = (i / (testResults.length - 1)) * size.width;
      final y = size.height - ((testResults[i].predictedNet - minNet) / (maxNet - minNet)) * size.height;
      points.add(Offset(x, y));
    }

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paint);

    // Draw target line
    final targetY = size.height - ((targetNet - minNet) / (maxNet - minNet)) * size.height;
    canvas.drawLine(Offset(0, targetY), Offset(size.width, targetY), targetPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _TestResultCard extends StatelessWidget {
  final TestResult result;

  const _TestResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.subject,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  AppDateUtils.formatDate(result.date),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Net: ${result.predictedNet.toStringAsFixed(1)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${result.correct}/${result.totalQuestions}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
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

class _StudyPlanCard extends StatelessWidget {
  final StudyPlan plan;

  const _StudyPlanCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.subject,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  AppDateUtils.formatDate(plan.date),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${plan.studyTime} dk',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Tahmin: ${plan.predictedNet.toStringAsFixed(1)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
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