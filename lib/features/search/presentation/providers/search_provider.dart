import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/local_storage_service.dart';
import '../../../../shared/data/mock_data.dart';
import '../../../services/domain/entities/service_entity.dart';
import '../../../services/presentation/providers/services_provider.dart';

class SearchFilters extends Equatable {
  const SearchFilters({
    this.minPrice = 0,
    this.maxPrice = 500,
    this.minRating = 0,
    this.category,
  });

  final double minPrice;
  final double maxPrice;
  final double minRating;
  final ServiceCategoryType? category;

  SearchFilters copyWith({
    double? minPrice,
    double? maxPrice,
    double? minRating,
    ServiceCategoryType? category,
    bool clearCategory = false,
  }) {
    return SearchFilters(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minRating: minRating ?? this.minRating,
      category: clearCategory ? null : (category ?? this.category),
    );
  }

  @override
  List<Object?> get props => [minPrice, maxPrice, minRating, category];
}

class SearchState extends Equatable {
  const SearchState({
    this.query = '',
    this.filters = const SearchFilters(),
    this.results = const [],
    this.recentSearches = const [],
    this.isLoading = false,
    this.hasSearched = false,
  });

  final String query;
  final SearchFilters filters;
  final List<ServiceEntity> results;
  final List<String> recentSearches;
  final bool isLoading;
  final bool hasSearched;

  SearchState copyWith({
    String? query,
    SearchFilters? filters,
    List<ServiceEntity>? results,
    List<String>? recentSearches,
    bool? isLoading,
    bool? hasSearched,
  }) {
    return SearchState(
      query: query ?? this.query,
      filters: filters ?? this.filters,
      results: results ?? this.results,
      recentSearches: recentSearches ?? this.recentSearches,
      isLoading: isLoading ?? this.isLoading,
      hasSearched: hasSearched ?? this.hasSearched,
    );
  }

  @override
  List<Object?> get props =>
      [query, filters, results, recentSearches, isLoading, hasSearched];
}

final searchProvider =
    NotifierProvider<SearchController, SearchState>(SearchController.new);

class SearchController extends Notifier<SearchState> {
  @override
  SearchState build() {
    _loadRecent();
    return const SearchState();
  }

  Future<void> _loadRecent() async {
    final recent = await ref.read(localStorageProvider).getRecentSearches();
    state = state.copyWith(recentSearches: recent);
  }

  void setQuery(String query) {
    state = state.copyWith(query: query);
  }

  void setFilters(SearchFilters filters) {
    state = state.copyWith(filters: filters);
  }

  Future<void> search([String? overrideQuery]) async {
    final query = (overrideQuery ?? state.query).trim();
    state = state.copyWith(
      query: query,
      isLoading: true,
      hasSearched: true,
    );

    final repo = ref.read(servicesRepositoryProvider);
    var results = await repo.search(query);
    results = _applyFilters(results, state.filters);

    if (query.isNotEmpty) {
      final recent = [
        query,
        ...state.recentSearches.where((s) => s.toLowerCase() != query.toLowerCase()),
      ].take(10).toList();
      await ref.read(localStorageProvider).saveRecentSearches(recent);
      state = state.copyWith(
        results: results,
        isLoading: false,
        recentSearches: recent,
      );
    } else {
      state = state.copyWith(results: results, isLoading: false);
    }
  }

  Future<void> applyFiltersAndSearch(SearchFilters filters) async {
    state = state.copyWith(filters: filters);
    await search();
  }

  void clear() {
    state = state.copyWith(
      query: '',
      results: const [],
      hasSearched: false,
      filters: const SearchFilters(),
    );
  }

  void removeRecent(String term) {
    final recent = state.recentSearches.where((s) => s != term).toList();
    state = state.copyWith(recentSearches: recent);
    ref.read(localStorageProvider).saveRecentSearches(recent);
  }

  List<String> get popularSearches => MockData.popularSearches;

  List<ServiceEntity> _applyFilters(
    List<ServiceEntity> source,
    SearchFilters filters,
  ) {
    return source.where((s) {
      if (s.priceFrom < filters.minPrice || s.priceFrom > filters.maxPrice) {
        return false;
      }
      if (s.rating < filters.minRating) return false;
      if (filters.category != null && s.category != filters.category) {
        return false;
      }
      return true;
    }).toList();
  }
}
