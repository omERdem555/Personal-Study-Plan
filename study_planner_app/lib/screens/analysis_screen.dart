import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/stat_chip.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.user;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (provider.testResults.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('AI Analiz')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.analytics_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 18),
                Text('Hen�z test verisi yok', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                Text('�lk testinizi girerek performans analizinizi g�r�n.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600])),
              ],
            ),
          ),
        ),
      );
    }

    final spots = provider.netTrend.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value);
    }).toList();

    final minY = (provider.netTrend.reduce((a, b) => a < b ? a : b).clamp(0, double.infinity) - 5).toDouble();
    final maxY = provider.netTrend.reduce((a, b) => a > b ? a : b).toDouble() + 5;
    final maxX = spots.length > 1 ? (spots.length - 1).toDouble() : 1.0;

    return Scaffold(
      appBar: AppBar(title: const Text('AI Analiz')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          Text('Genel Performans', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: StatChip(label: 'Ortalama Net', value: provider.averageNet.toStringAsFixed(1), color: Colors.indigo)),
              const SizedBox(width: 12),
              Expanded(child: StatChip(label: 'Hedef A����', value: provider.targetGap.toStringAsFixed(1), color: Colors.red)),
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
          Text('Net E�risi', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: SizedBox(
                height: 220,
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
                          getTitlesWidget: (value, meta) => Text((value.toInt() + 1).toString(), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ),
                      ),
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
          Text('Zay�f Dersler', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: provider.weakSubjects.map((subject) => Chip(label: Text(subject))).toList(),
          ),
          const SizedBox(height: 24),
          Text('AI ��g�r�s�', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
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
