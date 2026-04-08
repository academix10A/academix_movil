import '../../domain/repositories/profile_repository.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/entities/membresia_entity.dart';
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
    String? apellidoPaterno,
    String? apellidoMaterno,
  }) {
    return remote.updateProfile(
      nombre: nombre,
      apellidoPaterno: apellidoPaterno,
      apellidoMaterno: apellidoMaterno,
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

  @override
  Future<int> getNoteCount() {
    return remote.getNoteCount();
  }

  @override
  Future<List<Membresia>> getMembresias() {
    return remote.getMembresias();
  }

  @override
  Future<void> activarMembresia(int idMembresia) {
    return remote.activarMembresia(idMembresia);
  }

  @override
  Future<Map<String, dynamic>> createPaypalOrder(int idMembresia) {
    return remote.createPaypalOrder(idMembresia);
  }

  @override
  Future<void> capturePaypalOrder(String orderId, int idMembresia) {
    return remote.capturePaypalOrder(orderId, idMembresia);
  }
}