import '../../domain/entities/publication_entity.dart';
import '../../domain/repositories/publication_repository.dart';
import '../datasources/publication_remote_datasource.dart';

class PublicationRepositoryImpl implements PublicationRepository {
  final PublicationRemoteDataSource remote;

  const PublicationRepositoryImpl(this.remote);

  @override
  Future<List<PublicationEntity>> getMyPublications() async {
    final models = await remote.getMyPublications();
    return models.map((model) => model.entity).toList();
  }

  @override
  Future<PublicationEntity> createPublication(Map<String, dynamic> data) async {
    final model = await remote.createPublication(data);
    return model.entity;
  }

  @override
  Future<PublicationEntity> updatePublication(int id, Map<String, dynamic> data) async {
    final model = await remote.updatePublication(id, data);
    return model.entity;
  }

  @override
  Future<void> deletePublication(int id) async {
    await remote.deletePublication(id);
  }
}
