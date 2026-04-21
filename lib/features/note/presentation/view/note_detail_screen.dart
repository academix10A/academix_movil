// note/presentation/view/note_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/core/constants/app_radius.dart';
import 'package:academix/core/routes/app_routes.dart';
import 'package:academix/features/note/domain/usecases/note_usecases.dart';
import 'package:academix/features/note/presentation/di/note_di.dart';
import 'package:academix/features/note/presentation/viewmodel/notes_viewmodel.dart';

class NoteDetailScreen extends StatefulWidget {
  final NoteItem note;

  const NoteDetailScreen({super.key, required this.note});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late final UpdateNoteUseCase _updateNote;
  late final DeleteNoteUseCase _deleteNote;

  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  bool _isEditing = false;
  bool _isLoading = false;

  // Mismo patrón de colores accent que LibraryResourceCard
  static const List<Color> _accentColors = [
    Color(0xFFE8C547),
    Color(0xFF4CAF50),
    Color(0xFF2196F3),
    Color(0xFFFF5722),
    Color(0xFF9C27B0),
  ];

  Color get _accent =>
      _accentColors[(widget.note.idNota ?? 0) % _accentColors.length];

  @override
  void initState() {
    super.initState();
    _updateNote = NoteDI.updateNoteUseCase;
    _deleteNote = NoteDI.deleteNoteUseCase;
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    try {
      await _updateNote(
        id: widget.note.idNota!,
        titulo: _titleController.text,
        contenido: _contentController.text,
        esCompartida: widget.note.isShared,
      );
      if (mounted) {
        setState(() => _isEditing = false);
        AppNavigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> deleteNote() async {
    setState(() => _isLoading = true);
    try {
      await _deleteNote(widget.note.idNota!);
      if (mounted) AppNavigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header (estilo BookDetailScreen) ─────────────────────────
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
                      child: const Icon(Icons.arrow_back_rounded,
                          color: AppColors.text, size: 22),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),

                  // Badge compartida — mismo estilo que _UrlTypeBadge
                  if (widget.note.isShared)
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
                          Icon(Icons.people_outline_rounded,
                              size: 14, color: _accent),
                          const SizedBox(width: 4),
                          Text(
                            'Compartida',
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
                  GestureDetector(
                    onTap: _isLoading
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
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
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
                  ),
                ],
              ),
            ),

            // ── Contenido scrollable ──────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tiempo relativo
                    Text(
                      widget.note.timeAgo,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Título — editable o display
                    if (_isEditing)
                      TextField(
                        controller: _titleController,
                        style: AppTextStyles.h1
                            .copyWith(color: AppColors.primary, fontSize: 26),
                        decoration: InputDecoration(
                          hintText: 'Título de la nota',
                          hintStyle: AppTextStyles.h1.copyWith(
                              color: AppColors.textMuted, fontSize: 26),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      )
                    else
                      Text(
                        widget.note.title,
                        style: AppTextStyles.h1
                            .copyWith(color: AppColors.primary, fontSize: 26),
                      ),

                    const SizedBox(height: AppSpacing.md),

                    // Tags — mismo estilo que categoría en BookDetailScreen
                    if (widget.note.tags.isNotEmpty)
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: widget.note.tags
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
                                  tag,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),

                    const SizedBox(height: AppSpacing.xl),

                    // Divider con color accent (igual al de publication_detail)
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

                    // Label sección contenido
                    Text(
                      'Contenido',
                      style: AppTextStyles.h2
                          .copyWith(color: AppColors.text, fontSize: 18),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Contenido — editable (con borde accent) o display
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
                          controller: _contentController,
                          maxLines: null,
                          minLines: 10,
                          style: AppTextStyles.body
                              .copyWith(color: AppColors.text, height: 1.6),
                          decoration: InputDecoration(
                            hintText: 'Escribe tu nota aquí...',
                            hintStyle: AppTextStyles.body
                                .copyWith(color: AppColors.textMuted),
                            border: InputBorder.none,
                          ),
                        ),
                      )
                    else
                      // Igual que _ReadingContent en BookDetailScreen
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
                          widget.note.content,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.text,
                            height: 1.8,
                          ),
                        ),
                      ),

                    const SizedBox(height: AppSpacing.xl),

                    // Recurso asociado — estilo card igual que BookDetailScreen
                    if (widget.note.hasResource)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                        child: GestureDetector(
                          onTap: () => AppNavigator.push(
                            context,
                            AppRoutes.bookDetail,
                            arguments: widget.note.resource,
                          ),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundCard,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.md),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.25),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.menu_book_rounded,
                                        color: AppColors.primary, size: 18),
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
                                      color: AppColors.textMuted, height: 1.4),
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

                    // Opciones en modo edición
                    if (_isEditing) ...[
                      Text(
                        'Opciones',
                        style: AppTextStyles.h2
                            .copyWith(color: AppColors.text, fontSize: 16),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _OptionButton(
                        icon: Icons.delete_outline_rounded,
                        label: 'Eliminar nota',
                        isDestructive: true,
                        onTap: () => _showDeleteConfirmation(context),
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
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md)),
        title: Text('¿Eliminar nota?',
            style: AppTextStyles.h2.copyWith(color: AppColors.text)),
        content: Text('Esta acción no se puede deshacer.',
            style: AppTextStyles.body.copyWith(color: AppColors.textMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar',
                style:
                    AppTextStyles.body.copyWith(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await deleteNote();
            },
            child: Text('Eliminar',
                style: AppTextStyles.body.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// ─── Widgets auxiliares ────────────────────────────────────────────────────────

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