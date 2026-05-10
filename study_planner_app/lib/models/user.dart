class User {
  final String name;
  final String targetSubject;
  final double targetNet;
  final double currentNet;
  final DateTime createdAt;

  User({
    required this.name,
    required this.targetSubject,
    required this.targetNet,
    required this.currentNet,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'targetSubject': targetSubject,
      'targetNet': targetNet,
      'currentNet': currentNet,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      targetSubject: json['targetSubject'],
      targetNet: json['targetNet'],
      currentNet: json['currentNet'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}