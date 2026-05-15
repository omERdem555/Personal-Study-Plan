import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/test_result.dart';
import '../providers/app_provider.dart';
import '../services/api_service.dart';
import '../screens/settings_screen.dart';
import '../utils/helpers.dart';
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
  double? _actualNet;

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

      final correct = int.parse(_correctController.text);
      final wrong = int.parse(_wrongController.text);
      final actualNet = MathUtils.calculateNet(correct, wrong);

      final result = await ApiService.getPrediction(
        subject: _subjectController.text.trim(),
        totalQuestions: int.parse(_totalQuestionsController.text),
        correct: correct,
        wrong: wrong,
        timeSpent: int.parse(_studyTimeController.text),
        difficulty: double.parse(_difficultyController.text),
        currentNet: user.currentNet,
        targetNet: user.targetNet,
      );

      setState(() {
        _predictedNet = (result['predicted_net'] as num).toDouble();
        _actualNet = actualNet;
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Analiz hatası: $error')));
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
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Test sonucu kaydedildi. Çalışma süresi ve zorluk verileri kaydedildi.')));
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
    setState(() {
      _predictedNet = null;
      _actualNet = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Giriş'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Yeni Test Sonucu ve Analiz', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Text('Ders, net ve çalışma süresi bilgilerinizi girin, AI tahmini ile doğru planlayın.', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[700])),
              const SizedBox(height: 20),
              TextFormField(controller: _subjectController, decoration: const InputDecoration(labelText: 'Ders Adı'), validator: (value) => (value?.isEmpty ?? true) ? 'Ders adını girin' : null),
              const SizedBox(height: 14),
              TextFormField(controller: _totalQuestionsController, decoration: const InputDecoration(labelText: 'Toplam Soru'), keyboardType: TextInputType.number, validator: _validatePositiveInt),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: TextFormField(controller: _correctController, decoration: const InputDecoration(labelText: 'Doğru'), keyboardType: TextInputType.number, validator: _validateNonNegativeInt)),
                  const SizedBox(width: 14),
                  Expanded(child: TextFormField(controller: _wrongController, decoration: const InputDecoration(labelText: 'Yanlış'), keyboardType: TextInputType.number, validator: _validateNonNegativeInt)),
                ],
              ),
              const SizedBox(height: 14),
              TextFormField(controller: _studyTimeController, decoration: const InputDecoration(labelText: 'Çalışma Süresi (dk)'), keyboardType: TextInputType.number, validator: _validatePositiveInt),
              const SizedBox(height: 14),
              TextFormField(controller: _difficultyController, decoration: const InputDecoration(labelText: 'Zorluk (0.5 - 1.5)'), keyboardType: TextInputType.number, validator: _validateDifficulty),
              const SizedBox(height: 14),
              TextFormField(controller: _weaknessController, decoration: const InputDecoration(labelText: 'Zayıf Konu (opsiyonel)'), keyboardType: TextInputType.text),
              const SizedBox(height: 24),
              _predictedNet == null ? PrimaryButton(label: 'Analiz Et', onTap: _analyze, isLoading: _isLoading) : PrimaryButton(label: 'Sonucu Kaydet (${_studyTimeController.text} dk)', onTap: _saveResult, isLoading: _isLoading),
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
                        Text('Tahmini Sonuç', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Gerçek Net', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                                Text(_actualNet!.toStringAsFixed(1), style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Tahmini Net', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                                Text(_predictedNet!.toStringAsFixed(1), style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text('${_studyTimeController.text} dakika çalışma ile tahmin edilen netiniz: ${_predictedNet!.toStringAsFixed(1)}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700])),
                        const SizedBox(height: 8),
                        Text('Yüksek doğruluk hedefli bir plan için sonucu kaydedin.', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
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
    if (value?.isEmpty ?? true) return 'Bu alan boş olamaz';
    final number = int.tryParse(value!);
    if (number == null || number <= 0) return 'Pozitif bir sayı girin';
    return null;
  }

  String? _validateNonNegativeInt(String? value) {
    if (value?.isEmpty ?? true) return 'Bu alan boş olamaz';
    final number = int.tryParse(value!);
    if (number == null || number < 0) return 'Geçerli bir sayı girin';
    return null;
  }

  String? _validateDifficulty(String? value) {
    if (value?.isEmpty ?? true) return 'Bu alan boş olamaz';
    final number = double.tryParse(value!);
    if (number == null || number < 0.5 || number > 1.5) return '0.5 - 1.5 arası değer girin';
    return null;
  }
}
