import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/test_result.dart';
import '../models/study_plan.dart';
import '../services/local_storage_service.dart';

class AppProvider extends ChangeNotifier {
  User? _user;
  List<TestResult> _testResults = [];
  List<StudyPlan> _studyPlans = [];

  User? get user => _user;
  List<TestResult> get testResults => _testResults;
  List<StudyPlan> get studyPlans => _studyPlans;

  bool get isOnboarded => _user != null;

  Future<void> loadData() async {
    _user = LocalStorageService.getUser();
    _testResults = LocalStorageService.getTestResults();
    _studyPlans = LocalStorageService.getStudyPlans();
    notifyListeners();
  }

  Future<void> saveUser(User user) async {
    _user = user;
    await LocalStorageService.saveUser(user);
    notifyListeners();
  }

  Future<void> addTestResult(TestResult result) async {
    _testResults.add(result);
    await LocalStorageService.saveTestResult(result);
    notifyListeners();
  }

  Future<void> addStudyPlan(StudyPlan plan) async {
    _studyPlans.add(plan);
    await LocalStorageService.saveStudyPlan(plan);
    notifyListeners();
  }

  Future<void> clearAllData() async {
    _user = null;
    _testResults.clear();
    _studyPlans.clear();
    await LocalStorageService.clearAllData();
    notifyListeners();
  }
}