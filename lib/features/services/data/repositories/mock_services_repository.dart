import '../../../../shared/data/mock_data.dart';
import '../../domain/entities/service_entity.dart';
import '../../domain/repositories/services_repository.dart';

class MockServicesRepository implements ServicesRepository {
  @override
  Future<List<ServiceCategory>> getCategories() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return MockData.categories;
  }

  @override
  Future<List<ServiceEntity>> getServices({ServiceCategoryType? category}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (category == null) return MockData.services;
    return MockData.services.where((s) => s.category == category).toList();
  }

  @override
  Future<ServiceEntity?> getServiceById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    try {
      return MockData.services.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<ServiceEntity>> search(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return MockData.services;
    return MockData.services.where((s) {
      return s.title.toLowerCase().contains(q) ||
          s.description.toLowerCase().contains(q) ||
          s.category.label.toLowerCase().contains(q);
    }).toList();
  }
}
