import 'package:flutter/material.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/core/constants/app_radius.dart';
import 'package:academix/core/routes/app_routes.dart';
import 'package:academix/features/library/presentation/view/ai_chat_screen.dart';
import 'package:academix/features/library/presentation/view/recurso_viewer_screen.dart';
import 'package:academix/features/library/presentation/viewmodel/book_detail_viewmodel.dart';
import 'package:academix/features/library/presentation/viewmodel/library_viewmodel.dart';
import 'package:academix/features/library/domain/entities/library_entity.dart';
import 'package:academix/features/library/presentation/viewmodel/url_detector.dart';
import 'package:academix/features/note/presentation/view/create_note_screen.dart';
import 'package:academix/features/library/presentation/view/resource_shared_notes_screen.dart';

class BookDetailScreen extends StatefulWidget {
  final LibraryResource resource;

  const BookDetailScreen({
    super.key,
    required this.resource,
  });

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final BookDetailViewModel vm = BookDetailViewModel();
  double _fontSize = 16.0;
  bool _isReadingMode = false;

  // ── Helpers ──────────────────────────────────────────────────────────────

  UrlType get _urlType => UrlDetector.detect(widget.resource.urlArchivo);

  /// true cuando el recurso tiene contenido externo (URL) que abrir
  bool get _tieneVisor {
    final url = widget.resource.urlArchivo ?? '';
    return url.isNotEmpty;
  }

  /// true cuando el recurso es solo texto interno (sin URL real o tipo texto)
  bool get _esSoloTexto => !_tieneVisor;

  String get _botonLabel {
    switch (_urlType) {
      case UrlType.pdf:
        return 'Abrir PDF';
      case UrlType.youtube:
      case UrlType.video:
        return 'Ver video';
      case UrlType.audio:
        return 'Escuchar audio';
      case UrlType.gutenberg:
      case UrlType.openLibrary:
      case UrlType.archive:
      case UrlType.html:
        return 'Leer en línea';
      case UrlType.drive:
        return 'Abrir en Drive';
      default:
        return _esSoloTexto ? 'Empezar a leer' : 'Abrir recurso';
    }
  }

  IconData get _botonIcon {
    switch (_urlType) {
      case UrlType.pdf:
        return Icons.picture_as_pdf_rounded;
      case UrlType.youtube:
      case UrlType.video:
        return Icons.play_circle_outline_rounded;
      case UrlType.audio:
        return Icons.headphones_rounded;
      case UrlType.gutenberg:
      case UrlType.openLibrary:
      case UrlType.archive:
      case UrlType.html:
        return Icons.menu_book_rounded;
      case UrlType.drive:
        return Icons.drive_file_move_rounded;
      default:
        return _esSoloTexto ? Icons.auto_stories_rounded : Icons.open_in_new_rounded;
    }
  }

  void _abrirContenido() {
    if (_esSoloTexto) {
      // Recurso de solo texto → modo lectura interno
      setState(() => _isReadingMode = true);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecursoViewerScreen(
          url: widget.resource.urlArchivo!,
          title: widget.resource.title,
        ),
      ),
    );
  }

  void _showAiModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: AiChatScreen(),
        ),
      ),
    );
  }

  void _openCreateNote(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateNoteScreen(
          preselectedResourceId: int.parse(widget.resource.id),
          preselectedResourceTitle: widget.resource.title,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    vm.loadResource(int.parse(widget.resource.id));
    vm.loadFavoriteStatus(int.parse(widget.resource.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // ── Header ────────────────────────────────────────────────
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

                      // Botón favorito
                      ValueListenableBuilder<bool>(
                        valueListenable: vm.isFavorite,
                        builder: (context, isFav, _) {
                          return GestureDetector(
                            onTap: () => vm.toggleFavorite(
                                int.parse(widget.resource.id)),
                            child: Container(
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundCard,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                              ),
                              child: Icon(
                                isFav
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: isFav
                                    ? AppColors.primary
                                    : AppColors.text,
                                size: 22,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: AppSpacing.sm),

                      // Botón notas compartidas
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ResourceSharedNotesScreen(
                                idRecurso: int.parse(widget.resource.id),
                                resourceTitle: widget.resource.title,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundCard,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: const Icon(
                              Icons.chat_bubble_outline_rounded,
                              color: AppColors.text,
                              size: 22),
                        ),
                      ),

                      const Spacer(),

                      // Botón AI (solo en modo lectura de texto interno)
                      if (_isReadingMode && _esSoloTexto) ...[
                        GestureDetector(
                          onTap: () => _showAiModal(context),
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundCard,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.md),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.4),
                                width: 1,
                              ),
                            ),
                            child: Icon(Icons.smart_toy,
                                color: AppColors.primary, size: 22),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                      ],

                      // Controles de texto (solo lectura interna)
                      if (_isReadingMode && _esSoloTexto) ...[
                        GestureDetector(
                          onTap: () =>
                              setState(() => _isReadingMode = false),
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.md),
                            ),
                            child: const Icon(Icons.menu_book_rounded,
                                color: AppColors.background, size: 22),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        GestureDetector(
                          onTap: () => setState(() {
                            _fontSize = (_fontSize + 2).clamp(14.0, 28.0);
                          }),
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundCard,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.md),
                            ),
                            child: const Icon(Icons.text_increase_rounded,
                                color: AppColors.text, size: 22),
                          ),
                        ),
                      ],

                      // Badge tipo de recurso
                      if (!_isReadingMode && _tieneVisor)
                        _UrlTypeBadge(urlType: _urlType),
                    ],
                  ),
                ),

                // ── Contenido scrollable ──────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.resource.title,
                          style: AppTextStyles.h1.copyWith(
                              color: AppColors.primary, fontSize: 26),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.15),
                            borderRadius:
                                BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(widget.resource.category,
                              style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Row(
                          children: [
                            _InfoChip(
                                icon: Icons.access_time_rounded,
                                label:
                                    '${widget.resource.durationMinutes} min'),
                            const SizedBox(width: AppSpacing.md),
                            _InfoChip(
                                icon: Icons.description_outlined,
                                label: '${widget.resource.pages} páginas'),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text('Descripción',
                            style: AppTextStyles.h2.copyWith(
                                color: AppColors.text, fontSize: 18)),
                        const SizedBox(height: AppSpacing.sm),
                        Text(widget.resource.description,
                            style: AppTextStyles.body.copyWith(
                                color: AppColors.textMuted, height: 1.6)),
                        const SizedBox(height: AppSpacing.xl),

                        // Contenido texto interno
                        if (_isReadingMode && _esSoloTexto) ...[
                          Text('Contenido',
                              style: AppTextStyles.h2.copyWith(
                                  color: AppColors.text, fontSize: 18)),
                          const SizedBox(height: AppSpacing.md),
                          ValueListenableBuilder<bool>(
                            valueListenable: vm.isLoading,
                            builder: (context, loading, _) {
                              if (loading) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              return ValueListenableBuilder<
                                  LibraryResourceEntity?>(
                                valueListenable: vm.resource,
                                builder: (context, resource, _) {
                                  if (resource == null) {
                                    return const Text(
                                        'Error al cargar contenido');
                                  }
                                  return _ReadingContent(
                                    fontSize: _fontSize,
                                    content: resource.contenido ??
                                        'Sin contenido',
                                  );
                                },
                              );
                            },
                          ),
                        ],

                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
                ),

                // ── Botón principal ───────────────────────────────────────
                if (!_isReadingMode)
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: GestureDetector(
                      onTap: _abrirContenido,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_botonIcon,
                                color: AppColors.background, size: 22),
                            const SizedBox(width: AppSpacing.sm),
                            Text(_botonLabel,
                                style: AppTextStyles.body.copyWith(
                                    color: AppColors.background,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── FAB crear nota (solo lectura texto interno) ───────────────────
          if (_isReadingMode && _esSoloTexto)
            Positioned(
              right: AppSpacing.xl,
              bottom: AppSpacing.xxl,
              child: GestureDetector(
                onTap: () => _openCreateNote(context),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.edit_note_rounded,
                      color: AppColors.background, size: 28),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Badge tipo de recurso ──────────────────────────────────────────────────────

class _UrlTypeBadge extends StatelessWidget {
  final UrlType urlType;
  const _UrlTypeBadge({required this.urlType});

  String get _label {
    switch (urlType) {
      case UrlType.pdf:       return 'PDF';
      case UrlType.youtube:   return 'YouTube';
      case UrlType.video:     return 'Video';
      case UrlType.audio:     return 'Audio';
      case UrlType.gutenberg: return 'Libro';
      case UrlType.openLibrary: return 'Libro';
      case UrlType.archive:   return 'Archivo';
      case UrlType.drive:     return 'Drive';
      case UrlType.html:      return 'Web';
      default:                return 'Recurso';
    }
  }

  IconData get _icon {
    switch (urlType) {
      case UrlType.pdf:       return Icons.picture_as_pdf_rounded;
      case UrlType.youtube:   return Icons.play_circle_outline_rounded;
      case UrlType.video:     return Icons.videocam_outlined;
      case UrlType.audio:     return Icons.headphones_rounded;
      case UrlType.gutenberg:
      case UrlType.openLibrary: return Icons.menu_book_rounded;
      case UrlType.drive:     return Icons.drive_file_move_rounded;
      default:                return Icons.link_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, color: AppColors.primary, size: 14),
          const SizedBox(width: 4),
          Text(_label,
              style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

// ── Widgets auxiliares ─────────────────────────────────────────────────────────

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
          Text(label,
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _ReadingContent extends StatelessWidget {
  final double fontSize;
  final String content;
  const _ReadingContent({required this.fontSize, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Text(
        content,
        style: AppTextStyles.body.copyWith(
            color: AppColors.text, height: 1.8, fontSize: fontSize),
      ),
    );
  }
}