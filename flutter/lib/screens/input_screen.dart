import 'package:flutter/material.dart';
import '../services/api_service.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final subjectController = TextEditingController();
  final correctController = TextEditingController();
  final wrongController = TextEditingController();
  final timeController = TextEditingController();
  final currentNetController = TextEditingController();
  final targetNetController = TextEditingController();

  String result = "";

  void sendData() async {
    final response = await ApiService.getPrediction(
      subject: subjectController.text,
      totalQuestions: 40,
      correct: int.parse(correctController.text),
      wrong: int.parse(wrongController.text),
      timeSpent: int.parse(timeController.text),
      difficulty: 1.0,
      currentNet: double.parse(currentNetController.text),
      targetNet: double.parse(targetNetController.text),
    );

    setState(() {
      result = response.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Veri Girişi")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TextField(controller: subjectController, decoration: const InputDecoration(labelText: "Ders")),
            TextField(controller: correctController, decoration: const InputDecoration(labelText: "Doğru")),
            TextField(controller: wrongController, decoration: const InputDecoration(labelText: "Yanlış")),
            TextField(controller: timeController, decoration: const InputDecoration(labelText: "Süre (dk)")),
            TextField(controller: currentNetController, decoration: const InputDecoration(labelText: "Mevcut Net")),
            TextField(controller: targetNetController, decoration: const InputDecoration(labelText: "Hedef Net")),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: sendData,
              child: const Text("Analiz Et"),
            ),

            const SizedBox(height: 20),

            Text(result),
          ],
        ),
      ),
    );
  }
}