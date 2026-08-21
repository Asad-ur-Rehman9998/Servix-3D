import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/data/mock_data.dart';
import '../../domain/app_notification.dart';

final notificationsProvider =
    NotifierProvider<NotificationsController, List<AppNotification>>(
  NotificationsController.new,
);

class NotificationsController extends Notifier<List<AppNotification>> {
  @override
  List<AppNotification> build() {
    return List.of(MockData.notifications);
  }

  int get unreadCount => state.where((n) => !n.isRead).length;

  void markRead(String id) {
    state = [
      for (final n in state)
        if (n.id == id) n.copyWith(isRead: true) else n,
    ];
  }

  void markAllRead() {
    state = [for (final n in state) n.copyWith(isRead: true)];
  }

  void delete(String id) {
    state = state.where((n) => n.id != id).toList();
  }

  void clearAll() {
    state = const [];
  }
}

final unreadNotificationsCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).where((n) => !n.isRead).length;
});
