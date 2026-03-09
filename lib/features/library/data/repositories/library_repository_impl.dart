import '../../domain/repositories/library_repository.dart';
import '../../domain/entities/library_entity.dart';
import '../datasources/library_remote_datasource.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  final LibraryRemoteDataSource remote;

  LibraryRepositoryImpl(this.remote);

  @override
  Future<List<LibraryResourceEntity>> getResources() {
    return remote.getResources();
  }

  @override
  Future<LibraryResourceEntity> getResourceById(int id) {
    return remote.getResourceById(id);
  }

  @override
  Future<List<LibraryResourceEntity>> searchResources(String query) {
    return remote.searchResources(query);
  }
}

