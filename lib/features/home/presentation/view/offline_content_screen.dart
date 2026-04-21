import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/core/constants/app_radius.dart';
import 'package:academix/features/library/data/models/library_resource_ui_model.dart';
import 'package:academix/features/library/presentation/view/book_detail_screen.dart';
import 'package:academix/features/library/presentation/view/pdf_ai_viewer_screen.dart';
import 'package:academix/features/library/presentation/viewmodel/url_detector.dart';
import 'package:academix/features/home/data/datasources/offline_local_datasource.dart';
import '../viewmodel/offline_di.dart';
import '../viewmodel/offline_viewmodel.dart';
import '../../domain/entities/offline_entity.dart';

class OfflineContentScreen extends StatefulWidget {
  const OfflineContentScreen({super.key});

  @override
  State<OfflineContentScreen> createState() => _OfflineContentScreenState();
}

class _OfflineContentScreenState extends State<OfflineContentScreen> {
  late final OfflineViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = OfflineDI.viewModel();
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Offline',
            style: AppTextStyles.h2.copyWith(color: AppColors.text)),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _vm.isLoading,
        builder: (context, loading, _) {
          if (loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          return ValueListenableBuilder<List<OfflineEntity>>(
            valueListenable: _vm.offlineItems,
            builder: (context, items, _) {
              if (items.isEmpty) return const _EmptyState();
              return ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: items.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) =>
                    _OfflineTile(item: items[index], vm: _vm),
              );
            },
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _OfflineTile extends StatelessWidget {
  final OfflineEntity    item;
  final OfflineViewModel vm;

  const _OfflineTile({required this.item, required this.vm});

  // Usa UrlDetector como única fuente de verdad (igual que el resto de la app)
  UrlType get _urlType => UrlDetector.detect(item.urlArchivo);

  IconData get _icono {
    switch (_urlType) {
      case UrlType.youtube:
      case UrlType.video:
        return Icons.play_circle_outline_rounded;
      case UrlType.pdf:
      case UrlType.drive:
        return Icons.picture_as_pdf_rounded;
      case UrlType.audio:
        return Icons.headphones_rounded;
      case UrlType.html:
      case UrlType.gutenberg:
      case UrlType.openLibrary:
      case UrlType.archive:
        return Icons.language_rounded;
      default:
        return item.urlArchivo?.isNotEmpty == true
            ? Icons.link_rounded
            : Icons.article_rounded;
    }
  }

  Color get _iconColor {
    switch (_urlType) {
      case UrlType.youtube:
      case UrlType.video:
        return Colors.red;
      case UrlType.pdf:
      case UrlType.drive:
        return AppColors.primary;
      case UrlType.audio:
        return AppColors.secondary;
      default:
        return AppColors.textMuted;
    }
  }

  String get _etiqueta {
    switch (_urlType) {
      case UrlType.youtube:
      case UrlType.video:
        return 'Video';
      case UrlType.pdf:
      case UrlType.drive:
        return 'PDF';
      case UrlType.audio:
        return 'Audio';
      case UrlType.html:
        return 'Web';
      case UrlType.gutenberg:
      case UrlType.openLibrary:
      case UrlType.archive:
        return 'Libro';
      default:
        return item.urlArchivo?.isNotEmpty == true ? 'Enlace' : 'Texto';
    }
  }

  LibraryResource _toUiModel() => LibraryResource(
    id:              item.idRecurso.toString(),
    title:           item.titulo,
    description:     item.descripcion,
    category:        '',
    urlArchivo:      item.urlArchivo,
    contenido:       item.contenido,
    idTipo:          item.idTipo ?? 2,
    durationMinutes: 0,
    pages:           0,
  );

  Future<void> _abrir(BuildContext context) async {
    // Tiene archivo encriptado local → desencriptar y abrir sin red
    if (item.rutaLocal != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );

      try {
        final pdfBytes = await OfflineLocalDataSource()
            .leerPdfLocal(item.idRecurso, item.rutaLocal!);

        if (!context.mounted) return;
        Navigator.pop(context);

        if (pdfBytes == null) {
          _mostrarError(context, 'No se pudo leer el archivo offline.');
          return;
        }

        final b64     = base64Encode(pdfBytes);
        final dataUrl = 'data:application/pdf;base64,$b64';

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PdfAiViewerScreen(
              pdfUrl: dataUrl,
              title:  item.titulo,
            ),
          ),
        );
      } catch (_) {
        if (context.mounted) Navigator.pop(context);
        if (context.mounted) {
          _mostrarError(context, 'Error al abrir el recurso offline.');
        }
      }
      return;
    }

    // Sin archivo local → abrir normalmente (requiere red)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookDetailScreen(resource: _toUiModel()),
      ),
    );
  }

  void _mostrarError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _abrir(context),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical:   AppSpacing.sm,
          ),
          leading: Container(
            width:  46,
            height: 46,
            decoration: BoxDecoration(
              color:        _iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(_icono, color: _iconColor, size: 24),
          ),
          title: Text(
            item.titulo,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Text(
                item.descripcion,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _iconColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      _etiqueta,
                      style: AppTextStyles.caption.copyWith(
                        color:      _iconColor,
                        fontWeight: FontWeight.w600,
                        fontSize:   10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (item.rutaLocal != null) ...[
                    Icon(Icons.lock_outline,
                        size: 11, color: AppColors.textMuted),
                    const SizedBox(width: 3),
                  ],
                  Text(
                    item.fechaDescarga
                        .toLocal()
                        .toString()
                        .split(' ')[0],
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
              IconButton(
                icon: Icon(Icons.delete_outline,
                    color: AppColors.error, size: 20),
                onPressed: () =>
                    vm.eliminar(item.idRecurso, item.urlArchivo),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off, size: 80, color: AppColors.textMuted),
          const SizedBox(height: AppSpacing.md),
          Text('No hay contenido offline',
              style: AppTextStyles.h2.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: AppSpacing.sm),
          Text('Descarga recursos para usarlos sin conexión',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}