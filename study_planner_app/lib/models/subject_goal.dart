class SubjectGoal {
  final String subject;
  final double currentNet;
  final double targetNet;
  final DateTime createdAt;

  SubjectGoal({
    required this.subject,
    required this.currentNet,
    required this.targetNet,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'currentNet': currentNet,
      'targetNet': targetNet,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SubjectGoal.fromJson(Map<String, dynamic> json) {
    return SubjectGoal(
      subject: json['subject'],
      currentNet: (json['currentNet'] as num).toDouble(),
      targetNet: (json['targetNet'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
