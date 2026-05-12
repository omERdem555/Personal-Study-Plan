import 'package:hive/hive.dart';
import '../models/test_result.dart';
import '../models/study_plan.dart';
import '../models/user.dart';

class LocalStorageService {
  static const String userBox = 'user_data';
  static const String testBox = 'test_results';
  static const String planBox = 'study_plans';

  static Box? _userBox;
  static Box? _testBox;
  static Box? _planBox;

  static Future<Box> _getUserBox() async {
    _userBox ??= await Hive.openBox(userBox);
    return _userBox!;
  }

  static Future<Box> _getTestBox() async {
    _testBox ??= await Hive.openBox(testBox);
    return _testBox!;
  }

  static Future<Box> _getPlanBox() async {
    _planBox ??= await Hive.openBox(planBox);
    return _planBox!;
  }

  static Future<void> saveUser(User user) async {
    final box = await _getUserBox();
    await box.put('user', user.toJson());
  }

  static Future<User?> getUser() async {
    final box = await _getUserBox();
    final data = box.get('user');
    if (data != null) {
      final map = _castToStringDynamicMap(data);
      return User.fromJson(map);
    }
    return null;
  }

  static Future<void> saveTestResult(TestResult result) async {
    final box = await _getTestBox();
    final key = result.date.toIso8601String();
    await box.put(key, result.toJson());
  }

  static Future<List<TestResult>> getTestResults() async {
    final box = await _getTestBox();
    return box.values.map((e) => TestResult.fromJson(_castToStringDynamicMap(e))).toList();
  }

  static Future<void> saveStudyPlan(StudyPlan plan) async {
    final box = await _getPlanBox();
    final key = plan.date.toIso8601String();
    await box.put(key, plan.toJson());
  }

  static Future<List<StudyPlan>> getStudyPlans() async {
    final box = await _getPlanBox();
    return box.values.map((e) => StudyPlan.fromJson(_castToStringDynamicMap(e))).toList();
  }

  static Map<String, dynamic> _castToStringDynamicMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    return Map<String, dynamic>.from(data as Map);
  }

  static Future<void> clearAllData() async {
    final userBox = await _getUserBox();
    final testBox = await _getTestBox();
    final planBox = await _getPlanBox();
    await userBox.clear();
    await testBox.clear();
    await planBox.clear();
  }
}