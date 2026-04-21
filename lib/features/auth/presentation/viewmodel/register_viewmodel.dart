import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/register_user_usecase.dart';

// El ViewModel solo conoce el UseCase.
// Toda la lógica de validación de UI vive aquí — es parte de la presentación.
class RegisterViewModel extends ChangeNotifier {
  final RegisterUserUseCase _registerUseCase;

  RegisterViewModel({required RegisterUserUseCase registerUseCase})
      : _registerUseCase = registerUseCase;

  final nameController = TextEditingController();
  final apellidoPaternoController = TextEditingController();
  final apellidoMaternoController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String? errorMessage;
  bool isLoading = false;

  Future<bool> register() async {
    errorMessage = null;

    final validationError = _validate();
    if (validationError != null) {
      errorMessage = validationError;
      notifyListeners();
      return false;
    }

    isLoading = true;
    notifyListeners();

    final user = UserEntity(
      nombre: nameController.text.trim(),
      apellidoPaterno: apellidoPaternoController.text.trim(),
      apellidoMaterno: apellidoMaternoController.text.trim(),
      correo: emailController.text.trim(),
      contrasena: passwordController.text,
    );

    final success = await _registerUseCase(user);

    isLoading = false;

    if (!success) {
      errorMessage = 'Error al crear la cuenta. Verifica los datos e inténtalo más tarde.';
    }

    notifyListeners();
    return success;
  }

  String? _validate() {
    if (nameController.text.trim().isEmpty) return 'El nombre es requerido';
    if (apellidoPaternoController.text.trim().isEmpty) return 'El apellido paterno es requerido';
    if (apellidoMaternoController.text.trim().isEmpty) return 'El apellido materno es requerido';

    final email = emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) return 'Correo electrónico válido requerido';

    if (passwordController.text.length < 8) return 'La contraseña debe tener mínimo 8 caracteres';

    final passwordRegex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
    );
    if (!passwordRegex.hasMatch(passwordController.text)) {
      return 'La contraseña debe tener al menos 1 mayúscula, 1 minúscula, 1 número y 1 carácter especial';
    }

    if (passwordController.text != confirmPasswordController.text) {
      return 'Las contraseñas no coinciden';
    }

    return null;
  }

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
}