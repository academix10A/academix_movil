import '../entities/library_resource_entity.dart';
import '../repositories/library_repository.dart';

/// Gets a single resource by ID.
class GetResourceByIdUseCase {
  final LibraryRepository repository;
  GetResourceByIdUseCase(this.repository);
  Future<LibraryResourceEntity> call(int id) => repository.getResourceById(id);
}

/// Gets all resources (flat list).
class GetResourcesUseCase {
  final LibraryRepository repository;
  GetResourcesUseCase(this.repository);
  Future<List<LibraryResourceEntity>> call() => repository.getResources();
}