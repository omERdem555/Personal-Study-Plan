import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/api_service.dart';
import '../widgets/primary_button.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _planResult;

  Future<void> _loadPlan() async {
    final provider = context.read<AppProvider>();
    final user = provider.user;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      final recent = provider.latestResult;
      final response = await ApiService.getPlan(
        subject: recent?.subject ?? user.targetSubject,
        totalQuestions: recent?.totalQuestions ?? 40,
        correct: recent?.correct ?? 24,
        wrong: recent?.wrong ?? 16,
        currentNet: user.currentNet,
        targetNet: user.targetNet,
      );

      setState(() => _planResult = response);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Plan oluşturma hatası: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.user;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Tavsiye Planı'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          Text(
            'Kişisel Çalışma Planı',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Mevcut performansınıza göre AI destekli bir günlük plan oluşturun.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[700]),
          ),
          const SizedBox(height: 20),
          if (_planResult == null)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Plan hazır değil', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    Text(
                      'Önce son test verilerinizi kullanarak plan oluşturun. Bu öneri size hedef netinize ulaşmanız için yön gösterir.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(label: 'Plan Oluştur', onTap: _loadPlan, isLoading: _isLoading),
                  ],
                ),
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('AI Planı', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 16),
                        _PlanDetailRow(label: 'Önerilen Ders', value: _planResult!['subject'] ?? user.targetSubject),
                        _PlanDetailRow(label: 'Çalışma Süresi', value: '${_planResult!['study_time']} dakika'),
                        _PlanDetailRow(label: 'Tahmini Net', value: _planResult!['predicted_net']?.toStringAsFixed(1) ?? '--'),
                        _PlanDetailRow(
                          label: 'Hedef Açığı',
                          value: _planResult != null
                              ? ((user.targetNet - (_planResult!['predicted_net'] as num).toDouble()).clamp(0.0, double.infinity)).toStringAsFixed(1)
                              : provider.targetGap.toStringAsFixed(1),
                        ),
                        const SizedBox(height: 18),
                        Text('Plan Özeti', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 10),
                        Text(
                          _planResult != null
                              ? 'Bu plan ile ${_planResult!['subject'] ?? user.targetSubject} dersinde ${_planResult!['study_time']} dk çalışarak tahmini netinizi ${(_planResult!['predicted_net'] as num?)?.toStringAsFixed(1) ?? '--'} seviyesine çıkarabilirsiniz.'
                              : provider.planSummary,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700], height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Öncelikli Adımlar', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                ...provider.recommendations.map((recommendation) => _RecommendationCard(text: recommendation)).toList(),
                const SizedBox(height: 24),
                PrimaryButton(label: 'Yeniden Hesapla', onTap: _loadPlan, isLoading: _isLoading),
              ],
            ),
        ],
      ),
    );
  }
}

class _PlanDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _PlanDetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final String text;

  const _RecommendationCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.lightbulb_outline, color: Color(0xFF3366FF)),
            const SizedBox(width: 12),
            Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
          ],
        ),
      ),
    );
  }
}
