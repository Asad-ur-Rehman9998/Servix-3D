import '../entities/service_entity.dart';

abstract class ServicesRepository {
  Future<List<ServiceCategory>> getCategories();
  Future<List<ServiceEntity>> getServices({ServiceCategoryType? category});
  Future<ServiceEntity?> getServiceById(String id);
  Future<List<ServiceEntity>> search(String query);
}
