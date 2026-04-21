import '../entities/library_resource_entity.dart';
import '../entities/tema_resource_entity.dart';

abstract class LibraryRepository {
  Future<List<LibraryResourceEntity>> getResources();
  Future<LibraryResourceEntity> getResourceById(int id);
  Future<List<LibraryResourceEntity>> searchResources(String query);
  Future<List<LibraryResourceEntity>> getFavorites(int idUsuario);
  Future<void> postFavorite(int idUsuario, int idRecurso);
  Future<void> deleteFavorite(int idUsuario, int idRecurso);
  Future<List<TemaResourceEntity>> getResourcesFromTemas();
}