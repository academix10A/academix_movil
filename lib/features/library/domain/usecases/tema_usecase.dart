import '../entities/tema_resource_entity.dart';
import '../repositories/library_repository.dart';

/// Gets all resources grouped by tema/subtema.
class GetResourcesFromTemasUseCase {
  final LibraryRepository repository;
  GetResourcesFromTemasUseCase(this.repository);
  Future<List<TemaResourceEntity>> call() => repository.getResourcesFromTemas();
}