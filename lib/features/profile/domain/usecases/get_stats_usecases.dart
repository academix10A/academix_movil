import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class GetUserStatsUseCase {
  final ProfileRepository repository;

  GetUserStatsUseCase(this.repository);

  Future<UserStatsEntity> call() {
    return repository.getUserStats();
  }
}

class GetResourcesCountUseCase {
  final ProfileRepository repository;

  GetResourcesCountUseCase(this.repository);

  Future<int> call() {
    return repository.getResourcesCount();
  }
}

class GetNoteCountUseCase {
  final ProfileRepository repository;

  GetNoteCountUseCase(this.repository);

  Future<int> call() {
    return repository.getNoteCount();
  }
}