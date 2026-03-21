import 'package:shared_preferences/shared_preferences.dart';

class NudgeService {
  static const _pdfCountKey = 'pdf_export_count';
  static const _pdfMonthKey = 'pdf_export_month';
  static const _installDateKey = 'install_date';
  static const _nudgeCooldownPrefix = 'nudge_cooldown_';

  static const int freePdfLimit = 3;
  static const int nudgeCooldownDays = 3;

  // ─── Install date ────────────────────────────
  static Future<void> recordInstallDate() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_installDateKey)) {
      await prefs.setString(_installDateKey, DateTime.now().toIso8601String());
    }
  }

  static Future<int> daysSinceInstall() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_installDateKey);
    if (raw == null) return 0;
    final install = DateTime.tryParse(raw);
    if (install == null) return 0;
    return DateTime.now().difference(install).inDays;
  }

  // ─── PDF export counting ─────────────────────
  static Future<int> getPdfCountThisMonth() async {
    final prefs = await SharedPreferences.getInstance();
    final currentMonth = _monthKey();
    final savedMonth = prefs.getString(_pdfMonthKey) ?? '';
    if (savedMonth != currentMonth) {
      await prefs.setInt(_pdfCountKey, 0);
      await prefs.setString(_pdfMonthKey, currentMonth);
      return 0;
    }
    return prefs.getInt(_pdfCountKey) ?? 0;
  }

  static Future<void> incrementPdfCount() async {
    final prefs = await SharedPreferences.getInstance();
    final currentMonth = _monthKey();
    final savedMonth = prefs.getString(_pdfMonthKey) ?? '';
    int count = 0;
    if (savedMonth == currentMonth) {
      count = prefs.getInt(_pdfCountKey) ?? 0;
    }
    await prefs.setInt(_pdfCountKey, count + 1);
    await prefs.setString(_pdfMonthKey, currentMonth);
  }

  /// Returns {canExport: bool, used: int, remaining: int}
  static Future<Map<String, int>> checkPdfLimit() async {
    final count = await getPdfCountThisMonth();
    final remaining = (freePdfLimit - count).clamp(0, freePdfLimit);
    return {'canExport': count < freePdfLimit ? 1 : 0, 'used': count, 'remaining': remaining};
  }

  // ─── Nudge cooldown ──────────────────────────
  static Future<bool> shouldShowNudge(String nudgeId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_nudgeCooldownPrefix$nudgeId';
    final raw = prefs.getString(key);
    if (raw == null) return true;
    final last = DateTime.tryParse(raw);
    if (last == null) return true;
    return DateTime.now().difference(last).inDays >= nudgeCooldownDays;
  }

  static Future<void> markNudgeShown(String nudgeId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_nudgeCooldownPrefix$nudgeId';
    await prefs.setString(key, DateTime.now().toIso8601String());
  }

  static String _monthKey() {
    final now = DateTime.now();
    return '${now.year}_${now.month}';
  }
}
