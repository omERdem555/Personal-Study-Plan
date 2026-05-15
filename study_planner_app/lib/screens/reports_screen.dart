import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'settings_screen.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.user;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final netTrend = provider.netTrend;
    final studyTimeTrend = provider.studyTimeTrend;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Raporlar ve İstatistikler'),
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
          Text('Haftalık & Aylık Rapor', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Genel Özet', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 14),
                  _ReportMetric(label: 'Toplam Test', value: provider.totalTests.toString()),
                  _ReportMetric(label: 'Ortalama Net', value: provider.averageNet.toStringAsFixed(1)),
                  _ReportMetric(label: 'Hedef Açığı', value: provider.targetGap.toStringAsFixed(1)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Net Trendi (Gelişim)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 200,
                child: netTrend.isEmpty
                    ? const Center(child: Text('Veri yok'))
                    : LineChart(
                        LineChartData(
                          minX: -0.5,
                          maxX: (netTrend.length - 0.5).toDouble(),
                          minY: (netTrend.reduce((a, b) => a < b ? a : b) - 5).clamp(0, double.infinity),
                          maxY: netTrend.reduce((a, b) => a > b ? a : b) + 5,
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withAlpha((0.12 * 255).round()), strokeWidth: 1),
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 50,
                                interval: ((netTrend.reduce((a, b) => a > b ? a : b) - netTrend.reduce((a, b) => a < b ? a : b)) / 5).ceil().toDouble(),
                                getTitlesWidget: (value, meta) => Text(value.toStringAsFixed(0), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 28,
                                interval: (netTrend.length / 5).ceil().toDouble(),
                                getTitlesWidget: (value, meta) => Text('Test ${value.toInt() + 1}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: netTrend.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                              isCurved: true,
                              color: Theme.of(context).colorScheme.primary,
                              barWidth: 3,
                              belowBarData: BarAreaData(show: true, color: Theme.of(context).colorScheme.primary.withAlpha((0.16 * 255).round())),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Çalışma Süresi Trendi (dakika)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 200,
                child: studyTimeTrend.isEmpty
                    ? const Center(child: Text('Çalışma verisi henüz yok'))
                    : BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          barGroups: studyTimeTrend.asMap().entries.map((entry) {
                            return BarChartGroupData(
                              x: entry.key,
                              barRods: [
                                BarChartRodData(
                                  toY: entry.value.toDouble(),
                                  color: Theme.of(context).colorScheme.secondary,
                                  width: 16,
                                ),
                              ],
                            );
                          }).toList(),
                          gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withAlpha((0.12 * 255).round()), strokeWidth: 1)),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 35,
                                interval: 1,
                                getTitlesWidget: (value, meta) => Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text('Test ${value.toInt() + 1}', style: const TextStyle(color: Colors.grey, fontSize: 11), textAlign: TextAlign.center),
                                ),
                              ),
                            ),
                          ),
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipColor: (group) => Theme.of(context).colorScheme.primary,
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                return BarTooltipItem('${rod.toY.toInt()} dk', const TextStyle(color: Colors.white, fontWeight: FontWeight.bold));
                              },
                            ),
                          ),
                          maxY: studyTimeTrend.reduce((a, b) => a > b ? a : b).toDouble() + 10,
                          minY: 0,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportMetric extends StatelessWidget {
  final String label;
  final String value;

  const _ReportMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700])),
          Text(value, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
