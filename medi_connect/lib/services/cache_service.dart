import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Simple cache service using SharedPreferences for offline support.
/// In production, replace with Hive for better performance.
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  static const Duration _defaultTtl = Duration(hours: 1);

  Future<void> set(String key, dynamic value, {Duration? ttl}) async {
    final prefs = await SharedPreferences.getInstance();
    final expiry = DateTime.now().add(ttl ?? _defaultTtl).millisecondsSinceEpoch;
    final wrapper = {'data': value, 'expiry': expiry};
    await prefs.setString('cache_$key', jsonEncode(wrapper));
  }

  Future<T?> get<T>(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('cache_$key');
      if (raw == null) return null;

      final wrapper = jsonDecode(raw) as Map<String, dynamic>;
      final expiry = wrapper['expiry'] as int;

      if (DateTime.now().millisecondsSinceEpoch > expiry) {
        await prefs.remove('cache_$key');
        return null;
      }

      return wrapper['data'] as T?;
    } catch (_) {
      return null;
    }
  }

  Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cache_$key');
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('cache_')).toList();
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  // Convenience methods for common data
  Future<void> cacheDoctors(List<Map<String, dynamic>> doctors) async {
    await set('doctors_list', doctors, ttl: const Duration(minutes: 30));
  }

  Future<List<Map<String, dynamic>>?> getCachedDoctors() async {
    final data = await get<List>('doctors_list');
    return data?.cast<Map<String, dynamic>>();
  }

  Future<void> cacheUserProfile(Map<String, dynamic> profile) async {
    await set('user_profile', profile, ttl: const Duration(hours: 24));
  }

  Future<Map<String, dynamic>?> getCachedUserProfile() async {
    return await get<Map<String, dynamic>>('user_profile');
  }

  Future<void> cacheAppointments(List<Map<String, dynamic>> appointments) async {
    await set('appointments', appointments, ttl: const Duration(minutes: 15));
  }

  Future<List<Map<String, dynamic>>?> getCachedAppointments() async {
    final data = await get<List>('appointments');
    return data?.cast<Map<String, dynamic>>();
  }
}
