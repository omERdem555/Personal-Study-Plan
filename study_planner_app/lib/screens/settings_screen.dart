import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../screens/splash_screen.dart';
import '../widgets/primary_button.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          Text('Profil Bilgileri', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 18),
          if (user != null) ...[
            _SettingTile(label: 'Ad', value: user.name),
            _SettingTile(label: 'Hedef Ders', value: user.targetSubject),
            _SettingTile(label: 'Mevcut Net', value: user.currentNet.toStringAsFixed(1)),
            _SettingTile(label: 'Hedef Net', value: user.targetNet.toStringAsFixed(1)),
          ],
          const SizedBox(height: 24),
          Text('Uygulama', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 18),
          SwitchListTile(
            title: const Text('Karanlık Mod'),
            value: provider.isDarkMode,
            onChanged: (value) => provider.toggleThemeMode(value),
          ),
          const SizedBox(height: 24),
          Text('Veri Yönetimi', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 18),
          _ActionCard(
            title: 'Hedef Güncelle',
            description: 'Mevcut net veya hedef netinizi güncelleyin.',
            buttonLabel: 'Güncelle',
            onPressed: () => _showTargetDialog(context),
          ),
          const SizedBox(height: 16),
          _ActionCard(
            title: 'Verileri Sıfırla',
            description: 'Tüm kayıtlı kullanıcı ve test verilerini siler.',
            buttonLabel: 'Sıfırla',
            onPressed: () => _confirmReset(context),
            buttonColor: Colors.red,
          ),
        ],
      ),
    );
  }

  void _showTargetDialog(BuildContext context) {
    final currentController = TextEditingController();
    final targetController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hedef Güncelle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: currentController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Mevcut Net')), 
              TextField(controller: targetController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Hedef Net')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('�ptal')),
            TextButton(
              onPressed: () {
                final provider = context.read<AppProvider>();
                final currentNet = double.tryParse(currentController.text);
                final targetNet = double.tryParse(targetController.text);
                if (currentNet != null || targetNet != null) {
                  provider.updateUserProgress(currentNet: currentNet, targetNet: targetNet);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Verileri Sil'),
          content: const Text('Bu işlem tüm verileri kalıcı olarak siler. Devam etmek istiyor musunuz?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('�ptal')),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await context.read<AppProvider>().clearAllData();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const SplashScreen()),
                  (route) => false,
                );
              },
              child: const Text('Sil', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

class _SettingTile extends StatelessWidget {
  final String label;
  final String value;

  const _SettingTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(label),
        subtitle: Text(value),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String description;
  final String buttonLabel;
  final VoidCallback onPressed;
  final Color buttonColor;

  const _ActionCard({
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.onPressed,
    this.buttonColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Text(description, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700])),
            const SizedBox(height: 14),
            PrimaryButton(label: buttonLabel, onTap: onPressed, color: buttonColor),
          ],
        ),
      ),
    );
  }
}
