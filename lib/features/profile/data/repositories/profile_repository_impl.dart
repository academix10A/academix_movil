import '../../domain/repositories/profile_repository.dart';
import '../../domain/entities/profile_entity.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remote;

  ProfileRepositoryImpl(this.remote);

  @override
  Future<UserProfileEntity> getCurrentUser() {
    return remote.getCurrentUser();
  }

  @override
  Future<UserProfileEntity> updateProfile({
    String? nombre,
    String? fotoPerfil,
  }) {
    return remote.updateProfile(
      nombre: nombre,
      fotoPerfil: fotoPerfil,
    );
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword) {
    return remote.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  @override
  Future<UserStatsEntity> getUserStats() {
    return remote.getUserStats();
  }

  @override
  Future<int> getResourcesCount() {
    return remote.getResourcesCount();
  }
}

