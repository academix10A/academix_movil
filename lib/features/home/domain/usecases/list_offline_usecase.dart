import '../entities/offline_entity.dart';
import '../repositories/offline_repository.dart';

class ListOfflineUseCase {
  final OfflineRepository repository;
  ListOfflineUseCase(this.repository);

  Future<List<OfflineEntity>> call() => repository.listarTodos();
}