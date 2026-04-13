import '../entities/publication_entity.dart';

abstract class PublicationRepository {
  Future<List<PublicationEntity>> getMyPublications();
  Future<PublicationEntity> createPublication(Map<String, dynamic> data);
  Future<PublicationEntity> updatePublication(int id, Map<String, dynamic> data);
  Future<void> deletePublication(int id);
}
