class TestResult {
  final String subject;
  final int totalQuestions;
  final int correct;
  final int wrong;
  final int studyTime;
  final double difficulty;
  final double currentNet;
  final double targetNet;
  final double predictedNet;
  final DateTime date;

  TestResult({
    required this.subject,
    required this.totalQuestions,
    required this.correct,
    required this.wrong,
    required this.studyTime,
    required this.difficulty,
    required this.currentNet,
    required this.targetNet,
    required this.predictedNet,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'totalQuestions': totalQuestions,
      'correct': correct,
      'wrong': wrong,
      'studyTime': studyTime,
      'difficulty': difficulty,
      'currentNet': currentNet,
      'targetNet': targetNet,
      'predictedNet': predictedNet,
      'date': date.toIso8601String(),
    };
  }

  factory TestResult.fromJson(Map<String, dynamic> json) {
    return TestResult(
      subject: json['subject'],
      totalQuestions: json['totalQuestions'],
      correct: json['correct'],
      wrong: json['wrong'],
      studyTime: json['studyTime'],
      difficulty: json['difficulty'],
      currentNet: json['currentNet'],
      targetNet: json['targetNet'],
      predictedNet: json['predictedNet'],
      date: DateTime.parse(json['date']),
    );
  }
}