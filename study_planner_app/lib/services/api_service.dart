import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000";

  static Future<Map<String, dynamic>> getPrediction({
    required String subject,
    required int totalQuestions,
    required int correct,
    required int wrong,
    required int timeSpent,
    required double difficulty,
    required double currentNet,
    required double targetNet,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/predict"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "subject": subject,
        "total_questions": totalQuestions,
        "correct": correct,
        "wrong": wrong,
        "time_spent": timeSpent,
        "difficulty": difficulty,
        "current_net": currentNet,
        "target_net": targetNet
      }),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getPlan({
    required String subject,
    required int totalQuestions,
    required int correct,
    required int wrong,
    required double currentNet,
    required double targetNet,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/plan"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "subject": subject,
        "total_questions": totalQuestions,
        "correct": correct,
        "wrong": wrong,
        "current_net": currentNet,
        "target_net": targetNet
      }),
    );

    return jsonDecode(response.body);
  }
}