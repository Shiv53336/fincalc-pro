import 'package:shared_preferences/shared_preferences.dart';

class PremiumManager {
  static const _key = 'is_premium';
  static bool _isPremium = false;

  static bool get isPremium => _isPremium;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool(_key) ?? false;
  }

  static Future<void> setPremium(bool value) async {
    _isPremium = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
  }
}
