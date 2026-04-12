import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  String plan = "";

  void getPlan() async {
    final response = await ApiService.getPlan(
      subject: "math",
      totalQuestions: 40,
      correct: 25,
      wrong: 15,
      currentNet: 20,
      targetNet: 35,
    );

    setState(() {
      plan = response.toString();
    });
  }

  @override
  void initState() {
    super.initState();
    getPlan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Plan")),
      body: Center(
        child: Text(plan),
      ),
    );
  }
}