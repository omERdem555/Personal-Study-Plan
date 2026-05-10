import 'package:hive/hive.dart';
import '../models/test_result.dart';
import '../models/study_plan.dart';
import '../models/user.dart';

class LocalStorageService {
  static const String userBox = 'user_data';
  static const String testBox = 'test_results';
  static const String planBox = 'study_plans';

  static Future<void> saveUser(User user) async {
    final box = Hive.box(userBox);
    await box.put('user', user.toJson());
  }

  static User? getUser() {
    final box = Hive.box(userBox);
    final data = box.get('user');
    if (data != null) {
      return User.fromJson(data);
    }
    return null;
  }

  static Future<void> saveTestResult(TestResult result) async {
    final box = Hive.box(testBox);
    final key = result.date.toIso8601String();
    await box.put(key, result.toJson());
  }

  static List<TestResult> getTestResults() {
    final box = Hive.box(testBox);
    return box.values.map((e) => TestResult.fromJson(e)).toList();
  }

  static Future<void> saveStudyPlan(StudyPlan plan) async {
    final box = Hive.box(planBox);
    final key = plan.date.toIso8601String();
    await box.put(key, plan.toJson());
  }

  static List<StudyPlan> getStudyPlans() {
    final box = Hive.box(planBox);
    return box.values.map((e) => StudyPlan.fromJson(e)).toList();
  }

  static Future<void> clearAllData() async {
    await Hive.box(userBox).clear();
    await Hive.box(testBox).clear();
    await Hive.box(planBox).clear();
  }
}