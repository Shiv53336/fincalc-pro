import 'package:firebase_analytics/firebase_analytics.dart';

/// Wraps Firebase Analytics. Gracefully no-ops if Firebase is not configured.
/// To activate: add google-services.json and call FirebaseAnalytics.initialize().
class AnalyticsService {
  static FirebaseAnalytics? _analytics;

  static void initialize() {
    try {
      _analytics = FirebaseAnalytics.instance;
    } catch (_) {
      // Firebase not configured — analytics disabled
    }
  }

  static Future<void> _log(String name, [Map<String, Object>? params]) async {
    try {
      await _analytics?.logEvent(name: name, parameters: params);
    } catch (_) {}
  }

  // ─── App lifecycle ──────────────────────────
  static Future<void> logAppOpened() => _log('app_opened');

  // ─── Calculator events ───────────────────────
  static Future<void> logCalculatorUsed(String calculatorName) =>
      _log('calculator_used', {'calculator': calculatorName});

  static Future<void> logCalculationDone(String calculatorName) =>
      _log('calculation_done', {'calculator': calculatorName});

  // ─── PDF events ──────────────────────────────
  static Future<void> logPdfExported(String calculatorName) =>
      _log('pdf_exported', {'calculator': calculatorName});

  // ─── Premium funnel ──────────────────────────
  static Future<void> logPremiumPromptShown(String source) =>
      _log('premium_prompt_shown', {'source': source});

  static Future<void> logPremiumPurchased() => _log('premium_purchased');

  static Future<void> logPremiumRestored() => _log('premium_restored');

  // ─── Engagement ──────────────────────────────
  static Future<void> logHealthScoreShared(int score) =>
      _log('health_score_shared', {'score': score});

  static Future<void> logGoalSaved(String goalType) =>
      _log('goal_saved', {'goal_type': goalType});

  static Future<void> logScenarioCompared() => _log('scenario_compared');
}
