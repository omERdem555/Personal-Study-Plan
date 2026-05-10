class StudyPlan {
  final String subject;
  final int studyTime;
  final double predictedNet;
  final DateTime date;

  StudyPlan({
    required this.subject,
    required this.studyTime,
    required this.predictedNet,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'studyTime': studyTime,
      'predictedNet': predictedNet,
      'date': date.toIso8601String(),
    };
  }

  factory StudyPlan.fromJson(Map<String, dynamic> json) {
    return StudyPlan(
      subject: json['subject'],
      studyTime: json['studyTime'],
      predictedNet: json['predictedNet'],
      date: DateTime.parse(json['date']),
    );
  }
}