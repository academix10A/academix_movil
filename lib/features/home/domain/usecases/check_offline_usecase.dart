import '../repositories/offline_repository.dart';

class CheckOfflineUseCase {
  final OfflineRepository repository;
  CheckOfflineUseCase(this.repository);

  Future<bool> call(int idRecurso) => repository.estaGuardado(idRecurso);
}