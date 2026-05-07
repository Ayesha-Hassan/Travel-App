import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const String _placesKey = 'cached_places';
  static const String _timestampKey = 'cache_timestamp';
  static const Duration _ttl = Duration(hours: 1);

  final SharedPreferences prefs;

  CacheService(this.prefs);

  Future<void> savePlaces(List<dynamic> places) async {
    await prefs.setString(_placesKey, jsonEncode(places));
    await prefs.setInt(_timestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  List<dynamic>? getPlaces() {
    final timestamp = prefs.getInt(_timestampKey);
    if (timestamp == null) return null;

    final diff = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(timestamp));
    if (diff > _ttl) {
      prefs.remove(_placesKey);
      prefs.remove(_timestampKey);
      return null;
    }

    final data = prefs.getString(_placesKey);
    if (data == null) return null;
    return jsonDecode(data);
  }

  Future<void> clearCache() async {
    await prefs.remove(_placesKey);
    await prefs.remove(_timestampKey);
  }
}
