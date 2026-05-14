import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/app_provider.dart';
import '../widgets/primary_button.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _subjectController = TextEditingController();
  final _currentNetController = TextEditingController();
  final _targetNetController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _subjectController.dispose();
    _currentNetController.dispose();
    _targetNetController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final user = User(
        name: _nameController.text.trim(),
        targetSubject: _subjectController.text.trim(),
        currentNet: double.parse(_currentNetController.text),
        targetNet: double.parse(_targetNetController.text),
        createdAt: DateTime.now(),
      );
      await context.read<AppProvider>().saveUser(user);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kaydetme hatas�: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ho� Geldiniz!', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(
                  'Akademik hedeflerinizi daha ak�ll�ca belirleyin ve AI destekli planlar�n�z� olu�turun.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[700]),
                ),
                const SizedBox(height: 32),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Ad�n�z'),
                        validator: (value) => (value?.isEmpty ?? true) ? 'Ad�n�z� girin' : null,
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _subjectController,
                        decoration: const InputDecoration(labelText: 'Hedef Ders'),
                        validator: (value) => (value?.isEmpty ?? true) ? 'Hedef dersi girin' : null,
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _currentNetController,
                        decoration: const InputDecoration(labelText: 'Mevcut Netiniz'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Mevcut net girin';
                          return double.tryParse(value!) == null ? 'Ge�erli bir say� girin' : null;
                        },
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _targetNetController,
                        decoration: const InputDecoration(labelText: 'Hedef Netiniz'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Hedef net girin';
                          return double.tryParse(value!) == null ? 'Ge�erli bir say� girin' : null;
                        },
                      ),
                      const SizedBox(height: 32),
                      PrimaryButton(label: 'Ba�la', onTap: _onSubmit, isLoading: _isLoading),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
