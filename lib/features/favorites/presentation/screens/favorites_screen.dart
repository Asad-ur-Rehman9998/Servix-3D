import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/service_card.dart';
import '../../../services/presentation/providers/services_provider.dart';
import '../providers/favorites_provider.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favIds = ref.watch(favoritesProvider);
    final servicesAsync = ref.watch(servicesListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: favIds.isEmpty
          ? EmptyStateWidget(
              icon: Icons.favorite_border_rounded,
              title: 'No favorites yet',
              subtitle: 'Tap the heart on a service to save it here.',
              actionLabel: 'Explore services',
              onAction: () => context.go('/explore'),
            )
          : servicesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (services) {
                final items =
                    services.where((s) => favIds.contains(s.id)).toList();
                if (items.isEmpty) {
                  return EmptyStateWidget(
                    title: 'Saved items unavailable',
                    subtitle: 'Clear favorites or browse again.',
                    actionLabel: 'Explore',
                    onAction: () => context.go('/explore'),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final s = items[i];
                    return ServiceCard(
                      service: s,
                      width: double.infinity,
                      onTap: () => context.push('/services/${s.id}'),
                    );
                  },
                );
              },
            ),
    );
  }
}
