import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/test_result.dart';
import '../providers/app_provider.dart';
import '../services/api_service.dart';
import '../widgets/custom_button.dart';
import '../utils/helpers.dart';

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

  bool _isLoading = false;
  Map<String, dynamic>? _predictionResult;

  @override
  void dispose() {
    _subjectController.dispose();
    _totalQuestionsController.dispose();
    _correctController.dispose();
    _wrongController.dispose();
    _studyTimeController.dispose();
    _difficultyController.dispose();
    super.dispose();
  }

  Future<void> _analyzeTest() async {
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

      setState(() => _predictionResult = result);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Analiz hatası: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveTestResult() async {
    if (!_formKey.currentState!.validate() || _predictionResult == null) return;

    try {
      final testResult = TestResult(
        subject: _subjectController.text.trim(),
        totalQuestions: int.parse(_totalQuestionsController.text),
        correct: int.parse(_correctController.text),
        wrong: int.parse(_wrongController.text),
        studyTime: int.parse(_studyTimeController.text),
        difficulty: double.parse(_difficultyController.text),
        currentNet: context.read<AppProvider>().user!.currentNet,
        targetNet: context.read<AppProvider>().user!.targetNet,
        predictedNet: _predictionResult!['predicted_net'],
        date: DateTime.now(),
      );

      await context.read<AppProvider>().addTestResult(testResult);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Test sonucu kaydedildi')),
      );

      _clearForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kaydetme hatası: $e')),
      );
    }
  }

  void _clearForm() {
    _subjectController.clear();
    _totalQuestionsController.clear();
    _correctController.clear();
    _wrongController.clear();
    _studyTimeController.clear();
    _difficultyController.text = '1.0';
    setState(() => _predictionResult = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Sonucu Gir'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Test Bilgilerini Girin',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Ders',
                  hintText: 'Örn: Matematik',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Lütfen ders adını girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _totalQuestionsController,
                decoration: const InputDecoration(
                  labelText: 'Toplam Soru',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Lütfen toplam soru sayısını girin';
                  }
                  final num = int.tryParse(value!);
                  if (num == null || num <= 0) {
                    return 'Geçerli bir sayı girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _correctController,
                      decoration: const InputDecoration(
                        labelText: 'Doğru',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Gerekli';
                        }
                        final num = int.tryParse(value!);
                        if (num == null || num < 0) {
                          return 'Geçersiz';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _wrongController,
                      decoration: const InputDecoration(
                        labelText: 'Yanlış',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Gerekli';
                        }
                        final num = int.tryParse(value!);
                        if (num == null || num < 0) {
                          return 'Geçersiz';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _studyTimeController,
                decoration: const InputDecoration(
                  labelText: 'Çalışma Süresi (dk)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Lütfen çalışma süresini girin';
                  }
                  final num = int.tryParse(value!);
                  if (num == null || num <= 0) {
                    return 'Geçerli bir süre girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _difficultyController,
                decoration: const InputDecoration(
                  labelText: 'Zorluk (0.5-1.5)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Lütfen zorluk seviyesini girin';
                  }
                  final num = double.tryParse(value!);
                  if (num == null || num < 0.5 || num > 1.5) {
                    return '0.5-1.5 arası girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Analiz Et',
                isLoading: _isLoading,
                onPressed: _analyzeTest,
              ),
              if (_predictionResult != null) ...[
                const SizedBox(height: 24),
                Card(
                  elevation: 4,
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Tahmini',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tahmini Net: ${_predictionResult!['predicted_net'].toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Kaydet',
                  onPressed: _saveTestResult,
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}