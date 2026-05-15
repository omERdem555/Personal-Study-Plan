import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/stat_chip.dart';
import '../utils/helpers.dart';

class HomeDashboard extends StatelessWidget {
  final void Function(int) onNavigate;
  final VoidCallback onSettings;

  const HomeDashboard({
    super.key,
    required this.onNavigate,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.user;
    final recentTests = provider.recentResults;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Akademik Başarı Merkezi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: onSettings,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: provider.loadData,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          children: [
            Text(
              'Merhaba, ${user.name}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Hedefinize doğru her gün daha akıllı çalışın.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[700]),
            ),
            const SizedBox(height: 20),
            DashboardCard(
              title: 'Mevcut Net',
              value: user.currentNet.toStringAsFixed(1),
              subtitle: 'Hedefe kalan ${provider.targetGap.toStringAsFixed(1)} net',
              icon: Icons.school_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            DashboardCard(
              title: 'Hedef Net',
              value: user.targetNet.toStringAsFixed(1),
              subtitle: user.targetSubject,
              icon: Icons.flag_outlined,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatChip(
                    label: 'Net Ortalaması',
                    value: provider.averageNet.toStringAsFixed(1),
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatChip(
                    label: 'Test Sayısı',
                    value: '${provider.totalTests}',
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Günlük AI Önerisi',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Zayıf konulara ağırlık ver', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    Text(
                      provider.dailyRecommendation,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700], height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      runSpacing: 10,
                      spacing: 10,
                      children: provider.weakSubjects
                          .map(
                            (subject) => Chip(
                              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                              label: Text(subject),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Hızlı Geçişler',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    label: 'Test Gir',
                    onTap: () => onNavigate(1),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    label: 'AI Analiz',
                    onTap: () => onNavigate(2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    label: 'Plan Oluştur',
                    onTap: () => onNavigate(3),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    label: 'Raporlar',
                    onTap: () => onNavigate(4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Son Kayıtlar',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            if (recentTests.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    const Icon(Icons.timeline, size: 60, color: Colors.grey),
                    const SizedBox(height: 14),
                    Text(
                      'Henüz test verisi yok. Test girişi yaparak AI analizlerine başlayın.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ...recentTests.map(
                (result) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    tileColor: Theme.of(context).cardColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.16),
                      child: Icon(Icons.auto_graph, color: Theme.of(context).colorScheme.primary),
                    ),
                    title: Text(result.subject, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    subtitle: Text('${AppDateUtils.formatDate(result.date)} • Net ${result.actualNet.toStringAsFixed(1)}'),
                    trailing: Text('${result.correct}/${result.totalQuestions}'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
