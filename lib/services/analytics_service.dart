import 'package:flutter/foundation.dart';

/// Analytics stub — logs to debug console in dev, no-ops in release.
/// Replace with Firebase Analytics once google-services.json is added.
class AnalyticsService {
  static void initialize() {}

  static Future<void> _log(String name, [Map<String, Object>? params]) async {
    if (kDebugMode) debugPrint('[Analytics] $name ${params ?? ''}');
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
