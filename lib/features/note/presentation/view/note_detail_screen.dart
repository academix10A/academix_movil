import 'package:flutter/material.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/core/constants/app_radius.dart';
import 'package:academix/core/routes/app_routes.dart';
import 'package:academix/features/note/presentation/viewmodel/notes_viewmodel.dart';

class NoteDetailScreen extends StatefulWidget {
  final NoteItem note;

  const NoteDetailScreen({super.key, required this.note});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isEditing = false;
  late final NotesViewModel vm;

  @override
  void initState() {
    super.initState();
    vm = NotesViewModel();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    // vm.dispose() called by list screen or gc
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
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
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.text,
                        size: 22,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Badge de compartida
                  if (widget.note.isShared)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: Border.all(
                          color: AppColors.accent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.people_outline_rounded,
                            size: 14,
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Compartida",
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(width: AppSpacing.sm),
                  // Botón editar/guardar
                  GestureDetector(
                    onTap: () async {
                      setState(() {
                        _isEditing = !_isEditing;
                      });
                      if (!_isEditing) {
                        // Guardar cambios
                        await vm.updateNote(
                          widget.note.idNota!,
                          _titleController.text,
                          _contentController.text,
                          esCompartida: widget.note.isShared,
                        );
                        AppNavigator.pop(context);
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
                      child: Icon(
                        _isEditing
                            ? Icons.check_rounded
                            : Icons.edit_outlined,
                        color: _isEditing
                            ? AppColors.background
                            : AppColors.text,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Contenido scrollable
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fecha
                    Text(
                      widget.note.timeAgo,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Título (editable)
                    if (_isEditing)
                      TextField(
                        controller: _titleController,
                        style: AppTextStyles.h1.copyWith(
                          color: AppColors.primary,
                          fontSize: 24,
                        ),
                        decoration: InputDecoration(
                          hintText: "Título de la nota",
                          hintStyle: AppTextStyles.h1.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 24,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      )
                    else
                      Text(
                        widget.note.title,
                        style: AppTextStyles.h1.copyWith(
                          color: AppColors.primary,
                          fontSize: 24,
                        ),
                      ),

                    const SizedBox(height: AppSpacing.md),

                    // Tags
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: widget.note.tags
                          .map(
                            (tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.15),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.full),
                              ),
                              child: Text(
                                tag,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Divider
                    Container(
                      height: 1,
                      color: AppColors.border,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Contenido (editable)
                    if (_isEditing)
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundCard,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: TextField(
                          controller: _contentController,
                          maxLines: null,
                          minLines: 10,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.text,
                            height: 1.6,
                          ),
                          decoration: InputDecoration(
                            hintText: "Escribe tu nota aquí...",
                            hintStyle: AppTextStyles.body.copyWith(
                              color: AppColors.textMuted,
                            ),
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
                        ),
                        child: Text(
                          widget.note.content,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.text,
                        height: 1.8,
                          ),
                        ),
                      ),

                    const SizedBox(height: AppSpacing.xl),

                    // Recurso asociado
                    if (widget.note.hasResource)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                        child: GestureDetector(
                          onTap: () {
                            AppNavigator.push(
                              context,
                              AppRoutes.bookDetail,
                              arguments: widget.note.resource,
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundCard.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.book_outlined,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Text(
                                      'Recurso asociado',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textMuted,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  widget.note.resource!.title,
                                  style: AppTextStyles.h2.copyWith(
                                    fontSize: 18,
                                    color: AppColors.text,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  widget.note.resource!.description,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textMuted,
                                    height: 1.4,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Ver recurso →',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Opciones adicionales en modo edición
                    if (_isEditing) ...[
                      Text(
                        "Opciones",
                        style: AppTextStyles.h2.copyWith(
                          color: AppColors.text,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Compartir nota
                      _OptionButton(
                        icon: Icons.share_outlined,
                        label: widget.note.isShared
                            ? "Dejar de compartir"
                            : "Compartir nota",
                        onTap: () {
                          // TODO: Implementar toggle share
                        },
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      // Eliminar nota
                      _OptionButton(
                        icon: Icons.delete_outline_rounded,
                        label: "Eliminar nota",
                        isDestructive: true,
                        onTap: () {
                          _showDeleteConfirmation(context);
                        },
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

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        title: Text(
          "¿Eliminar nota?",
          style: AppTextStyles.h2.copyWith(color: AppColors.text),
        ),
        content: Text(
          "Esta acción no se puede deshacer.",
          style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancelar",
              style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await vm.deleteNote(widget.note.idNota!);
              AppNavigator.pop(context); // Back to list
            },
            child: Text(
              "Eliminar",
              style: AppTextStyles.body.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

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
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: AppSpacing.md),
            Text(
              label,
              style: AppTextStyles.body.copyWith(color: color),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right_rounded,
              color: color,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

