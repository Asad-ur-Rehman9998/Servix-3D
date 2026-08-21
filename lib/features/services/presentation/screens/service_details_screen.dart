import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/price_tag.dart';
import '../../../../core/widgets/rating_stars.dart';
import '../../../../shared/data/mock_data.dart';
import '../../../../core/utils/async_value_x.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../bookings/presentation/providers/bookings_provider.dart';
import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../../domain/entities/service_entity.dart';
import '../providers/services_provider.dart';

class ServiceDetailsScreen extends ConsumerWidget {
  const ServiceDetailsScreen({super.key, required this.serviceId});

  final String serviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(serviceByIdProvider(serviceId));
    final favorites = ref.watch(favoritesProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return async.when(
      loading: () => const Scaffold(body: LoadingWidget()),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: ErrorView(
          message: '$e',
          onRetry: () => ref.invalidate(serviceByIdProvider(serviceId)),
        ),
      ),
      data: (service) {
        if (service == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const ErrorView(message: 'Service not found'),
          );
        }
        final provider = MockData.providers
            .where((p) => p.id == service.providerId)
            .firstOrNull;
        final isFav = favorites.contains(service.id);

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                actions: [
                  IconButton(
                    onPressed: () => ref
                        .read(favoritesProvider.notifier)
                        .toggle(service.id),
                    icon: Icon(
                      isFav ? Icons.favorite_rounded : Icons.favorite_border,
                      color: isFav ? AppColors.error : null,
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: 'service_image_${service.id}',
                    child: CachedNetworkImage(
                      imageUrl: service.imageUrl,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        child: Icon(service.category.icon, size: 64),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          RatingStars(rating: service.rating),
                          const SizedBox(width: 8),
                          Text(
                            '${service.rating} (${service.reviewCount} reviews)',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          PriceTag(amount: service.priceFrom),
                          const Spacer(),
                          Chip(
                            avatar: const Icon(Icons.schedule, size: 16),
                            label: Text('~${service.durationMinutes} min'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        service.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.45,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "What's included",
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      ...service.included.map(
                        (e) => ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.success,
                          ),
                          title: Text(e),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Not included',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      ...service.excluded.map(
                        (e) => ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(
                            Icons.remove_circle_outline,
                            color: AppColors.warning,
                          ),
                          title: Text(e),
                        ),
                      ),
                      if (provider != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Provider',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        ListTile(
                          onTap: () =>
                              context.push('/providers/${provider.id}'),
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundImage:
                                NetworkImage(provider.avatarUrl),
                          ),
                          title: Text(provider.name),
                          subtitle: Text(
                            '${provider.title} · ${provider.rating}★',
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded),
                        ),
                      ],
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () =>
                            context.push('/reviews/${service.providerId}'),
                        child: const Text('Read reviews'),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: AppButton(
                label: 'Book Now',
                icon: Icons.event_available_rounded,
                onPressed: () {
                  final user =
                      ref.read(authControllerProvider).valueOrNull?.user;
                  ref.read(bookingDraftProvider.notifier).startForService(
                        serviceId: service.id,
                        serviceTitle: service.title,
                        providerId: service.providerId,
                        providerName: provider?.name ?? 'Professional',
                        price: service.priceFrom,
                        address: user?.address,
                      );
                  context.push('/booking/flow');
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
