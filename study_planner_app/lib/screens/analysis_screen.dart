import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../screens/settings_screen.dart';
import '../widgets/stat_chip.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  static const allSubjectsLabel = 'Tümü';
  String selectedSubject = allSubjectsLabel;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.user;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final subjectOptions = <String>{allSubjectsLabel, ...provider.testResults.map((result) => result.subject)}.toList();
    subjectOptions.sort((a, b) {
      if (a == allSubjectsLabel) return -1;
      if (b == allSubjectsLabel) return 1;
      return a.compareTo(b);
    });
    final activeSubject = subjectOptions.contains(selectedSubject) ? selectedSubject : allSubjectsLabel;

    final filteredResults = activeSubject == allSubjectsLabel
        ? provider.testResults
        : provider.testResults.where((result) => result.subject == activeSubject).toList();

    if (filteredResults.isEmpty) {
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
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.analytics_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 18),
                Text('Seçili ders için henüz veri yok', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                Text('Farklı bir ders seçin veya yeni test ekleyin.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600])),
              ],
            ),
          ),
        ),
      );
    }

    final spots = filteredResults.asMap().entries.map((entry) => FlSpot(entry.key.toDouble(), entry.value.actualNet)).toList();
    final minY = (filteredResults.map((r) => r.actualNet).reduce((a, b) => a < b ? a : b) - 5).clamp(0, double.infinity).toDouble();
    final maxY = filteredResults.map((r) => r.actualNet).reduce((a, b) => a > b ? a : b).toDouble() + 5;
    final maxX = spots.length > 1 ? (spots.length - 1).toDouble() : 1.0;

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
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          Text('Genel Performans', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: StatChip(label: 'Ortalama Net', value: provider.averageNet.toStringAsFixed(1), color: Colors.indigo)),
              const SizedBox(width: 12),
              Expanded(child: StatChip(label: 'Hedef Açığı', value: provider.targetGap.toStringAsFixed(1), color: Colors.red)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: StatChip(label: 'Toplam Test', value: '${provider.totalTests}', color: Colors.teal)),
              const SizedBox(width: 12),
              Expanded(child: StatChip(label: 'Tamamlanma', value: '${(provider.completionRate * 100).toStringAsFixed(1)}%', color: Colors.orange)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Net Eğrisi', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              DropdownButton<String>(
                value: activeSubject,
                items: subjectOptions.map((subject) {
                  return DropdownMenuItem(value: subject, child: Text(subject));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedSubject = value;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 14),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: SizedBox(
                height: 240,
                child: LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: maxX.toDouble(),
                    minY: minY,
                    maxY: maxY,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withAlpha((0.12 * 255).round()), strokeWidth: 1),
                    ),
                    lineTouchData: LineTouchData(
                      enabled: true,
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (spot) => Theme.of(context).colorScheme.primary,
                        getTooltipItems: (spots) {
                          return spots.map((spot) {
                            return LineTooltipItem('Net ${spot.y.toStringAsFixed(1)}', const TextStyle(color: Colors.white));
                          }).toList();
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          interval: 5,
                          getTitlesWidget: (value, meta) => Text(value.toStringAsFixed(0), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          interval: 1,
                          getTitlesWidget: (value, meta) => Text('T${value.toInt() + 1}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ),
                      ),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        barWidth: 3,
                        color: Theme.of(context).colorScheme.primary,
                        belowBarData: BarAreaData(show: true, color: Theme.of(context).colorScheme.primary.withAlpha((0.16 * 255).round())),
                        dotData: FlDotData(show: true),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Zayıf Dersler', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: provider.weakSubjects.map((subject) => Chip(label: Text(subject))).toList(),
          ),
          const SizedBox(height: 24),
          Text('AI Önerisi', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Text(
            provider.dailyRecommendation,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[700], height: 1.4),
          ),
        ],
      ),
    );
  }
}
