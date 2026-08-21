import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/mock_services_repository.dart';
import '../../domain/entities/service_entity.dart';
import '../../domain/repositories/services_repository.dart';

final servicesRepositoryProvider = Provider<ServicesRepository>((ref) {
  return MockServicesRepository();
});

final categoriesProvider = FutureProvider<List<ServiceCategory>>((ref) {
  return ref.watch(servicesRepositoryProvider).getCategories();
});

final servicesListProvider = FutureProvider<List<ServiceEntity>>((ref) {
  return ref.watch(servicesRepositoryProvider).getServices();
});

final serviceByIdProvider =
    FutureProvider.family<ServiceEntity?, String>((ref, id) {
  return ref.watch(servicesRepositoryProvider).getServiceById(id);
});

final servicesByCategoryProvider =
    FutureProvider.family<List<ServiceEntity>, ServiceCategoryType?>(
        (ref, category) {
  return ref.watch(servicesRepositoryProvider).getServices(category: category);
});
