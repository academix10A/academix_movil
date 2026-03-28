import '../entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<UserProfileEntity> getCurrentUser();
  Future<UserProfileEntity> updateProfile({
    String? nombre,
    String? fotoPerfil,
  });
  Future<void> changePassword(String currentPassword, String newPassword);
  Future<UserStatsEntity> getUserStats();
  Future<int> getResourcesCount();
  Future<int> getNoteCount();
}

