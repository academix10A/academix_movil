import '../entities/publication_entity.dart';
import '../repositories/publication_repository.dart';

class UpdatePublicationUseCase {
  final PublicationRepository repository;

  const UpdatePublicationUseCase(this.repository);

  Future<PublicationEntity> call(int id, Map<String, dynamic> data) async {
    return await repository.updatePublication(id, data);
  }
}
