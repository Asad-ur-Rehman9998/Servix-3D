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

  Future<void> setOnboardingDone(bool value) =>
      _prefs.setBool(AppConstants.onboardingDoneKey, value);

  bool get isOnboardingDone =>
      _prefs.getBool(AppConstants.onboardingDoneKey) ?? false;

  Future<void> setThemeMode(String mode) =>
      _prefs.setString(AppConstants.themeModeKey, mode);

  String get themeMode =>
      _prefs.getString(AppConstants.themeModeKey) ?? 'system';

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
