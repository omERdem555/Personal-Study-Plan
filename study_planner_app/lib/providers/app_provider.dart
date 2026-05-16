import 'package:flutter/material.dart';

import '../models/user.dart';
import '../models/test_result.dart';
import '../models/study_plan.dart';
import '../models/subject_goal.dart';
import '../storage/local_storage_service.dart';

class AppProvider extends ChangeNotifier {
  User? _user;
  List<TestResult> _testResults = [];
  List<StudyPlan> _studyPlans = [];
  List<SubjectGoal> _subjectGoals = [];
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
  int get totalSubjects => _subjectGoals.length;
  List<SubjectGoal> get subjectGoals => List.unmodifiable(_subjectGoals);

  double get averageNet {
    if (_testResults.isEmpty) return _user?.currentNet ?? 0.0;
    return _testResults.map((item) => item.actualNet).reduce((a, b) => a + b) / _testResults.length;
  }

  double get averageStudyTime {
    if (_testResults.isEmpty) return 90.0;
    return _testResults.map((item) => item.studyTime).reduce((a, b) => a + b) / _testResults.length;
  }

  double get recommendedStudyTime {
    if (latestPlan != null) return latestPlan!.studyTime.toDouble();
    return averageStudyTime;
  }

  double subjectAverageNet(String subject) {
    final results = _testResults.where((result) => result.subject == subject).toList();
    if (results.isEmpty) return 0.0;
    return results.map((item) => item.actualNet).reduce((a, b) => a + b) / results.length;
  }

  int subjectTestCount(String subject) {
    return _testResults.where((result) => result.subject == subject).length;
  }

  int subjectMaxQuestions(String subject) {
    const limits = {
      'Fen': 20,
      'Matematik': 40,
      'Türkçe': 40,
      'Sosyal': 40,
      'İngilizce': 40,
    };
    return limits[subject] ?? 40;
  }

  double subjectRecommendedStudyTime(String subject) {
    final plan = latestPlanForSubject(subject);
    if (plan != null) {
      return plan.studyTime.toDouble();
    }
    return averageStudyTime;
  }

  List<TestResult> subjectResults(String subject) {
    if (subject == 'Tümü') return _testResults;
    return _testResults.where((result) => result.subject == subject).toList();
  }

  TestResult? latestResultForSubject(String subject) {
    final subjects = _testResults.where((result) => result.subject == subject).toList();
    if (subjects.isEmpty) return null;
    return subjects.last;
  }

  SubjectGoal? getSubjectGoal(String subject) {
    try {
      return _subjectGoals.firstWhere((goal) => goal.subject == subject);
    } catch (_) {
      return null;
    }
  }

  double subjectTargetGap(String subject) {
    final goal = getSubjectGoal(subject);
    if (goal == null) return 0.0;
    return (goal.targetNet - subjectAverageNet(subject)).clamp(0.0, double.infinity);
  }

  double subjectCompletionRate(String subject) {
    final goal = getSubjectGoal(subject);
    if (goal == null || goal.targetNet == 0) return 0.0;
    return (subjectAverageNet(subject) / goal.targetNet).clamp(0.0, 1.0);
  }

  int subjectStudyTimeTotal(String subject) {
    return subjectResults(subject).fold(0, (sum, item) => sum + item.studyTime);
  }

  String subjectWeakness(String subject) {
    if (subject == 'Tümü') {
      return 'Genel eksiklerinizi düzenli test ve konu tekrarlarıyla kapatın.';
    }
    final matchedResults = _testResults.where((result) => result.subject == subject).toList();
    if (matchedResults.isEmpty) {
      return 'Bu ders için henüz yeterli veri yok. Yeni test ekleyin.';
    }
    final latest = matchedResults.last;
    if (latest.topicWeakness.isNotEmpty) {
      return 'Özellikle ${latest.topicWeakness} konusuna çalışın.';
    }
    final goal = _subjectGoals.firstWhere((item) => item.subject == subject, orElse: () => SubjectGoal(subject: subject, currentNet: 0.0, targetNet: _user?.targetNet ?? 50.0, createdAt: DateTime.now()));
    final avg = subjectAverageNet(subject);
    if (avg < goal.targetNet * 0.8) {
      return '$subject için temel konulara yeniden çalışma önerilir.';
    }
    return '$subject konularında düzenli tekrar ve test çözümü sürdürün.';
  }

  String subjectRecommendation(String subject) {
    if (subject == 'Tümü' || subject.isEmpty) {
      return dailyRecommendation;
    }
    final results = _testResults.where((result) => result.subject == subject).toList();
    if (results.isEmpty) {
      return 'Bu ders için veri yok. Yeni bir test girerek konu analizini güçlendirin.';
    }
    final avgNet = subjectAverageNet(subject);
    final avgTime = results.map((item) => item.studyTime).reduce((a, b) => a + b) / results.length;
    final goal = _subjectGoals.firstWhere((item) => item.subject == subject, orElse: () => SubjectGoal(subject: subject, currentNet: 0.0, targetNet: _user?.targetNet ?? avgNet, createdAt: DateTime.now()));
    final gap = (goal.targetNet - avgNet).clamp(0.0, double.infinity);
    if (gap > 0) {
      return '$subject için ortalama netiniz ${avgNet.toStringAsFixed(1)}. Günlük ${avgTime.toStringAsFixed(0)} dk çalışarak hedefe yaklaşın. Kalan net farkı ${gap.toStringAsFixed(1)}.';
    }
    return '$subject için performansınız güçlü. Yeni testlerle kalıcılığı artırın.';
  }

  List<String> get planSteps {
    if (latestPlan == null) {
      return [
        'Öncelikle hedef derslerinizi ekleyin.',
        'Yeni test sonuçları ekleyin ve plan oluşturun.',
        'Sonuçları kaydedip planınızı düzenli olarak güncelleyin.',
      ];
    }
    final plan = latestPlan!;
    return [
      'Öncelikli ders: ${plan.subject}. Bu konuya ${plan.studyTime} dk ayırın.',
      'Her çalışma oturumunda ilgili dersin zayıf konularını tekrar edin.',
      'Test sonuçlarını kaydedip planı haftalık olarak güncelleyin.',
    ];
  }

  double get targetGap {
    if (_user == null) return 0.0;
    final current = _testResults.isEmpty ? _user!.currentNet : averageNet;
    return (_user!.targetNet - current).clamp(0.0, double.infinity);
  }

  double get completionRate {
    if (_user == null || _user!.targetNet == 0) return 0.0;
    final current = _testResults.isEmpty ? _user!.currentNet : averageNet;
    return (current / _user!.targetNet).clamp(0.0, 1.0);
  }

  TestResult? get latestResult {
    if (_testResults.isEmpty) return null;
    return _testResults.last;
  }

  StudyPlan? get latestPlan {
    if (_studyPlans.isEmpty) return null;
    return _studyPlans.last;
  }

  StudyPlan? latestPlanForSubject(String subject) {
    final matchingPlans = _studyPlans.where((plan) => plan.subject == subject).toList();
    if (matchingPlans.isEmpty) return null;
    return matchingPlans.last;
  }

  List<String> get weakSubjects {
    final subjectMap = <String, List<double>>{};
    for (final result in _testResults) {
      subjectMap.putIfAbsent(result.subject, () => []).add(result.actualNet);
    }
    final weakSubjects = subjectMap.entries
        .where((entry) {
          final avg = entry.value.reduce((a, b) => a + b) / entry.value.length;
          final goal = _subjectGoals.firstWhere((item) => item.subject == entry.key, orElse: () => SubjectGoal(subject: entry.key, currentNet: 0.0, targetNet: _user?.targetNet ?? 50.0, createdAt: DateTime.now()));
          return avg < goal.targetNet * 0.8;
        })
        .map((entry) => entry.key)
        .toList();
    return weakSubjects.isEmpty ? ['Genel çalışma temposunu koru'] : weakSubjects;
  }

  String get dailyRecommendation {
    if (_user == null) {
      return 'Öncelikle hedef bilgilerinizi kaydedin.';
    }
    if (_subjectGoals.isEmpty) {
      return 'Derslerinizi ekleyin; her ders için özel öneri sunayım.';
    }
    if (_testResults.isEmpty) {
      return 'Bugün bir test sonucu ekleyin, AI size en iyi planı sunsun.';
    }
    final avgStudyTime = averageStudyTime.toStringAsFixed(0);
    final completedRate = (completionRate * 100).toStringAsFixed(0);
    if (latestPlan != null) {
      return 'Son planınız ${latestPlan!.subject} için günlük ${latestPlan!.studyTime} dk öneriyor. Hedefinize doğru ilerlemeye devam edin.';
    }
    if (weakSubjects.isNotEmpty && weakSubjects.first != 'Genel çalışma temposunu koru') {
      return 'Öncelikli olarak ${weakSubjects.take(2).join(', ')} konularına (ortalama $avgStudyTime dk) odaklanın. Şu anda hedefin %$completedRate tamamlandı.';
    }
    if (completionRate < 0.7) {
      return 'Haftalık çalışma sürenizi artırarak hedefinize yaklaşın. Ortalama $avgStudyTime dk çalışıyorsunuz.';
    }
    return 'Harika ilerliyorsunuz. Mevcut çalışma süreniz ($avgStudyTime dk) ile hedefe yaklaşıyorsunuz.';
  }

  String get planSummary {
    if (_user == null) {
      return 'Hedeflerinizi kaydedin ve AI planınızı oluşturun.';
    }
    if (_studyPlans.isNotEmpty) {
      final plan = _studyPlans.last;
      return 'Son planınız ${plan.subject} için ${plan.studyTime} dk çalışma ve ${plan.predictedNet.toStringAsFixed(1)} net tahmini sunuyor. Bu plan güncel test verilerinizden hesaplandı.';
    }
    if (_testResults.isEmpty) {
      return 'Test giriş olmadan AI planı kişiselleştirmek zor. Önce bir test girin.';
    }
    final avgStudyTime = averageStudyTime.toStringAsFixed(0);
    return 'Zayıf konularınıza daha fazla zaman ($avgStudyTime dk) ayırarak hedef netinize ulaşabilecek bir plan oluşturduk.';
  }

  List<String> get recommendations {
    final list = <String>[];
    if (_user != null) {
      list.add('Günlük ${targetGap.toStringAsFixed(1)} net farkını kapatmaya odaklanın.');
    }
    final avgStudyTime = averageStudyTime.toStringAsFixed(0);
    if (weakSubjects.isNotEmpty && weakSubjects.first != 'Genel çalışma temposunu koru') {
      list.add('Öncelikle ${weakSubjects.take(2).join(' ve ')} konularına günde en az $avgStudyTime dakika ayırın.');
    }
    if (latestPlan != null) {
      list.add('Günlük ${latestPlan!.studyTime} dk çalışma ile planlı ilerleyin.');
    }
    list.add('Her test sonrası hata analizi yaparak konuları pekiştirin.');
    return list;
  }

  List<TestResult> get recentResults => _testResults.reversed.toList();
  List<double> get netTrend => _testResults.map((result) => result.actualNet).toList();
  List<int> get studyTimeTrend => _testResults.map((result) => result.studyTime).toList();

  static Future<void> initializeStorage() async {
    await LocalStorageService.init();
  }

  Future<void> loadData() async {
    await LocalStorageService.init();
    _user = await LocalStorageService.getUser();
    _testResults = await LocalStorageService.getTestResults();
    _studyPlans = await LocalStorageService.getStudyPlans();
    _subjectGoals = await LocalStorageService.getSubjectGoals();
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

  Future<void> addSubjectGoal(SubjectGoal goal) async {
    final index = _subjectGoals.indexWhere((item) => item.subject == goal.subject);
    if (index >= 0) {
      _subjectGoals[index] = goal;
    } else {
      _subjectGoals.add(goal);
    }
    await LocalStorageService.saveSubjectGoal(goal);
    notifyListeners();
  }

  Future<void> removeSubjectGoal(String subject) async {
    _subjectGoals.removeWhere((item) => item.subject == subject);
    await LocalStorageService.deleteSubjectGoal(subject);
    notifyListeners();
  }

  Future<void> clearAllData() async {
    _user = null;
    _testResults.clear();
    _studyPlans.clear();
    _subjectGoals.clear();
    await LocalStorageService.clearAllData();
    notifyListeners();
  }
}
