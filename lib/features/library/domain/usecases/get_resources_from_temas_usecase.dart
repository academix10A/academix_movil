import '../entities/tema_resource_entity.dart';
import '../repositories/library_repository.dart';

class GetResourcesFromTemasUseCase {
  final LibraryRepository repository;

  GetResourcesFromTemasUseCase(this.repository);

  Future<List<TemaResourceEntity>> call() {
    return repository.getResourcesFromTemas();
  }
}