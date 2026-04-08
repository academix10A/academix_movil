import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class GetCurrentUserUseCase {
  final ProfileRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<UserProfileEntity> call() {
    return repository.getCurrentUser();
  }
}