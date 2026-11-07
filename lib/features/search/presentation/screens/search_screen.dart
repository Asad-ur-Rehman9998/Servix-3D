import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../shared/data/mock_data.dart';
import '../../../../shared/widgets/service_card.dart';
import '../../../services/domain/entities/service_entity.dart';
import '../providers/search_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(searchProvider).query);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openFilters() async {
    final current = ref.read(searchProvider).filters;
    var temp = current;
    final result = await showModalBottomSheet<SearchFilters>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModal) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 8,
                bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filters',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 16),
                  Text('Max price: \$${temp.maxPrice.toStringAsFixed(0)}'),
                  Slider(
                    value: temp.maxPrice,
                    min: 20,
                    max: 500,
                    divisions: 24,
                    onChanged: (v) => setModal(
                      () => temp = temp.copyWith(maxPrice: v),
                    ),
                  ),
                  Text('Min rating: ${temp.minRating.toStringAsFixed(1)}'),
                  Slider(
                    value: temp.minRating,
                    min: 0,
                    max: 5,
                    divisions: 10,
                    onChanged: (v) => setModal(
                      () => temp = temp.copyWith(minRating: v),
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('Any category'),
                        selected: temp.category == null,
                        onSelected: (_) => setModal(
                          () => temp = temp.copyWith(clearCategory: true),
                        ),
                      ),
                      ...ServiceCategoryType.values.map(
                        (c) => FilterChip(
                          label: Text(c.label),
                          selected: temp.category == c,
                          onSelected: (_) => setModal(
                            () => temp = temp.copyWith(category: c),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context, temp),
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    if (result != null) {
      await ref.read(searchProvider.notifier).applyFiltersAndSearch(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchProvider);
    final notifier = ref.read(searchProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onChanged: notifier.setQuery,
          onSubmitted: notifier.search,
          decoration: const InputDecoration(
            hintText: 'Search services…',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _openFilters,
            icon: const Icon(Icons.tune_rounded),
          ),
          IconButton(
            onPressed: () => notifier.search(_controller.text),
            icon: const Icon(Icons.search_rounded),
          ),
        ],
      ),
      body: state.isLoading
          ? const LoadingWidget()
          : state.hasSearched
              ? state.results.isEmpty
                  ? const EmptyStateWidget(
                      icon: Icons.search_off_rounded,
                      title: 'No matches',
                      subtitle: 'Try adjusting filters or keywords.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      itemCount: state.results.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final s = state.results[i];
                        return ServiceCard(
                          service: s,
                          width: double.infinity,
                          onTap: () => context.push('/services/${s.id}'),
                        );
                      },
                    )
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      'Recent',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    if (state.recentSearches.isEmpty)
                      Text(
                        'No recent searches',
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: state.recentSearches
                            .map(
                              (t) => InputChip(
                                label: Text(t),
                                onPressed: () {
                                  _controller.text = t;
                                  notifier.search(t);
                                },
                                onDeleted: () => notifier.removeRecent(t),
                              ),
                            )
                            .toList(),
                      ),
                    const SizedBox(height: 24),
                    Text(
                      'Popular',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: MockData.popularSearches
                          .map(
                            (t) => ActionChip(
                              label: Text(t),
                              backgroundColor:
                                  AppColors.primary.withValues(alpha: 0.1),
                              onPressed: () {
                                _controller.text = t;
                                notifier.search(t);
                              },
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Browse all',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    ...MockData.services.take(4).map(
                      (s) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(s.title),
                        subtitle: Text(s.category.label),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/services/${s.id}'),
                      ),
                    ),
                  ],
                ),
    );
  }
}
