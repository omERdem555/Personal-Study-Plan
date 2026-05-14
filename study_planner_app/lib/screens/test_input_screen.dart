import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/test_result.dart';
import '../providers/app_provider.dart';
import '../services/api_service.dart';
import '../widgets/primary_button.dart';

class TestInputScreen extends StatefulWidget {
  const TestInputScreen({super.key});

  @override
  State<TestInputScreen> createState() => _TestInputScreenState();
}

class _TestInputScreenState extends State<TestInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _totalQuestionsController = TextEditingController();
  final _correctController = TextEditingController();
  final _wrongController = TextEditingController();
  final _studyTimeController = TextEditingController();
  final _difficultyController = TextEditingController(text: '1.0');
  final _weaknessController = TextEditingController();

  bool _isLoading = false;
  double? _predictedNet;

  @override
  void dispose() {
    _subjectController.dispose();
    _totalQuestionsController.dispose();
    _correctController.dispose();
    _wrongController.dispose();
    _studyTimeController.dispose();
    _difficultyController.dispose();
    _weaknessController.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final user = context.read<AppProvider>().user;
      if (user == null) return;

      final result = await ApiService.getPrediction(
        subject: _subjectController.text.trim(),
        totalQuestions: int.parse(_totalQuestionsController.text),
        correct: int.parse(_correctController.text),
        wrong: int.parse(_wrongController.text),
        timeSpent: int.parse(_studyTimeController.text),
        difficulty: double.parse(_difficultyController.text),
        currentNet: user.currentNet,
        targetNet: user.targetNet,
      );

      setState(() => _predictedNet = (result['predicted_net'] as num).toDouble());
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Analiz hatas�: $error')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveResult() async {
    if (_predictedNet == null || !_formKey.currentState!.validate()) return;
    final user = context.read<AppProvider>().user;
    if (user == null) return;

    final result = TestResult(
      subject: _subjectController.text.trim(),
      totalQuestions: int.parse(_totalQuestionsController.text),
      correct: int.parse(_correctController.text),
      wrong: int.parse(_wrongController.text),
      studyTime: int.parse(_studyTimeController.text),
      difficulty: double.parse(_difficultyController.text),
      currentNet: user.currentNet,
      targetNet: user.targetNet,
      predictedNet: _predictedNet!,
      topicWeakness: _weaknessController.text.trim(),
      date: DateTime.now(),
    );

    await context.read<AppProvider>().addTestResult(result);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Test sonucu kaydedildi')));
    _clearForm();
  }

  void _clearForm() {
    _subjectController.clear();
    _totalQuestionsController.clear();
    _correctController.clear();
    _wrongController.clear();
    _studyTimeController.clear();
    _difficultyController.text = '1.0';
    _weaknessController.clear();
    setState(() => _predictedNet = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Giri�i')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Yeni Test Sonucu', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Text('Ders, net ve �al��ma s�resi bilgilerinizi girin, AI tahmini ile do�ru planlay�n.', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[700])),
              const SizedBox(height: 20),
              TextFormField(controller: _subjectController, decoration: const InputDecoration(labelText: 'Ders Ad�'), validator: (value) => (value?.isEmpty ?? true) ? 'Ders ad�n� girin' : null),
              const SizedBox(height: 14),
              TextFormField(controller: _totalQuestionsController, decoration: const InputDecoration(labelText: 'Toplam Soru'), keyboardType: TextInputType.number, validator: _validatePositiveInt),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: TextFormField(controller: _correctController, decoration: const InputDecoration(labelText: 'Do�ru'), keyboardType: TextInputType.number, validator: _validateNonNegativeInt)),
                  const SizedBox(width: 14),
                  Expanded(child: TextFormField(controller: _wrongController, decoration: const InputDecoration(labelText: 'Yanl��'), keyboardType: TextInputType.number, validator: _validateNonNegativeInt)),
                ],
              ),
              const SizedBox(height: 14),
              TextFormField(controller: _studyTimeController, decoration: const InputDecoration(labelText: '�al��ma S�resi (dk)'), keyboardType: TextInputType.number, validator: _validatePositiveInt),
              const SizedBox(height: 14),
              TextFormField(controller: _difficultyController, decoration: const InputDecoration(labelText: 'Zorluk (0.5 - 1.5)'), keyboardType: TextInputType.number, validator: _validateDifficulty),
              const SizedBox(height: 14),
              TextFormField(controller: _weaknessController, decoration: const InputDecoration(labelText: 'Zay�f Konu (opsiyonel)'), keyboardType: TextInputType.text),
              const SizedBox(height: 24),
              _predictedNet == null ? PrimaryButton(label: 'Analiz Et', onTap: _analyze, isLoading: _isLoading) : PrimaryButton(label: 'Sonucu Kaydet', onTap: _saveResult, isLoading: _isLoading),
              if (_predictedNet != null) ...[
                const SizedBox(height: 22),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tahmini Net', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        Text(_predictedNet!.toStringAsFixed(1), style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Text('Y�ksek do�ruluk hedefli bir plan i�in sonucu kaydedin.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700])),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String? _validatePositiveInt(String? value) {
    if (value?.isEmpty ?? true) return 'Bu alan bo� olamaz';
    final number = int.tryParse(value!);
    if (number == null || number <= 0) return 'Pozitif bir say� girin';
    return null;
  }

  String? _validateNonNegativeInt(String? value) {
    if (value?.isEmpty ?? true) return 'Bu alan bo� olamaz';
    final number = int.tryParse(value!);
    if (number == null || number < 0) return 'Ge�erli bir say� girin';
    return null;
  }

  String? _validateDifficulty(String? value) {
    if (value?.isEmpty ?? true) return 'Bu alan bo� olamaz';
    final number = double.tryParse(value!);
    if (number == null || number < 0.5 || number > 1.5) return '0.5 - 1.5 aras� de�er girin';
    return null;
  }
}
