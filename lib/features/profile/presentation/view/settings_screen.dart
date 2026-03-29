import 'package:flutter/material.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/core/constants/app_radius.dart';
import 'package:academix/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:academix/features/profile/domain/entities/profile_entity.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ProfileRemoteDataSource _dataSource = ProfileRemoteDataSource();
  UserProfileEntity? _user;
  bool _isLoading = true;
  
  // Form controllers
  final _nameController = TextEditingController();
  final _apellidoPaternoController = TextEditingController();
  final _apellidoMaternoController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await _dataSource.getCurrentUser();
      setState(() {
        _user = user;
        _nameController.text = user.userName;
        _apellidoPaternoController.text = user.apellidoPaterno;
        _apellidoMaternoController.text = user.apellidoMaterno;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cargar datos del usuario')),
        );
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre no puede estar vacío')),
      );
      return;
    }

    if (_apellidoPaternoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El apellido paterno no puede estar vacío')),
      );
      return;
    }

    if (_apellidoMaternoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El apellido materno no puede estar vacío')),
      );
      return;
    }

    try {
      await _dataSource.updateProfile(nombre: _nameController.text, apellidoPaterno: _apellidoPaternoController.text, apellidoMaterno: _apellidoMaternoController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado correctamente')),
        );
        _loadUserData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al actualizar el perfil')),
        );
      }
    }
  }

  Future<void> _changePassword() async {
    if (_currentPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor complete todos los campos')),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden')),
      );
      return;
    }

    if (_newPasswordController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La contraseña debe tener al menos 8 caracteres')),
      );
      return;
    }

    try {
      await _dataSource.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contraseña cambiada correctamente')),
        );
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cambiar la contraseña')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
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
        title: Text(
          'Configuración',
          style: AppTextStyles.h1.copyWith(
            color: AppColors.text,
            fontSize: 20,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Section
                  _SectionTitle(title: 'Información del Perfil'),
                  const SizedBox(height: AppSpacing.md),
                  
                  _SettingsCard(
                    children: [
                      _InputField(
                        label: 'Nombre',
                        controller: _nameController,
                        hintText: 'Ingresa tu nombre',
                      ),
                      _InputField(
                        label: 'Apellido Paterno',
                        controller: _apellidoPaternoController,
                        hintText: 'Ingresa tu apellido paterno',
                      ),
                      _InputField(
                        label: 'Apellido Materno',
                        controller: _apellidoMaternoController,
                        hintText: 'Ingresa tu nombre',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _InputField(
                        label: 'Correo electrónico',
                        enabled: false,
                        initialValue: _user?.email ?? '',
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _updateProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.background,
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                          ),
                          child: const Text(
                            'Guardar cambios',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Password Section
                  _SectionTitle(title: 'Cambiar Contraseña'),
                  const SizedBox(height: AppSpacing.md),
                  
                  _SettingsCard(
                    children: [
                      _InputField(
                        label: 'Contraseña actual',
                        controller: _currentPasswordController,
                        hintText: 'Ingresa tu contraseña actual',
                        isPassword: true,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _InputField(
                        label: 'Nueva contraseña',
                        controller: _newPasswordController,
                        hintText: 'Ingresa tu nueva contraseña',
                        isPassword: true,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _InputField(
                        label: 'Confirmar contraseña',
                        controller: _confirmPasswordController,
                        hintText: 'Confirma tu nueva contraseña',
                        isPassword: true,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _changePassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.background,
                            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                          ),
                          child: const Text(
                            'Cambiar contraseña',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // // Notifications Section
                  // _SectionTitle(title: 'Notificaciones'),
                  // const SizedBox(height: AppSpacing.md),
                  
                  // _SettingsCard(
                  //   children: [
                  //     _SettingsToggle(
                  //       title: 'Notificaciones push',
                  //       subtitle: 'Recibe notificaciones en tu dispositivo',
                  //       value: true,
                  //       onChanged: (value) {
                  //         // TODO: Implement notification toggle
                  //       },
                  //     ),
                  //     const Divider(color: AppColors.textMuted),
                  //     _SettingsToggle(
                  //       title: 'Notificaciones de exámenes',
                  //       subtitle: 'Te notificamos cuando haya nuevos exámenes',
                  //       value: true,
                  //       onChanged: (value) {
                  //         // TODO: Implement notification toggle
                  //       },
                  //     ),
                  //     const Divider(color: AppColors.textMuted),
                  //     _SettingsToggle(
                  //       title: 'Notificaciones de recursos',
                  //       subtitle: 'Te notify when new resources are available',
                  //       value: false,
                  //       onChanged: (value) {
                  //         // TODO: Implement notification toggle
                  //       },
                  //     ),
                  //   ],
                  // ),

                  // const SizedBox(height: AppSpacing.xl),

                  // Account Info
                  _SectionTitle(title: 'Información de la cuenta'),
                  const SizedBox(height: AppSpacing.md),
                  
                  _SettingsCard(
                    children: [
                      _InfoRow(
                        label: 'Rol',
                        value: _user?.roleName ?? 'Usuario',
                      ),
                      const Divider(color: AppColors.textMuted),
                      _InfoRow(
                        label: 'Miembro desde',
                        value: _user?.memberSince ?? 'N/A',
                      ),
                      // const Divider(color: AppColors.textMuted),
                      // _InfoRow(
                      //   label: 'Último acceso',
                      //   value: _user?.lastAccess ?? 'N/A',
                      // ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.h1.copyWith(
        color: AppColors.text,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
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
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          enabled: enabled,
          obscureText: isPassword,
          style: AppTextStyles.body.copyWith(color: AppColors.text),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTextStyles.body.copyWith(color: AppColors.textMuted),
            filled: true,
            fillColor: enabled ? AppColors.background : AppColors.backgroundCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              borderSide: const BorderSide(color: AppColors.textMuted),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              borderSide: const BorderSide(color: AppColors.textMuted),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsToggle extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsToggle({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.body.copyWith(
              color: AppColors.text,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

