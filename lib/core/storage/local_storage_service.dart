import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override sharedPreferencesProvider in main');
});

final localStorageProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService(ref.watch(sharedPreferencesProvider));
});

class LocalStorageService {
  LocalStorageService(this._prefs);
  final SharedPreferences _prefs;

  static const _userKey = 'cached_user_json';
  static const _bookingsKey = 'cached_bookings_json';
  static const _passwordsKey = 'mock_passwords_json';
  static const _notificationsKey = 'notifications_enabled';
  static const _languageKey = 'app_language';

  Future<void> setOnboardingDone(bool value) =>
      _prefs.setBool(AppConstants.onboardingDoneKey, value);

  bool get isOnboardingDone =>
      _prefs.getBool(AppConstants.onboardingDoneKey) ?? false;

  Future<void> setThemeMode(String mode) =>
      _prefs.setString(AppConstants.themeModeKey, mode);

  String get themeMode =>
      _prefs.getString(AppConstants.themeModeKey) ?? 'system';

  Future<void> setNotificationsEnabled(bool value) =>
      _prefs.setBool(_notificationsKey, value);

  bool get notificationsEnabled =>
      _prefs.getBool(_notificationsKey) ?? true;

  Future<void> setLanguage(String code) =>
      _prefs.setString(_languageKey, code);

  String get language => _prefs.getString(_languageKey) ?? 'en';

  Future<void> saveUserJson(String json) => _prefs.setString(_userKey, json);

  String? get userJson => _prefs.getString(_userKey);

  Future<void> clearUserJson() => _prefs.remove(_userKey);

  Future<void> saveBookingsJson(String json) =>
      _prefs.setString(_bookingsKey, json);

  String? get bookingsJson => _prefs.getString(_bookingsKey);

  Future<void> savePassword(String email, String password) async {
    final map = _readPasswords();
    map[email.trim().toLowerCase()] = password;
    await _prefs.setString(_passwordsKey, jsonEncode(map));
  }

  String? getPassword(String email) =>
      _readPasswords()[email.trim().toLowerCase()];

  Map<String, String> _readPasswords() {
    final raw = _prefs.getString(_passwordsKey);
    if (raw == null || raw.isEmpty) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(k, v.toString()));
  }

  Future<void> saveRecentSearches(List<String> searches) async {
    final box = await Hive.openBox<String>(AppConstants.hiveBoxSearch);
    await box.clear();
    await box.addAll(searches.take(10));
  }

  Future<List<String>> getRecentSearches() async {
    final box = await Hive.openBox<String>(AppConstants.hiveBoxSearch);
    return box.values.toList();
  }

  Future<void> saveFavoriteIds(Set<String> ids) async {
    final box = await Hive.openBox<String>(AppConstants.hiveBoxFavorites);
    await box.clear();
    await box.addAll(ids);
  }

  Future<Set<String>> getFavoriteIds() async {
    final box = await Hive.openBox<String>(AppConstants.hiveBoxFavorites);
    return box.values.toSet();
  }
}
