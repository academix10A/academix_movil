import '../repositories/offline_repository.dart';

class DeleteOfflineUseCase {
  final OfflineRepository repository;
  DeleteOfflineUseCase(this.repository);

  Future<void> call(int idRecurso, String? urlArchivo) =>
      repository.eliminar(idRecurso, urlArchivo);
}