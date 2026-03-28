import 'package:flutter/material.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/core/routes/app_routes.dart';
import 'package:academix/features/auth/presentation/viewmodel/register_viewmodel.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final RegisterViewModel vm = RegisterViewModel();

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
                  // Logo
                  Image.asset(
                    "assets/images/logo.png",
                    height: 128,
                  ),
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
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Nombre
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Nombre",
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextField(
                        controller: vm.nameController,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.text,
                        ),
                        decoration: InputDecoration(
                          hintText: "Juan",
                          hintStyle: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textMuted,
                          ),
                          filled: true,
                          fillColor: AppColors.backgroundCard,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Apellido Paterno",
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w500,
                                color: AppColors.text,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            TextField(
                              controller: vm.apellidoPaternoController,
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.text,
                              ),
                              decoration: InputDecoration(
                                hintText: "Perez",
                                hintStyle: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textMuted,
                                ),
                                filled: true,
                                fillColor: AppColors.backgroundCard,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Apellido Materno",
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w500,
                                color: AppColors.text,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            TextField(
                              controller: vm.apellidoMaternoController,
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.text,
                              ),
                              decoration: InputDecoration(
                                hintText: "Gonzalez",
                                hintStyle: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textMuted,
                                ),
                                filled: true,
                                fillColor: AppColors.backgroundCard,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Email
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Correo electrónico",
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextField(
                        controller: vm.emailController,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.text,
                        ),
                        decoration: InputDecoration(
                          hintText: "tucorreo@ejemplo.com",
                          hintStyle: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textMuted,
                          ),
                          filled: true,
                          fillColor: AppColors.backgroundCard,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Password
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Contraseña",
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextField(
                        controller: vm.passwordController,
                        obscureText: true,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.text,
                        ),
                        decoration: InputDecoration(
                          hintText: "Mínimo 8 caracteres",
                          hintStyle: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textMuted,
                          ),
                          filled: true,
                          fillColor: AppColors.backgroundCard,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Confirm Password
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Confirmar contraseña",
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextField(
                        controller: vm.confirmPasswordController,
                        obscureText: true,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.text,
                        ),
                        decoration: InputDecoration(
                          hintText: "Repite tu contraseña",
                          hintStyle: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textMuted,
                          ),
                          filled: true,
                          fillColor: AppColors.backgroundCard,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Button Register
                  ElevatedButton(
                    onPressed: vm.isLoading 
                      ? null 
                      : () async {
                          final success = await vm.register();
                          if (success && context.mounted) {
                            // Mock to main
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

                  // Link login
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
}

