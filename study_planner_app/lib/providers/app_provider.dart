import 'package:flutter/material.dart';

import '../models/user.dart';
import '../models/test_result.dart';
import '../models/study_plan.dart';
import '../storage/local_storage_service.dart';

class AppProvider extends ChangeNotifier {
  User? _user;
  List<TestResult> _testResults = [];
  List<StudyPlan> _studyPlans = [];
  bool _isReady = false;
  bool _isDarkMode = false;

  User? get user => _user;
  List<TestResult> get testResults => List.unmodifiable(_testResults);
  List<StudyPlan> get studyPlans => List.unmodifiable(_studyPlans);
  bool get isReady => _isReady;
  bool get isOnboarded => _user != null;
  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  int get totalTests => _testResults.length;

  double get averageNet {
    if (_testResults.isEmpty) return 0.0;
    return _testResults.map((item) => item.predictedNet).reduce((a, b) => a + b) / _testResults.length;
  }

  double get targetGap {
    if (_user == null) return 0.0;
    return (_user!.targetNet - _user!.currentNet).clamp(0.0, double.infinity);
  }

  double get completionRate {
    if (_user == null || _user!.targetNet == 0) return 0.0;
    return (_user!.currentNet / _user!.targetNet).clamp(0.0, 1.0);
  }

  TestResult? get latestResult {
    if (_testResults.isEmpty) return null;
    return _testResults.last;
  }

  StudyPlan? get latestPlan {
    if (_studyPlans.isEmpty) return null;
    return _studyPlans.last;
  }

  List<String> get weakSubjects {
    final subjectMap = <String, List<double>>{};
    for (final result in _testResults) {
      subjectMap.putIfAbsent(result.subject, () => []).add(result.predictedNet);
    }
    final weakSubjects = subjectMap.entries
        .where((entry) => entry.value.reduce((a, b) => a + b) / entry.value.length < (_user?.targetNet ?? 0) * 0.8)
        .map((entry) => entry.key)
        .toList();
    return weakSubjects.isEmpty ? ['Genel çalışma temposunu koru'] : weakSubjects;
  }

  String get dailyRecommendation {
    if (_user == null) {
      return 'Öncelikle hedef bilgilerinizi kaydedin.';
    }
    if (_testResults.isEmpty) {
      return 'Bugün bir test sonucu ekleyin, AI size en iyi planı sunsun.';
    }
    final avgStudyTime = _testResults.isNotEmpty ? (_testResults.map((r) => r.studyTime).reduce((a, b) => a + b) / _testResults.length).toStringAsFixed(0) : '0';
    if (weakSubjects.isNotEmpty && weakSubjects.first != 'Genel çalışma temposunu koru') {
      return 'Öncelikli olarak ${weakSubjects.take(2).join(', ')} konularına (ortalama $avgStudyTime dk) odaklanın.';
    }
    if (completionRate < 0.7) {
      return 'Haftalık çalışma sürenizi arttırarak (şu anda $avgStudyTime dk) hedefe yaklaşın.';
    }
    return 'Harika ilerliyorsunuz. Mevcut çalışma süresi ($avgStudyTime dk) ile planınıza sadık kalın.';
  }

  String get planSummary {
    if (_user == null) {
      return 'Hedeflerinizi kaydedin ve AI planınızı oluşturun.';
    }
    if (_testResults.isEmpty) {
      return 'Test giriş olmadan AI planı kişiselleştirmek zor. Önce bir test girin.';
    }
    final avgStudyTime = (_testResults.map((r) => r.studyTime).reduce((a, b) => a + b) / _testResults.length).toStringAsFixed(0);
    return 'Zayıf konularınıza daha fazla zaman ($avgStudyTime dk) ayırarak hedef netinize ulaşabilecek bir plan oluşturduk.';
  }

  List<String> get recommendations {
    final list = <String>[];
    if (_user != null) {
      list.add('Günlük ${targetGap.toStringAsFixed(1)} net farkını kapatmaya odaklanın.');
    }
    final avgStudyTime = _testResults.isNotEmpty ? (_testResults.map((r) => r.studyTime).reduce((a, b) => a + b) / _testResults.length).toStringAsFixed(0) : '60';
    if (weakSubjects.isNotEmpty && weakSubjects.first != 'Genel çalışma temposunu koru') {
      list.add('Öncelikle ${weakSubjects.take(2).join(' ve ')} konularına günde en az $avgStudyTime dakika ayırın.');
    }
    list.add('Her test sonrası hata analizi yaparak konuları pekiştirin.');
    return list;
  }

  List<TestResult> get recentResults => _testResults.reversed.toList();
  List<double> get netTrend => _testResults.map((result) => result.predictedNet).toList();
  List<int> get studyTimeTrend => _testResults.map((result) => result.studyTime).toList();

  static Future<void> initializeStorage() async {
    await LocalStorageService.init();
  }

  Future<void> loadData() async {
    await LocalStorageService.init();
    _user = await LocalStorageService.getUser();
    _testResults = await LocalStorageService.getTestResults();
    _studyPlans = await LocalStorageService.getStudyPlans();
    _isReady = true;
    notifyListeners();
  }

  Future<void> saveUser(User user) async {
    _user = user;
    await LocalStorageService.saveUser(user);
    notifyListeners();
  }

  Future<void> toggleThemeMode(bool value) async {
    _isDarkMode = value;
    notifyListeners();
  }

  Future<void> updateUserProgress({double? currentNet, double? targetNet}) async {
    if (_user == null) return;
    _user = User(
      name: _user!.name,
      targetSubject: _user!.targetSubject,
      currentNet: currentNet ?? _user!.currentNet,
      targetNet: targetNet ?? _user!.targetNet,
      createdAt: _user!.createdAt,
    );
    await LocalStorageService.saveUser(_user!);
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
