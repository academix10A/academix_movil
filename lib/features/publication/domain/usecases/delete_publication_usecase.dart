import '../repositories/publication_repository.dart';

class DeletePublicationUseCase {
  final PublicationRepository repository;

  const DeletePublicationUseCase(this.repository);

  Future<void> call(int id) async {
    await repository.deletePublication(id);
  }
}
