import '../entities/library_resource_entity.dart';
import '../repositories/library_repository.dart';

class GetFavoritesUseCase {
  final LibraryRepository repository;

  GetFavoritesUseCase(this.repository);

  Future<List<LibraryResourceEntity>> call(int idUsuario) {
    return repository.getFavorites(idUsuario);
  }
}