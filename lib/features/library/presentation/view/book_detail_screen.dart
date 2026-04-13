import 'dart:async';
import 'package:flutter/material.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/core/constants/app_radius.dart';
import 'package:academix/core/routes/app_routes.dart';
import 'package:academix/core/network/dio_client.dart';
import 'package:academix/features/library/domain/entities/library_resource_entity.dart';
import 'package:academix/features/library/presentation/view/ai_chat_screen.dart';
import 'package:academix/features/library/presentation/view/recurso_viewer_screen.dart';
import 'package:academix/features/library/presentation/viewmodel/book_detail_viewmodel.dart';
import 'package:academix/features/library/presentation/viewmodel/progreso_viewmodel.dart';
import 'package:academix/features/library/data/models/library_resource_ui_model.dart';
import 'package:academix/features/library/presentation/viewmodel/library_di.dart';
import 'package:academix/features/library/presentation/viewmodel/url_detector.dart';
import 'package:academix/features/note/presentation/view/create_note_screen.dart';
import 'package:academix/features/library/presentation/view/resource_shared_notes_screen.dart';
import 'package:academix/features/home/presentation/widgets/offline_button.dart';

class BookDetailScreen extends StatefulWidget {
  final LibraryResource resource;

  const BookDetailScreen({super.key, required this.resource});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  BookDetailViewModel? _vm;
  ProgresoViewModel?   _progresoVm;
  Timer?               _scrollDebounce;
  double               _fontSize = 16.0;
  bool                 _isReadingMode = false;

  @override
  void initState() {
    super.initState();
    _initViewModel();
  }

  Future<void> _initViewModel() async {
    int idUsuario = 0;
    try {
      final response = await DioClient.dio.get('/usuarios/me');
      idUsuario = response.data['id_usuario'] as int;
    } catch (_) {}

    if (!mounted) return;

    final vm = LibraryDI.bookDetailViewModel(idUsuario: idUsuario);

    // Precarga inmediata con datos locales del widget
    vm.resource.value = LibraryResourceEntity(
      idRecurso:        int.parse(widget.resource.id),
      titulo:           widget.resource.title,
      descripcion:      widget.resource.description,
      contenido:        widget.resource.contenido,
      urlArchivo:       widget.resource.urlArchivo,
      fechaPublicacion: DateTime.now(),
      idTipo:           widget.resource.idTipo ?? 2,
      idEstado:         1,
      idSubtema:        0,
      nombreSubtema:    widget.resource.category.isEmpty
                          ? null
                          : widget.resource.category,
    );
    vm.isLoading.value = false;

    // setState PRIMERO → UI aparece con datos locales
    setState(() => _vm = vm);

    // Progreso solo para recursos de texto puro (sin URL)
    if (widget.resource.urlArchivo == null ||
        widget.resource.urlArchivo!.isEmpty) {
      final pVm = LibraryDI.progresoViewModel(
        idRecurso: int.parse(widget.resource.id),
      );
      await pVm.cargar();
      if (mounted) setState(() => _progresoVm = pVm);
    }

    // En background: enriquece con datos frescos del API
    vm.loadResource(int.parse(widget.resource.id));
    vm.loadFavoriteStatus(int.parse(widget.resource.id));
  }

  @override
  void dispose() {
    _progresoVm?.sincronizarAlSalir();
    _progresoVm?.dispose();
    _scrollDebounce?.cancel();
    _vm?.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  UrlType get _urlType => UrlDetector.detect(widget.resource.urlArchivo);

  bool get _tieneVisor {
    final url = widget.resource.urlArchivo ?? '';
    return url.isNotEmpty;
  }

  bool get _esSoloTexto => !_tieneVisor;

  String get _botonLabel {
    switch (_urlType) {
      case UrlType.pdf:        return 'Abrir PDF';
      case UrlType.youtube:
      case UrlType.video:      return 'Ver video';
      case UrlType.audio:      return 'Escuchar audio';
      case UrlType.gutenberg:
      case UrlType.openLibrary:
      case UrlType.archive:
      case UrlType.html:       return 'Leer en línea';
      case UrlType.drive:      return 'Abrir en Drive';
      default:
        return _esSoloTexto ? 'Empezar a leer' : 'Abrir recurso';
    }
  }

  IconData get _botonIcon {
    switch (_urlType) {
      case UrlType.pdf:         return Icons.picture_as_pdf_rounded;
      case UrlType.youtube:
      case UrlType.video:       return Icons.play_circle_outline_rounded;
      case UrlType.audio:       return Icons.headphones_rounded;
      case UrlType.gutenberg:
      case UrlType.openLibrary:
      case UrlType.archive:
      case UrlType.html:        return Icons.menu_book_rounded;
      case UrlType.drive:       return Icons.drive_file_move_rounded;
      default:
        return _esSoloTexto
            ? Icons.auto_stories_rounded
            : Icons.open_in_new_rounded;
    }
  }

  void _abrirContenido() {
    if (_esSoloTexto) {
      setState(() => _isReadingMode = true);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecursoViewerScreen(
          url:   widget.resource.urlArchivo!,
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
        child: const Padding(
          padding: EdgeInsets.all(20),
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
          preselectedResourceId:    int.parse(widget.resource.id),
          preselectedResourceTitle: widget.resource.title,
        ),
      ),
    );
  }

  // ── Sección de progreso ───────────────────────────────────────────────────

  Widget _buildProgresoSection() {
    final pVm = _progresoVm;
    if (pVm == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fila título + estado
        Row(
          children: [
            Text(
              'Progreso',
              style: AppTextStyles.h2.copyWith(
                color: AppColors.text,
                fontSize: 18,
              ),
            ),
            const Spacer(),
            ValueListenableBuilder<bool>(
              valueListenable: pVm.completado,
              builder: (_, comp, __) {
                if (comp) {
                  return Row(
                    children: [
                      Icon(Icons.check_circle,
                          color: AppColors.success, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Completado',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.success),
                      ),
                    ],
                  );
                }
                return ValueListenableBuilder<double>(
                  valueListenable: pVm.porcentaje,
                  builder: (_, pct, __) => Text(
                    '${pct.toInt()}% leído',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textMuted),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // Barra de progreso
        ValueListenableBuilder<double>(
          valueListenable: pVm.porcentaje,
          builder: (_, pct, __) => ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value:           pct / 100,
              backgroundColor: AppColors.backgroundCard,
              color:           AppColors.primary,
              minHeight:       6,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Botón marcar como leído
        ValueListenableBuilder<bool>(
          valueListenable: pVm.completado,
          builder: (_, comp, __) {
            if (comp) return const SizedBox.shrink();
            return GestureDetector(
              onTap: pVm.marcarCompletado,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical:   AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(
                      color: AppColors.primary.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_outline,
                        color: AppColors.primary, size: 15),
                    const SizedBox(width: 6),
                    Text(
                      'Marcar como leído',
                      style: AppTextStyles.caption.copyWith(
                        color:      AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

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
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // ── Header ────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical:   AppSpacing.md,
                  ),
                  child: Row(
                    children: [
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
                            _fontSize =
                                (_fontSize + 2).clamp(14.0, 28.0);
                          }),
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundCard,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.md),
                            ),
                            child: const Icon(
                                Icons.text_increase_rounded,
                                color: AppColors.text,
                                size: 22),
                          ),
                        ),
                      ],
                      if (!_isReadingMode && _tieneVisor)
                        _UrlTypeBadge(urlType: _urlType),
                    ],
                  ),
                ),

                // ── Scrollable content ────────────────────────────────────
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
                          child: Text(
                            widget.resource.category,
                            style: AppTextStyles.bodySmall.copyWith(
                                color:      AppColors.primary,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Row(
                          children: [
                            _InfoChip(
                              icon:  Icons.access_time_rounded,
                              label: '${widget.resource.durationMinutes} min',
                            ),
                            const SizedBox(width: AppSpacing.md),
                            _InfoChip(
                              icon:  Icons.description_outlined,
                              label: '${widget.resource.pages} páginas',
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // ── Offline button ─────────────────────────────
                        ValueListenableBuilder<LibraryResourceEntity?>(
                          valueListenable: vm.resource,
                          builder: (context, entity, _) {
                            if (entity == null) return const SizedBox.shrink();
                            return OfflineButton(
                              esPremium: true,
                              recurso:   entity,
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        Text(
                          'Descripción',
                          style: AppTextStyles.h2.copyWith(
                              color: AppColors.text, fontSize: 18),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          widget.resource.description,
                          style: AppTextStyles.body.copyWith(
                              color: AppColors.textMuted, height: 1.6),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // ── Modo lectura ───────────────────────────────
                        if (_isReadingMode && _esSoloTexto) ...[
                          _buildProgresoSection(),
                          Text(
                            'Contenido',
                            style: AppTextStyles.h2.copyWith(
                                color: AppColors.text, fontSize: 18),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          ValueListenableBuilder<bool>(
                            valueListenable: vm.isLoading,
                            builder: (context, loading, _) {
                              if (loading) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              return ValueListenableBuilder
                                  <LibraryResourceEntity?>(
                                valueListenable: vm.resource,
                                builder: (context, resource, _) {
                                  if (resource == null) {
                                    return const Text(
                                        'Error al cargar contenido');
                                  }
                                  return _ReadingContent(
                                    fontSize:         _fontSize,
                                    content:          resource.contenido ??
                                        'Sin contenido',
                                    scrollController: _progresoVm?.scrollController,
                                    onScroll: _progresoVm == null
                                        ? null
                                        : () {
                                            _scrollDebounce?.cancel();
                                            _scrollDebounce = Timer(
                                              const Duration(seconds: 2),
                                              () => _progresoVm!
                                                  .sincronizarAlSalir(),
                                            );
                                          },
                                    onMounted: _progresoVm == null
                                        ? null
                                        : () => _progresoVm!
                                            .restaurarPosicion(),
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
                            Text(
                              _botonLabel,
                              style: AppTextStyles.body.copyWith(
                                  color:      AppColors.background,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          if (_isReadingMode && _esSoloTexto)
            Positioned(
              right:  AppSpacing.xl,
              bottom: AppSpacing.xxl,
              child: GestureDetector(
                onTap: () => _openCreateNote(context),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color:  AppColors.primary.withOpacity(0.9),
                    shape:  BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:      AppColors.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset:     const Offset(0, 10),
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

// ── Widgets auxiliares ────────────────────────────────────────────────────────

class _UrlTypeBadge extends StatelessWidget {
  final UrlType urlType;
  const _UrlTypeBadge({required this.urlType});

  String get _label {
    switch (urlType) {
      case UrlType.pdf:         return 'PDF';
      case UrlType.youtube:     return 'YouTube';
      case UrlType.video:       return 'Video';
      case UrlType.audio:       return 'Audio';
      case UrlType.gutenberg:
      case UrlType.openLibrary: return 'Libro';
      case UrlType.archive:     return 'Archivo';
      case UrlType.drive:       return 'Drive';
      case UrlType.html:        return 'Web';
      default:                  return 'Recurso';
    }
  }

  IconData get _icon {
    switch (urlType) {
      case UrlType.pdf:         return Icons.picture_as_pdf_rounded;
      case UrlType.youtube:     return Icons.play_circle_outline_rounded;
      case UrlType.video:       return Icons.videocam_outlined;
      case UrlType.audio:       return Icons.headphones_rounded;
      case UrlType.gutenberg:
      case UrlType.openLibrary: return Icons.menu_book_rounded;
      case UrlType.drive:       return Icons.drive_file_move_rounded;
      default:                  return Icons.link_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color:        AppColors.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border:       Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, color: AppColors.primary, size: 14),
          const SizedBox(width: 4),
          Text(_label,
              style: AppTextStyles.bodySmall.copyWith(
                  color:      AppColors.primary,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String   label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color:        AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Text(label,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

// _ReadingContent ahora es StatefulWidget para poder llamar onMounted
class _ReadingContent extends StatefulWidget {
  final double           fontSize;
  final String           content;
  final ScrollController? scrollController;
  final VoidCallback?    onScroll;
  final VoidCallback?    onMounted;

  const _ReadingContent({
    required this.fontSize,
    required this.content,
    this.scrollController,
    this.onScroll,
    this.onMounted,
  });

  @override
  State<_ReadingContent> createState() => _ReadingContentState();
}

class _ReadingContentState extends State<_ReadingContent> {
  @override
  void initState() {
    super.initState();
    // Restaura posición después de que el widget está en el árbol
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onMounted?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final scroll = widget.scrollController ?? ScrollController();

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.65,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification) {
            widget.onScroll?.call();
          }
          return false;
        },
        child: SingleChildScrollView(
          controller: scroll,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color:        AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Text(
              widget.content,
              style: AppTextStyles.body.copyWith(
                  color:    AppColors.text,
                  height:   1.8,
                  fontSize: widget.fontSize),
            ),
          ),
        ),
      ),
    );
  }
}