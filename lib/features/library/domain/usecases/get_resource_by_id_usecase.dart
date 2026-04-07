import '../entities/library_resource_entity.dart';
import '../repositories/library_repository.dart';

class GetResourceByIdUseCase {
  final LibraryRepository repository;

  GetResourceByIdUseCase(this.repository);

  Future<LibraryResourceEntity> call(int id) {
    return repository.getResourceById(id);
  }
}