import '../entities/profile_entity.dart';
import '../entities/membresia_entity.dart';

abstract class ProfileRepository {
  Future<UserProfileEntity> getCurrentUser();

  Future<UserProfileEntity> updateProfile({
    String? nombre,
    String? apellidoPaterno,
    String? apellidoMaterno,
  });

  Future<void> changePassword(String currentPassword, String newPassword);

  Future<UserStatsEntity> getUserStats();

  Future<int> getResourcesCount();

  Future<int> getNoteCount();

  // --- Membership ---

  Future<List<Membresia>> getMembresias();

  Future<void> activarMembresia(int idMembresia);

  Future<Map<String, dynamic>> createPaypalOrder(int idMembresia);

  Future<void> capturePaypalOrder(String orderId, int idMembresia);
}