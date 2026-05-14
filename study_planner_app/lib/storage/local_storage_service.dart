import 'package:hive_flutter/hive_flutter.dart';

import '../models/user.dart';
import '../models/test_result.dart';
import '../models/study_plan.dart';

class LocalStorageService {
  static const String userBox = 'user_data';
  static const String testBox = 'test_results';
  static const String planBox = 'study_plans';

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    await Hive.openBox<dynamic>(userBox);
    await Hive.openBox<dynamic>(testBox);
    await Hive.openBox<dynamic>(planBox);
    _initialized = true;
  }

  static Map<String, dynamic> _mapFromDynamic(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return {}; 
  }

  static Future<void> saveUser(User user) async {
    final box = Hive.box<dynamic>(userBox);
    await box.put('user', user.toJson());
  }

  static Future<User?> getUser() async {
    final box = Hive.box<dynamic>(userBox);
    final raw = box.get('user');
    if (raw == null) return null;
    return User.fromJson(_mapFromDynamic(raw));
  }

  static Future<void> saveTestResult(TestResult result) async {
    final box = Hive.box<dynamic>(testBox);
    await box.put(result.date.toIso8601String(), result.toJson());
  }

  static Future<List<TestResult>> getTestResults() async {
    final box = Hive.box<dynamic>(testBox);
    return box.values
        .map((item) => TestResult.fromJson(_mapFromDynamic(item)))
        .toList();
  }

  static Future<void> saveStudyPlan(StudyPlan plan) async {
    final box = Hive.box<dynamic>(planBox);
    await box.put(plan.date.toIso8601String(), plan.toJson());
  }

  static Future<List<StudyPlan>> getStudyPlans() async {
    final box = Hive.box<dynamic>(planBox);
    return box.values
        .map((item) => StudyPlan.fromJson(_mapFromDynamic(item)))
        .toList();
  }

  static Future<void> clearAllData() async {
    await Hive.box<dynamic>(userBox).clear();
    await Hive.box<dynamic>(testBox).clear();
    await Hive.box<dynamic>(planBox).clear();
  }
}
