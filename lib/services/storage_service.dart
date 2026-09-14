import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/announcement.dart';

/// Uygulamanın tüm kalıcı (yerel) verilerini yönetir: görülen ilanlar,
/// ayarlar ve son kontrol zamanı.
class StorageService {
  static const _kItemsKey = 'nai_announcements_v1';
  static const _kLastCheckKey = 'nai_last_check_v1';
  static const _kNotificationsEnabledKey = 'nai_notifications_enabled_v1';
  static const _kIntervalMinutesKey = 'nai_interval_minutes_v1';
  static const _kFirstRunDoneKey = 'nai_first_run_done_v1';

  Future<SharedPreferences> get _prefs async =>
      SharedPreferences.getInstance();

  Future<List<Announcement>> loadAll() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_kItemsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => Announcement.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveAll(List<Announcement> items) async {
    final prefs = await _prefs;
    // En fazla 200 kayıt tutularak depolama şişmesi engellenir.
    final trimmed = items.length > 200 ? items.sublist(0, 200) : items;
    final raw = jsonEncode(trimmed.map((e) => e.toJson()).toList());
    await prefs.setString(_kItemsKey, raw);
  }

  Future<DateTime?> getLastCheck() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_kLastCheckKey);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> setLastCheck(DateTime time) async {
    final prefs = await _prefs;
    await prefs.setString(_kLastCheckKey, time.toIso8601String());
  }

  Future<bool> getNotificationsEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(_kNotificationsEnabledKey) ?? true;
  }

  Future<void> setNotificationsEnabled(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_kNotificationsEnabledKey, value);
  }

  Future<int> getIntervalMinutes() async {
    final prefs = await _prefs;
    return prefs.getInt(_kIntervalMinutesKey) ?? 10;
  }

  Future<void> setIntervalMinutes(int minutes) async {
    final prefs = await _prefs;
    await prefs.setInt(_kIntervalMinutesKey, minutes);
  }

  Future<bool> getFirstRunDone() async {
    final prefs = await _prefs;
    return prefs.getBool(_kFirstRunDoneKey) ?? false;
  }

  Future<void> setFirstRunDone(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_kFirstRunDoneKey, value);
  }

  Future<void> markAsRead(String url) async {
    final items = await loadAll();
    final idx = items.indexWhere((e) => e.url == url);
    if (idx == -1) return;
    items[idx] = items[idx].copyWith(isRead: true);
    await saveAll(items);
  }
}
