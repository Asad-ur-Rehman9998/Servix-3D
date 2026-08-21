import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../shared/widgets/category_chip_card.dart';
import '../../../../shared/widgets/service_card.dart';
import '../../domain/entities/service_entity.dart';
import '../providers/services_provider.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key, this.initialCategory});

  final String? initialCategory;

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  final _query = TextEditingController();
  ServiceCategoryType? _selected;

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      _selected = ServiceCategoryType.values.where(
        (e) => e.name == widget.initialCategory,
      ).firstOrNull;
    }
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final servicesAsync = ref.watch(servicesByCategoryProvider(_selected));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Explore')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: TextField(
              controller: _query,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Filter services…',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor:
                    isDark ? AppColors.darkSurface : AppColors.lightSurface,
              ),
            ),
          ),
          SizedBox(
            height: 108,
            child: categoriesAsync.when(
              loading: () => const LoadingWidget(),
              error: (e, _) => ErrorView(message: '$e'),
              data: (cats) => ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: cats.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return _AllChip(
                      selected: _selected == null,
                      onTap: () => setState(() => _selected = null),
                    );
                  }
                  final cat = cats[i - 1];
                  return CategoryChipCard(
                    category: cat,
                    selected: _selected == cat.type,
                    onTap: () => setState(() => _selected = cat.type),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: servicesAsync.when(
              loading: () => const LoadingWidget(),
              error: (e, st) => ErrorView(
                message: '$e',
                onRetry: () => ref.invalidate(servicesByCategoryProvider(_selected)),
              ),
              data: (services) {
                final q = _query.text.trim().toLowerCase();
                final filtered = q.isEmpty
                    ? services
                    : services
                        .where((s) =>
                            s.title.toLowerCase().contains(q) ||
                            s.description.toLowerCase().contains(q))
                        .toList();
                if (filtered.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.search_off_rounded,
                    title: 'No services found',
                    subtitle: 'Try another category or search term.',
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final s = filtered[i];
                    return ServiceCard(
                      service: s,
                      width: double.infinity,
                      onTap: () => context.push('/services/${s.id}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AllChip extends StatelessWidget {
  const _AllChip({required this.selected, required this.onTap});
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Container(
        width: 88,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.15)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.lightBorder,
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.apps_rounded, color: AppColors.primary),
            SizedBox(height: 8),
            Text('All', style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
