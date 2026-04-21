import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<UserProfileEntity> call({
    String? nombre,
    String? apellidoPaterno,
    String? apellidoMaterno,
  }) {
    return repository.updateProfile(
      nombre: nombre,
      apellidoPaterno: apellidoPaterno,
      apellidoMaterno: apellidoMaterno,
    );
  }
}