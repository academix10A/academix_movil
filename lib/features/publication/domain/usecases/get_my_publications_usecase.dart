import '../entities/publication_entity.dart';
import '../repositories/publication_repository.dart';

class GetMyPublicationsUseCase {
  final PublicationRepository repository;

  const GetMyPublicationsUseCase(this.repository);

  Future<List<PublicationEntity>> call() async {
    return await repository.getMyPublications();
  }
}
