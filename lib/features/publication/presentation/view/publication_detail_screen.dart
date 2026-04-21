// publication/presentation/view/publication_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/core/constants/app_radius.dart';
import 'package:academix/core/routes/app_routes.dart';
import 'package:academix/features/publication/domain/entities/publication_entity.dart';
import 'package:academix/features/publication/presentation/viewmodel/create_edit_publication_viewmodel.dart';
import 'package:academix/features/publication/presentation/viewmodel/publication_di.dart';

class PublicationDetailScreen extends StatefulWidget {
  final PublicationEntity publication;

  const PublicationDetailScreen({super.key, required this.publication});

  @override
  State<PublicationDetailScreen> createState() =>
      _PublicationDetailScreenState();
}

class _PublicationDetailScreenState extends State<PublicationDetailScreen> {
  late final CreateEditPublicationViewModel _vm;

  bool _isEditing = false;
  bool _isLoading = false;

  static const List<Color> _accentColors = [
    Color(0xFFE8C547),
    Color(0xFF4CAF50),
    Color(0xFF2196F3),
    Color(0xFFFF5722),
    Color(0xFF9C27B0),
  ];

  Color get _accent =>
      _accentColors[widget.publication.id % _accentColors.length];

  @override
  void initState() {
    super.initState();
    _vm = PublicationDI.createEditPublicationViewModel();
    _vm.loadPublication(widget.publication);
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  String get _timeAgo {
    final diff = DateTime.now().difference(widget.publication.fechaCreacion);
    if (diff.inDays >= 365) return 'hace ${(diff.inDays / 365).floor()} año(s)';
    if (diff.inDays >= 30)  return 'hace ${(diff.inDays / 30).floor()} mes(es)';
    if (diff.inDays >= 1)   return 'hace ${diff.inDays} día(s)';
    if (diff.inHours >= 1)  return 'hace ${diff.inHours} hora(s)';
    if (diff.inMinutes >= 1) return 'hace ${diff.inMinutes} minuto(s)';
    return 'justo ahora';
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    try {
      final success = await _vm.updatePublication(widget.publication.id);
      if (mounted && success) {
        setState(() => _isEditing = false);
        AppNavigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md)),
        title: Text('¿Eliminar publicación?',
            style: AppTextStyles.h2.copyWith(color: AppColors.text)),
        content: Text(
          'Esta acción no se puede deshacer.',
          style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar',
                style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              AppNavigator.pop(context); // regresa al listado con señal
            },
            child: Text('Eliminar',
                style: AppTextStyles.body.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              child: Row(
                children: [
                  // Botón atrás
                  GestureDetector(
                    onTap: () => AppNavigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundCard,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: AppColors.text, size: 22),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),

                  // Badge autor
                  if (widget.publication.usuarioNombre != null &&
                      widget.publication.usuarioNombre!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: _accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: Border.all(color: _accent.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person_outline_rounded,
                              size: 14, color: _accent),
                          const SizedBox(width: 4),
                          Text(
                            widget.publication.usuarioNombre!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: _accent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const Spacer(),

                  // Botón editar / guardar
                  ValueListenableBuilder<bool>(
                    valueListenable: _vm.isLoading,
                    builder: (context, vmLoading, _) {
                      final loading = _isLoading || vmLoading;
                      return GestureDetector(
                        onTap: loading
                            ? null
                            : () async {
                                if (_isEditing) {
                                  await _saveChanges();
                                } else {
                                  setState(() => _isEditing = true);
                                }
                              },
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: _isEditing
                                ? AppColors.success
                                : AppColors.backgroundCard,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                )
                              : Icon(
                                  _isEditing
                                      ? Icons.check_rounded
                                      : Icons.edit_outlined,
                                  color: _isEditing
                                      ? AppColors.background
                                      : AppColors.text,
                                  size: 22,
                                ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // ── Contenido scrollable ──────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tiempo relativo
                    Text(
                      _timeAgo,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Título — editable o display
                    if (_isEditing)
                      TextField(
                        controller: _vm.tituloController,
                        style: AppTextStyles.h1.copyWith(
                            color: AppColors.primary, fontSize: 26),
                        decoration: InputDecoration(
                          hintText: 'Título de la publicación',
                          hintStyle: AppTextStyles.h1.copyWith(
                              color: AppColors.textMuted, fontSize: 26),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        maxLines: null,
                      )
                    else
                      Text(
                        widget.publication.titulo,
                        style: AppTextStyles.h1.copyWith(
                            color: AppColors.primary, fontSize: 26),
                      ),

                    const SizedBox(height: AppSpacing.md),

                    // Etiquetas
                    if (_isEditing) ...[
                      Text(
                        'Etiquetas (separadas por comas)',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textMuted),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundCard,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                              color: _accent.withOpacity(0.35), width: 1.5),
                        ),
                        child: TextField(
                          controller: _vm.etiquetasController,
                          style: AppTextStyles.body
                              .copyWith(color: AppColors.text),
                          decoration: InputDecoration(
                            hintText: 'ej. matemáticas, cálculo',
                            hintStyle: AppTextStyles.body
                                .copyWith(color: AppColors.textMuted),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                        ),
                      ),
                    ] else if (widget.publication.etiquetas != null &&
                        widget.publication.etiquetas!.isNotEmpty)
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: widget.publication.etiquetas!
                            .map(
                              (tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.15),
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.full),
                                ),
                                child: Text(
                                  '#$tag',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),

                    const SizedBox(height: AppSpacing.lg),

                    // Descripción — editable o display
                    if (_isEditing) ...[
                      Text(
                        'Descripción',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textMuted),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundCard,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                              color: _accent.withOpacity(0.35), width: 1.5),
                        ),
                        child: TextField(
                          controller: _vm.descripcionController,
                          maxLines: 3,
                          minLines: 2,
                          style: AppTextStyles.body
                              .copyWith(color: AppColors.text),
                          decoration: InputDecoration(
                            hintText: 'Descripción breve...',
                            hintStyle: AppTextStyles.body
                                .copyWith(color: AppColors.textMuted),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ] else if (widget.publication.descripcion.isNotEmpty)
                      Text(
                        widget.publication.descripcion,
                        style: AppTextStyles.body.copyWith(
                            color: AppColors.textMuted, height: 1.5),
                      ),

                    const SizedBox(height: AppSpacing.xl),

                    // Divider accent
                    Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _accent.withOpacity(0.5),
                            _accent.withOpacity(0),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    Text(
                      'Contenido',
                      style: AppTextStyles.h2
                          .copyWith(color: AppColors.text, fontSize: 18),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Texto — editable o display
                    if (_isEditing)
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundCard,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: _accent.withOpacity(0.4),
                            width: 1.5,
                          ),
                        ),
                        child: TextField(
                          controller: _vm.textoController,
                          maxLines: null,
                          minLines: 10,
                          style: AppTextStyles.body
                              .copyWith(color: AppColors.text, height: 1.6),
                          decoration: InputDecoration(
                            hintText: 'Escribe tu publicación aquí...',
                            hintStyle: AppTextStyles.body
                                .copyWith(color: AppColors.textMuted),
                            border: InputBorder.none,
                          ),
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundCard,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: _accent.withOpacity(0.25),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          widget.publication.texto,
                          style: AppTextStyles.body.copyWith(
                              color: AppColors.text, height: 1.8),
                        ),
                      ),

                    // Error del viewmodel
                    ValueListenableBuilder<String?>(
                      valueListenable: _vm.error,
                      builder: (context, errorMsg, _) {
                        if (errorMsg == null) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.md),
                          child: Text(
                            errorMsg,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),

                    // Opciones en modo edición
                    if (_isEditing) ...[
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'Opciones',
                        style: AppTextStyles.h2
                            .copyWith(color: AppColors.text, fontSize: 16),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _OptionButton(
                        icon: Icons.delete_outline_rounded,
                        label: 'Eliminar publicación',
                        isDestructive: true,
                        onTap: _showDeleteConfirmation,
                      ),
                    ],

                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Widgets auxiliares ───────────────────────────────────────────────────────

class _OptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _OptionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.text;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: AppSpacing.md),
            Text(label, style: AppTextStyles.body.copyWith(color: color)),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}