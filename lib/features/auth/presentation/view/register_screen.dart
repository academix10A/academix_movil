import 'package:flutter/material.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/core/routes/app_routes.dart';
import 'package:academix/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:academix/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:academix/features/auth/domain/usecases/register_user_usecase.dart';
import 'package:academix/features/auth/presentation/viewmodel/register_viewmodel.dart';

RegisterViewModel _buildViewModel() {
  final remote = AuthRemoteDataSource();
  final repository = AuthRepositoryImpl(remote);
  return RegisterViewModel(registerUseCase: RegisterUserUseCase(repository));
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final RegisterViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = _buildViewModel();
  }

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height
                - MediaQuery.of(context).padding.top
                - MediaQuery.of(context).padding.bottom
                - 48,
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset("assets/images/logo.png", height: 128),
                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    "Regístrate en Academix",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.h1.copyWith(color: AppColors.text),
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  Text(
                    "Crea tu cuenta gratis",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  _buildLabel("Nombre"),
                  const SizedBox(height: AppSpacing.sm),
                  _buildTextField(controller: vm.nameController, hint: "Juan"),
                  const SizedBox(height: AppSpacing.lg),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Apellido Paterno"),
                            const SizedBox(height: AppSpacing.sm),
                            _buildTextField(
                              controller: vm.apellidoPaternoController,
                              hint: "Perez",
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Apellido Materno"),
                            const SizedBox(height: AppSpacing.sm),
                            _buildTextField(
                              controller: vm.apellidoMaternoController,
                              hint: "Gonzalez",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  _buildLabel("Correo electrónico"),
                  const SizedBox(height: AppSpacing.sm),
                  _buildTextField(
                    controller: vm.emailController,
                    hint: "tucorreo@ejemplo.com",
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  _buildLabel("Contraseña"),
                  const SizedBox(height: AppSpacing.sm),
                  _buildTextField(
                    controller: vm.passwordController,
                    hint: "Mínimo 8 caracteres",
                    obscure: true,
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  _buildLabel("Confirmar contraseña"),
                  const SizedBox(height: AppSpacing.sm),
                  _buildTextField(
                    controller: vm.confirmPasswordController,
                    hint: "Repite tu contraseña",
                    obscure: true,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  ElevatedButton(
                    onPressed: vm.isLoading
                        ? null
                        : () async {
                            final success = await vm.register();
                            if (success && context.mounted) {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                AppRoutes.main,
                                (route) => false,
                              );
                            } else {
                              setState(() {});
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.background,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: vm.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            "Crear Cuenta",
                            style: AppTextStyles.body.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "¿Ya tienes cuenta? ",
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          "Inicia sesión",
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (vm.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        vm.errorMessage!,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
    text,
    style: AppTextStyles.bodySmall.copyWith(
      fontWeight: FontWeight.w500,
      color: AppColors.text,
    ),
  );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
  }) =>
      TextField(
        controller: controller,
        obscureText: obscure,
        style: AppTextStyles.body.copyWith(color: AppColors.text),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
          filled: true,
          fillColor: AppColors.backgroundCard,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      );
}