import '../entities/publication_entity.dart';
import '../repositories/publication_repository.dart';

class CreatePublicationUseCase {
  final PublicationRepository repository;

  const CreatePublicationUseCase(this.repository);

  Future<PublicationEntity> call(Map<String, dynamic> data) async {
    return await repository.createPublication(data);
  }
}
