import 'package:flutter/material.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/change_password_usecase.dart';

class SettingsViewModel extends ChangeNotifier {
  final GetCurrentUserUseCase _getCurrentUser;
  final UpdateProfileUseCase _updateProfile;
  final ChangePasswordUseCase _changePassword;

  SettingsViewModel({
    required GetCurrentUserUseCase getCurrentUser,
    required UpdateProfileUseCase updateProfile,
    required ChangePasswordUseCase changePassword,
  })  : _getCurrentUser = getCurrentUser,
        _updateProfile = updateProfile,
        _changePassword = changePassword;

  UserProfileEntity? _user;
  bool _isLoading = true;
  bool _isSavingProfile = false;
  bool _isSavingPassword = false;
  String? _profileError;
  String? _passwordError;
  String? _profileSuccess;
  String? _passwordSuccess;

  UserProfileEntity? get user => _user;
  bool get isLoading => _isLoading;
  bool get isSavingProfile => _isSavingProfile;
  bool get isSavingPassword => _isSavingPassword;
  String? get profileError => _profileError;
  String? get passwordError => _passwordError;
  String? get profileSuccess => _profileSuccess;
  String? get passwordSuccess => _passwordSuccess;

  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _getCurrentUser();
    } catch (_) {
      _profileError = 'Error al cargar datos del usuario';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveProfile({
    required String nombre,
    required String apellidoPaterno,
    required String apellidoMaterno,
  }) async {
    _profileError = null;
    _profileSuccess = null;

    if (nombre.isEmpty) {
      _profileError = 'El nombre no puede estar vacío';
      notifyListeners();
      return;
    }
    if (apellidoPaterno.isEmpty) {
      _profileError = 'El apellido paterno no puede estar vacío';
      notifyListeners();
      return;
    }
    if (apellidoMaterno.isEmpty) {
      _profileError = 'El apellido materno no puede estar vacío';
      notifyListeners();
      return;
    }

    _isSavingProfile = true;
    notifyListeners();

    try {
      _user = await _updateProfile(
        nombre: nombre,
        apellidoPaterno: apellidoPaterno,
        apellidoMaterno: apellidoMaterno,
      );
      _profileSuccess = 'Perfil actualizado correctamente';
    } catch (_) {
      _profileError = 'Error al actualizar el perfil';
    } finally {
      _isSavingProfile = false;
      notifyListeners();
    }
  }

  Future<void> savePassword({
    required String current,
    required String newPass,
    required String confirm,
  }) async {
    _passwordError = null;
    _passwordSuccess = null;

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      _passwordError = 'Por favor complete todos los campos';
      notifyListeners();
      return;
    }
    if (newPass != confirm) {
      _passwordError = 'Las contraseñas no coinciden';
      notifyListeners();
      return;
    }
    if (newPass.length < 8) {
      _passwordError = 'La contraseña debe tener al menos 8 caracteres';
      notifyListeners();
      return;
    }

    _isSavingPassword = true;
    notifyListeners();

    try {
      await _changePassword(currentPassword: current, newPassword: newPass);
      _passwordSuccess = 'Contraseña cambiada correctamente';
    } catch (_) {
      _passwordError = 'Error al cambiar la contraseña';
    } finally {
      _isSavingPassword = false;
      notifyListeners();
    }
  }
}