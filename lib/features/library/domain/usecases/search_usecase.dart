import '../entities/library_resource_entity.dart';
import '../repositories/library_repository.dart';

class SearchResourcesUseCase {
  final LibraryRepository repository;

  SearchResourcesUseCase(this.repository);

  Future<List<LibraryResourceEntity>> call(String query) {
    return repository.searchResources(query);
  }
}