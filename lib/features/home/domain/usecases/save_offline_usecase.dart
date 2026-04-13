import '../repositories/offline_repository.dart';

class SaveOfflineUseCase {
  final OfflineRepository repository;
  SaveOfflineUseCase(this.repository);

  Future<void> call(Map<String, dynamic> recurso) =>
      repository.guardar(recurso);
}