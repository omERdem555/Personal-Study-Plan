import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/study_plan.dart';
import '../models/subject_goal.dart';
import '../providers/app_provider.dart';
import '../screens/settings_screen.dart';
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
  String? _selectedSubject;

  Future<void> _loadPlan() async {
    if (!mounted) return;
    final provider = context.read<AppProvider>();
    final user = provider.user;
    if (user == null || provider.subjectGoals.isEmpty) return;

    final subject = _selectedSubject ?? provider.subjectGoals.first.subject;
    setState(() => _isLoading = true);

    try {
      final recent = provider.latestResult;
      final goal = provider.subjectGoals.firstWhere(
        (goal) => goal.subject == subject,
        orElse: () => SubjectGoal(subject: subject, currentNet: 0.0, targetNet: user.targetNet, createdAt: DateTime.now()),
      );

      final response = await ApiService.getPlan(
        subject: subject,
        totalQuestions: recent?.totalQuestions ?? 40,
        correct: recent?.correct ?? 24,
        wrong: recent?.wrong ?? 16,
        currentNet: provider.averageNet,
        targetNet: goal.targetNet,
      );

      setState(() => _planResult = {...response, 'subject': subject});
      if (response.containsKey('study_time') && response.containsKey('predicted_net')) {
        await provider.addStudyPlan(
          StudyPlan(
            subject: subject,
            studyTime: response['study_time'] as int,
            predictedNet: (response['predicted_net'] as num).toDouble(),
            date: DateTime.now(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Plan oluşturma hatası: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.user;
    final selectedSubject = _selectedSubject ?? (provider.subjectGoals.isNotEmpty ? provider.subjectGoals.first.subject : '');
    final latestSubjectPlan = provider.latestPlanForSubject(selectedSubject);
    final planAvailable = _planResult != null || latestSubjectPlan != null;
    final displayedPlan = _planResult != null
        ? StudyPlan(
            subject: _planResult!['subject'] as String,
            studyTime: _planResult!['study_time'] as int,
            predictedNet: (_planResult!['predicted_net'] as num).toDouble(),
            date: DateTime.now(),
          )
        : latestSubjectPlan;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Tavsiye Planı'),
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
          if (provider.subjectGoals.isNotEmpty) ...[
            Text('Plan Oluşturmak için ders seçin', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedSubject.isNotEmpty ? selectedSubject : null,
              items: provider.subjectGoals.map((goal) => DropdownMenuItem(value: goal.subject, child: Text(goal.subject))).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSubject = value;
                });
              },
              decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Ders Seçiniz'),
            ),
            const SizedBox(height: 20),
          ],
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
          if (provider.subjectGoals.isEmpty)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ders yok', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    Text(
                      'Ana Sayfa üzerinden yeni dersler ekleyin. Her ders için özel plan oluşturabilirsiniz.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            )
          else if (!planAvailable)
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
                      'Plan oluşturmak için bir ders seçin ve "Plan Oluştur" butonuna dokunun.',
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
                        _PlanDetailRow(label: 'Önerilen Ders', value: displayedPlan?.subject ?? selectedSubject),
                        _PlanDetailRow(label: 'Çalışma Süresi', value: '${displayedPlan?.studyTime ?? 0} dakika'),
                        _PlanDetailRow(label: 'Tahmini Net', value: displayedPlan?.predictedNet.toStringAsFixed(1) ?? '--'),
                        _PlanDetailRow(label: 'Mevcut Net', value: provider.subjectGoals.firstWhere((goal) => goal.subject == selectedSubject, orElse: () => SubjectGoal(subject: selectedSubject, currentNet: 0.0, targetNet: user.targetNet, createdAt: DateTime.now())).currentNet.toStringAsFixed(1)),
                        _PlanDetailRow(
                          label: 'Hedef Açığı',
                          value: ((provider.subjectGoals.firstWhere((goal) => goal.subject == selectedSubject, orElse: () => SubjectGoal(subject: selectedSubject, currentNet: 0.0, targetNet: user.targetNet, createdAt: DateTime.now())).targetNet - (displayedPlan?.predictedNet ?? 0.0)).clamp(0.0, double.infinity)).toStringAsFixed(1),
                        ),
                        const SizedBox(height: 18),
                        Text('Plan Özeti', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 10),
                        Text(
                          'Bu plan, seçili dersiniz için önerildi. ${displayedPlan?.studyTime ?? 0} dk çalışarak tahmini netinizi ${displayedPlan?.predictedNet.toStringAsFixed(1) ?? '--'} seviyesine taşımayı hedefleyin.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700], height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Öncelikli Adımlar', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                ...provider.planSteps.map((recommendation) => _RecommendationCard(text: recommendation)),
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
