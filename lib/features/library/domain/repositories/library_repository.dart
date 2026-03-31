import '../entities/library_entity.dart';

abstract class LibraryRepository {
  Future<List<LibraryResourceEntity>> getResources();
  Future<LibraryResourceEntity> getResourceById(int id);
  Future<List<LibraryResourceEntity>> searchResources(String query);
  Future<List<LibraryResourceEntity>> getFavorites(int idUsuario);
}

