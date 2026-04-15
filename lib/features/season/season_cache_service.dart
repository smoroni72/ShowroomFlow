import 'package:shared_preferences/shared_preferences.dart';

class SeasonCacheService {
  static const _key = 'active_season';

  static Future<void> saveSeason(String seasonId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, seasonId);
  }

  static Future<String?> getSeason() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  static Future<bool> isSeasonChanged(String newSeason) async {
    final current = await getSeason();
    return current != newSeason;
  }
}