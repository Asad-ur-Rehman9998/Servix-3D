import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/rating_stars.dart';
import '../../../../shared/data/mock_data.dart';

class ProviderProfileScreen extends StatelessWidget {
  const ProviderProfileScreen({super.key, required this.providerId});

  final String providerId;

  @override
  Widget build(BuildContext context) {
    final provider =
        MockData.providers.where((p) => p.id == providerId).firstOrNull;
    if (provider == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const ErrorView(message: 'Provider not found'),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: Center(
                  child: Hero(
                    tag: 'provider_avatar_${provider.id}',
                    child: CircleAvatar(
                      radius: 54,
                      backgroundImage: CachedNetworkImageProvider(
                        provider.avatarUrl,
                      ),
                    ),
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
                    provider.name,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  Text(provider.title),
                  const SizedBox(height: 8),
                  RatingStars(
                    rating: provider.rating,
                    reviewCount: provider.jobsCompleted,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _StatChip(
                        label: '${provider.jobsCompleted} jobs',
                        icon: Icons.work_outline_rounded,
                      ),
                      _StatChip(
                        label: '${provider.experienceYears} yrs',
                        icon: Icons.timeline_rounded,
                      ),
                      _StatChip(
                        label: '${provider.distanceKm} km',
                        icon: Icons.place_outlined,
                      ),
                      _StatChip(
                        label: provider.available ? 'Available' : 'Busy',
                        icon: Icons.circle,
                        color: provider.available
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'About',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(provider.bio),
                  const SizedBox(height: 16),
                  Text(
                    'Skills',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: provider.skills
                        .map((s) => Chip(label: Text(s)))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  Text('Location: ${provider.location}'),
                  Text(
                    'From \$${provider.hourlyRate.toStringAsFixed(0)}/hr',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    label: 'Read reviews',
                    variant: AppButtonVariant.secondary,
                    onPressed: () =>
                        context.push('/reviews/${provider.id}'),
                  ),
                  const SizedBox(height: 10),
                  AppButton(
                    label: 'Contact provider',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Messaging is mocked in this demo'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.icon,
    this.color = AppColors.primary,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

class ReviewsScreen extends ConsumerStatefulWidget {
  const ReviewsScreen({super.key, required this.providerId});

  final String providerId;

  @override
  ConsumerState<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends ConsumerState<ReviewsScreen> {
  double _rating = 5;
  final _comment = TextEditingController();

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reviews = MockData.reviewsFor(widget.providerId);
    final avg =
        reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Reviews')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            avg.toStringAsFixed(1),
            style: Theme.of(context)
                .textTheme
                .displaySmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          RatingStars(rating: avg, reviewCount: reviews.length),
          const SizedBox(height: 16),
          ...reviews.map(
            (r) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: r.avatarUrl != null
                      ? NetworkImage(r.avatarUrl!)
                      : null,
                  child: r.avatarUrl == null ? Text(r.authorName[0]) : null,
                ),
                title: Text(r.authorName),
                subtitle: Text(r.comment),
                trailing: Text('${r.rating}★'),
              ),
            ),
          ),
          const Divider(height: 32),
          Text(
            'Leave a review',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          Slider(
            value: _rating,
            min: 1,
            max: 5,
            divisions: 8,
            label: _rating.toStringAsFixed(1),
            onChanged: (v) => setState(() => _rating = v),
          ),
          TextField(
            controller: _comment,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Share your experience…',
            ),
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Submit review',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Review submitted (demo)'),
                ),
              );
              _comment.clear();
            },
          ),
        ],
      ),
    );
  }
}
