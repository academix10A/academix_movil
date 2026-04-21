// note/presentation/view/note_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/core/constants/app_radius.dart';
import 'package:academix/core/routes/app_routes.dart';
import 'package:academix/features/note/domain/entities/note_entity.dart';
import 'package:academix/features/library/domain/usecases/get_note_by_id_usecase.dart';
import 'package:academix/features/note/data/repositories/note_repository_impl.dart';
import 'package:academix/features/note/data/datasources/note_remote_datasource.dart';
import 'package:academix/features/library/presentation/viewmodel/note_detail_viewmodel.dart';

class NoteDetailScreenLibrary extends StatefulWidget {
  /// Acepta String (desde SearchResult.id) o int (navegación directa)
  final dynamic id;

  const NoteDetailScreenLibrary({super.key, required this.id});

  @override
  State<NoteDetailScreenLibrary> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreenLibrary> {
  NoteDetailViewModel? _vm;
  double _fontSize = 16.0;

  @override
  void initState() {
    super.initState();
    _initViewModel();
  }

  Future<void> _initViewModel() async {
    // DI manual — mismo patrón que BookDetailScreen
    final vm = NoteDetailViewModel(
      getNoteByIdUseCase: GetNoteByIdUseCase(
        NoteRepositoryImpl(NoteRemoteDataSource()),
      ),
    );

    final noteId = int.tryParse(widget.id.toString()) ?? 0;
    vm.loadNote(noteId);

    if (!mounted) return;
    setState(() => _vm = vm);
  }

  @override
  void dispose() {
    _vm?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = _vm;

    if (vm == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ValueListenableBuilder<bool>(
          valueListenable: vm.isLoading,
          builder: (context, loading, _) {
            if (loading) {
              return const Center(child: CircularProgressIndicator());
            }
            return ValueListenableBuilder<NoteEntity?>(
              valueListenable: vm.note,
              builder: (context, note, _) {
                if (note == null) {
                  return _NoteErrorState(
                    errorMessage: vm.errorMessage.value,
                    onBack: () => AppNavigator.pop(context),
                  );
                }
                return _NoteDetailBody(
                  note: note,
                  fontSize: _fontSize,
                  onFontIncrease: () => setState(
                      () => _fontSize = (_fontSize + 2).clamp(14.0, 28.0)),
                  onFontDecrease: () => setState(
                      () => _fontSize = (_fontSize - 2).clamp(14.0, 28.0)),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// ─── Cuerpo principal ──────────────────────────────────────────────────────────

class _NoteDetailBody extends StatelessWidget {
  final NoteEntity note;
  final double fontSize;
  final VoidCallback onFontIncrease;
  final VoidCallback onFontDecrease;

  const _NoteDetailBody({
    required this.note,
    required this.fontSize,
    required this.onFontIncrease,
    required this.onFontDecrease,
  });

  // Mismo patrón de colores que LibraryResourceCard
  static const List<Color> _accentColors = [
    Color(0xFFE8C547),
    Color(0xFF4CAF50),
    Color(0xFF2196F3),
    Color(0xFFFF5722),
    Color(0xFF9C27B0),
  ];

  Color get _accent => _accentColors[note.idNota % _accentColors.length];

  String _formatDate(DateTime dt) {
    const months = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Header (idéntico al de BookDetailScreen) ─────────────────────
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

              // Badge privada/compartida
              _StatusBadge(isShared: note.esCompartida, accentColor: _accent),

              const Spacer(),

              // Aumentar fuente
              GestureDetector(
                onTap: onFontIncrease,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundCard,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(Icons.text_increase_rounded,
                      color: AppColors.text, size: 22),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),

              // Disminuir fuente
              GestureDetector(
                onTap: onFontDecrease,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundCard,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(Icons.text_decrease_rounded,
                      color: AppColors.text, size: 22),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),

              // Copiar contenido
              GestureDetector(
                onTap: () async {
                  await Clipboard.setData(
                      ClipboardData(text: note.contenido));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Nota copiada al portapapeles'),
                        backgroundColor: _accent,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundCard,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(Icons.copy_rounded,
                      color: AppColors.text, size: 22),
                ),
              ),
            ],
          ),
        ),

        // ── Contenido scrollable ──────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                Text(
                  note.title,
                  style: AppTextStyles.h1.copyWith(
                    color: AppColors.primary,
                    fontSize: 26,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Recurso asociado
                if (note.hasResource && note.recurso != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.menu_book_rounded,
                            size: 14, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            note.recurso!.titulo,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],

                // Chips de info: tiempo relativo + fecha de edición
                Row(
                  children: [
                    _InfoChip(
                      icon: Icons.access_time_rounded,
                      label: note.timeAgo,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    _InfoChip(
                      icon: Icons.edit_calendar_rounded,
                      label: _formatDate(note.fechaActualizacion),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),

                // Sección "Contenido"
                Text(
                  'Contenido',
                  style: AppTextStyles.h2
                      .copyWith(color: AppColors.text, fontSize: 18),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Descripción/preview encima del texto completo
                Text(
                  note.preview,
                  style: AppTextStyles.body.copyWith(
                      color: AppColors.textMuted, height: 1.6),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Cuerpo de la nota (igual que _ReadingContent en BookDetailScreen)
                Container(
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
                    note.contenido,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.text,
                      height: 1.8,
                      fontSize: fontSize,
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Widgets auxiliares (mismo estilo que BookDetailScreen) ───────────────────

class _StatusBadge extends StatelessWidget {
  final bool isShared;
  final Color accentColor;

  const _StatusBadge({required this.isShared, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: accentColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isShared ? Icons.public_rounded : Icons.lock_outline_rounded,
            color: accentColor,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            isShared ? 'Compartida' : 'Privada',
            style: AppTextStyles.bodySmall.copyWith(
              color: accentColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

// ─── Error state ──────────────────────────────────────────────────────────────

class _NoteErrorState extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback onBack;

  const _NoteErrorState({this.errorMessage, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sticky_note_2_outlined,
              size: 64,
              color: AppColors.textMuted.withOpacity(0.4)),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Nota no encontrada',
            style: AppTextStyles.h2.copyWith(color: AppColors.textMuted),
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Text(
                errorMessage!,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          GestureDetector(
            onTap: onBack,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.backgroundCard,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.arrow_back_rounded,
                      color: AppColors.text, size: 18),
                  const SizedBox(width: AppSpacing.xs),
                  Text('Volver',
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.text)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}