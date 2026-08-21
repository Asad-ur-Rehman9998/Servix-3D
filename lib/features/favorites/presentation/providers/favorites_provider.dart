import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/local_storage_service.dart';

final favoritesProvider =
    NotifierProvider<FavoritesController, Set<String>>(FavoritesController.new);

class FavoritesController extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    _load();
    return <String>{};
  }

  Future<void> _load() async {
    final ids = await ref.read(localStorageProvider).getFavoriteIds();
    state = ids;
  }

  bool isFavorite(String serviceId) => state.contains(serviceId);

  Future<void> toggle(String serviceId) async {
    final next = Set<String>.from(state);
    if (next.contains(serviceId)) {
      next.remove(serviceId);
    } else {
      next.add(serviceId);
    }
    state = next;
    await ref.read(localStorageProvider).saveFavoriteIds(next);
  }

  Future<void> add(String serviceId) async {
    if (state.contains(serviceId)) return;
    final next = {...state, serviceId};
    state = next;
    await ref.read(localStorageProvider).saveFavoriteIds(next);
  }

  Future<void> remove(String serviceId) async {
    if (!state.contains(serviceId)) return;
    final next = Set<String>.from(state)..remove(serviceId);
    state = next;
    await ref.read(localStorageProvider).saveFavoriteIds(next);
  }
}
