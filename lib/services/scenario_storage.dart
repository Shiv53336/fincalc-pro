import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'premium_manager.dart';

class ScenarioData {
  final String id;
  final String name;
  final String calculator;
  final DateTime savedAt;
  final Map<String, String> results;

  ScenarioData({
    required this.id,
    required this.name,
    required this.calculator,
    required this.savedAt,
    required this.results,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'calculator': calculator,
    'savedAt': savedAt.toIso8601String(),
    'results': results,
  };

  factory ScenarioData.fromJson(Map<String, dynamic> json) => ScenarioData(
    id: json['id'] as String,
    name: json['name'] as String,
    calculator: json['calculator'] as String,
    savedAt: DateTime.parse(json['savedAt'] as String),
    results: Map<String, String>.from(json['results'] as Map),
  );
}

class ScenarioStorage {
  static const _key = 'saved_scenarios';
  static const int _freeLimit = 1;

  static Future<List<ScenarioData>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final List<dynamic> list = jsonDecode(raw) as List;
    return list.map((e) => ScenarioData.fromJson(e as Map<String, dynamic>)).toList()
      ..sort((a, b) => b.savedAt.compareTo(a.savedAt));
  }

  /// Returns true if saved successfully, false if limit reached.
  static Future<bool> save(ScenarioData scenario) async {
    final existing = await loadAll();
    if (!PremiumManager.isPremium && existing.length >= _freeLimit) {
      return false;
    }
    existing.insert(0, scenario);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(existing.map((e) => e.toJson()).toList()));
    return true;
  }

  static Future<void> delete(String id) async {
    final existing = await loadAll();
    existing.removeWhere((e) => e.id == id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(existing.map((e) => e.toJson()).toList()));
  }

  static String generateId() => DateTime.now().millisecondsSinceEpoch.toString();
}
