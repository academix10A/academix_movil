import 'package:flutter/material.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/core/constants/app_radius.dart';
import 'package:academix/features/profile/presentation/viewmodel/settings_viewmodel.dart';

class SettingsScreen extends StatefulWidget {
  final SettingsViewModel vm;

  const SettingsScreen({super.key, required this.vm});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final SettingsViewModel _vm;

  final _nameController = TextEditingController();
  final _apellidoPaternoController = TextEditingController();
  final _apellidoMaternoController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _vm = widget.vm;
    _vm.addListener(_onVmChanged);
    _vm.loadUser().then((_) {
      if (_vm.user != null) {
        _nameController.text = _vm.user!.nombre;
        _apellidoPaternoController.text = _vm.user!.apellidoPaterno;
        _apellidoMaternoController.text = _vm.user!.apellidoMaterno;
      }
    });
  }

  void _onVmChanged() {
    if (!mounted) return;
    setState(() {});

    // Show success / error snackbars
    if (_vm.profileSuccess != null) {
      _showSnack(_vm.profileSuccess!);
    } else if (_vm.profileError != null) {
      _showSnack(_vm.profileError!, isError: true);
    }
    if (_vm.passwordSuccess != null) {
      _showSnack(_vm.passwordSuccess!);
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    } else if (_vm.passwordError != null) {
      _showSnack(_vm.passwordError!, isError: true);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : null,
      ),
    );
  }

  @override
  void dispose() {
    _vm.removeListener(_onVmChanged);
    _nameController.dispose();
    _apellidoPaternoController.dispose();
    _apellidoMaternoController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Configuración',
            style: AppTextStyles.h1.copyWith(color: AppColors.text, fontSize: 20)),
      ),
      body: _vm.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle(title: 'Información del Perfil'),
                  const SizedBox(height: AppSpacing.md),
                  _SettingsCard(children: [
                    _InputField(
                        label: 'Nombre',
                        controller: _nameController,
                        hintText: 'Ingresa tu nombre'),
                    _InputField(
                        label: 'Apellido Paterno',
                        controller: _apellidoPaternoController,
                        hintText: 'Ingresa tu apellido paterno'),
                    _InputField(
                        label: 'Apellido Materno',
                        controller: _apellidoMaternoController,
                        hintText: 'Ingresa tu apellido materno'),
                    const SizedBox(height: AppSpacing.md),
                    _InputField(
                        label: 'Correo electrónico',
                        enabled: false,
                        initialValue: _vm.user?.email ?? ''),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _vm.isSavingProfile
                            ? null
                            : () => _vm.saveProfile(
                                  nombre: _nameController.text,
                                  apellidoPaterno:
                                      _apellidoPaternoController.text,
                                  apellidoMaterno:
                                      _apellidoMaternoController.text,
                                ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.background,
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.md)),
                        ),
                        child: _vm.isSavingProfile
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Text('Guardar cambios',
                                style:
                                    TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ]),
                  const SizedBox(height: AppSpacing.xl),
                  _SectionTitle(title: 'Cambiar Contraseña'),
                  const SizedBox(height: AppSpacing.md),
                  _SettingsCard(children: [
                    _InputField(
                        label: 'Contraseña actual',
                        controller: _currentPasswordController,
                        hintText: 'Ingresa tu contraseña actual',
                        isPassword: true),
                    const SizedBox(height: AppSpacing.md),
                    _InputField(
                        label: 'Nueva contraseña',
                        controller: _newPasswordController,
                        hintText: 'Ingresa tu nueva contraseña',
                        isPassword: true),
                    const SizedBox(height: AppSpacing.md),
                    _InputField(
                        label: 'Confirmar contraseña',
                        controller: _confirmPasswordController,
                        hintText: 'Confirma tu nueva contraseña',
                        isPassword: true),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _vm.isSavingPassword
                            ? null
                            : () => _vm.savePassword(
                                  current: _currentPasswordController.text,
                                  newPass: _newPasswordController.text,
                                  confirm: _confirmPasswordController.text,
                                ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.background,
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.md)),
                        ),
                        child: _vm.isSavingPassword
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Text('Cambiar contraseña',
                                style:
                                    TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ]),
                  const SizedBox(height: AppSpacing.xl),
                  _SectionTitle(title: 'Información de la cuenta'),
                  const SizedBox(height: AppSpacing.md),
                  _SettingsCard(children: [
                    _InfoRow(
                        label: 'Rol', value: _vm.user?.roleName ?? 'Usuario'),
                    const Divider(color: AppColors.textMuted),
                    _InfoRow(
                        label: 'Miembro desde',
                        value: _vm.user?.memberSince ?? 'N/A'),
                  ]),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
    );
  }
}

// ─── Private widgets ──────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: AppTextStyles.h1.copyWith(
            color: AppColors.text, fontSize: 18, fontWeight: FontWeight.bold));
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final String? hintText;
  final String? initialValue;
  final bool enabled;
  final bool isPassword;

  const _InputField({
    required this.label,
    this.controller,
    this.hintText,
    this.initialValue,
    this.enabled = true,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          enabled: enabled,
          obscureText: isPassword,
          style: AppTextStyles.body.copyWith(color: AppColors.text),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle:
                AppTextStyles.body.copyWith(color: AppColors.textMuted),
            filled: true,
            fillColor: enabled
                ? AppColors.background
                : AppColors.backgroundCard,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: const BorderSide(color: AppColors.textMuted)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: const BorderSide(color: AppColors.textMuted)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                borderSide: const BorderSide(color: AppColors.primary)),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  AppTextStyles.body.copyWith(color: AppColors.textMuted)),
          Text(value,
              style: AppTextStyles.body.copyWith(
                  color: AppColors.text, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}