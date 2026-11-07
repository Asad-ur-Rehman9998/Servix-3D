import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/local_storage_service.dart';

final notificationsEnabledProvider =
    NotifierProvider<NotificationsEnabledController, bool>(
  NotificationsEnabledController.new,
);

class NotificationsEnabledController extends Notifier<bool> {
  @override
  bool build() => ref.watch(localStorageProvider).notificationsEnabled;

  Future<void> setEnabled(bool value) async {
    await ref.read(localStorageProvider).setNotificationsEnabled(value);
    state = value;
  }
}

final languageProvider =
    NotifierProvider<LanguageController, String>(LanguageController.new);

class LanguageController extends Notifier<String> {
  @override
  String build() => ref.watch(localStorageProvider).language;

  Future<void> setLanguage(String code) async {
    await ref.read(localStorageProvider).setLanguage(code);
    state = code;
  }
}
