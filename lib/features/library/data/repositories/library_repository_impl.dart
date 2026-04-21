import '../../domain/entities/library_resource_entity.dart';
import '../../domain/entities/tema_resource_entity.dart';
import '../../domain/repositories/library_repository.dart';
import '../datasources/library_remote_datasource.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  final LibraryRemoteDataSource remote;

  LibraryRepositoryImpl(this.remote);

  @override
  Future<List<LibraryResourceEntity>> getResources() async {
    final models = await remote.getResources();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<LibraryResourceEntity> getResourceById(int id) async {
    final model = await remote.getRecursoById(id);
    return model.toEntity();
  }

  @override
  Future<List<LibraryResourceEntity>> searchResources(String query) async {
    final models = await remote.searchResources(query);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<LibraryResourceEntity>> getFavorites(int idUsuario) async {
    final models = await remote.getFavorites(idUsuario);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> postFavorite(int idUsuario, int idRecurso) {
    return remote.postFavorite(idUsuario, idRecurso);
  }

  @override
  Future<void> deleteFavorite(int idUsuario, int idRecurso) {
    return remote.deleteFavorite(idUsuario, idRecurso);
  }

  @override
  Future<List<TemaResourceEntity>> getResourcesFromTemas() async {
    final models = await remote.getResourcesFromTemas();
    return models.map((m) => m.toEntity()).toList();
  }
}