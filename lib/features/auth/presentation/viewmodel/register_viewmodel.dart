import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/register_user_usecase.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';

class RegisterViewModel extends ChangeNotifier {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController apellidoPaternoController = TextEditingController();
  final TextEditingController apellidoMaternoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  String? errorMessage;
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    apellidoPaternoController.dispose();
    apellidoMaternoController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<bool> register() async {
    errorMessage = null;
    isLoading = true;
    notifyListeners();

    // Validation
    if (nameController.text.trim().isEmpty) {
      errorMessage = 'El nombre es requerido';
      isLoading = false;
      notifyListeners();
      return false;
    }
    if (apellidoPaternoController.text.trim().isEmpty) {
      errorMessage = 'El apellido paterno es requerido';
      isLoading = false;
      notifyListeners();
      return false;
    }
    if (apellidoMaternoController.text.trim().isEmpty) {
      errorMessage = 'El apellido materno es requerido';
      isLoading = false;
      notifyListeners();
      return false;
    }
    if (emailController.text.trim().isEmpty || !emailController.text.trim().contains('@')) {
      errorMessage = 'Correo electrónico válido requerido';
      isLoading = false;
      notifyListeners();
      return false;
    }
    if (passwordController.text.length < 8) {
      errorMessage = 'La contraseña debe tener mínimo 8 caracteres';
      isLoading = false;
      notifyListeners();
      return false;
    }
    final RegExp passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
    if (!passwordRegex.hasMatch(passwordController.text)) {
      errorMessage = 'La contraseña debe tener al menos 1 mayúscula, 1 minúscula, 1 número y 1 carácter especial';
      isLoading = false;
      notifyListeners();
      return false;
    }
    if (passwordController.text != confirmPasswordController.text) {
      errorMessage = 'Las contraseñas no coinciden';
      isLoading = false;
      notifyListeners();
      return false;
    }

    // API call
    final remoteDataSource = AuthRemoteDataSource();
    final repository = AuthRepositoryImpl(remoteDataSource);
    final registerUseCase = RegisterUserUseCase(repository);

    final user = UserEntity(
      nombre: nameController.text.trim(),
      apellidoPaterno: apellidoPaternoController.text.trim(),
      apellidoMaterno: apellidoMaternoController.text.trim(),
      correo: emailController.text.trim(),
      contrasena: passwordController.text,
    );

    bool success;
    try {
      success = await registerUseCase(user);
    } on DioException catch (e) {
      success = false;
      errorMessage = e.response?.data['detail']?.toString() ?? 'Error del servidor';
    } catch (e) {
      success = false;
      errorMessage = 'Error de conexión';
    }

    isLoading = false;
    notifyListeners();

    if (!success) {
      errorMessage ??= 'Error al crear la cuenta. Verifica los datos e inténtalo más tarde.';
    }

    return success;
  }
}
