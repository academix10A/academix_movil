import 'package:flutter/material.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/core/constants/app_radius.dart';
import 'package:academix/features/library/domain/entities/publication_entity.dart';
import 'package:academix/features/library/presentation/viewmodel/publication_detail_viewmodel.dart';
import 'package:academix/features/library/presentation/viewmodel/library_di.dart';
import 'package:flutter/services.dart';

class PublicationLibraryDetailScreen extends StatefulWidget {
  final String id;

  const PublicationLibraryDetailScreen({super.key, required this.id});

  @override
  State<PublicationLibraryDetailScreen> createState() => _PublicationDetailScreenState();
}

class _PublicationDetailScreenState extends State<PublicationLibraryDetailScreen> {
  PublicationDetailViewModel? _vm;

  @override
  void initState() {
    super.initState();
    _vm = LibraryDI.publicationDetailViewModel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _vm!.loadPublication(int.parse(widget.id));
    });
  }

  @override
  void dispose() {
    _vm?.dispose();
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
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _vm!.isLoading,
        builder: (context, loading, _) {
          if (loading) {
            return const Center(child: CircularProgressIndicator());
          }
          return ValueListenableBuilder<PublicationEntity?>(
            valueListenable: _vm!.publication,
            builder: (context, pub, _) {
              if (pub == null) {
                return const Center(child: Text('Publication not found'));
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pub.titulo, style: AppTextStyles.h1),
                    const SizedBox(height: AppSpacing.sm),
                    if (pub.etiquetas != null && pub.etiquetas!.isNotEmpty) ...[
                      Wrap(
                        spacing: AppSpacing.sm,
                        children: pub.etiquetas!
                            .map((tag) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(AppRadius.full),
                                  ),
                                  child: Text(tag, style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    Text(pub.descripcion, style: AppTextStyles.body),
                    const SizedBox(height: AppSpacing.xl),
                    Text(pub.texto, style: AppTextStyles.body.copyWith(height: 1.6)),
                    const SizedBox(height: AppSpacing.xxl),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(pub.usuarioNombre ?? 'Unknown', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
                        Text(pub.fechaCreacion.toLocal().toString().split(' ')[0], style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    GestureDetector(
                      onTap: () async {
                        await Clipboard.setData(ClipboardData(text: pub.texto));
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied')));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundCard,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.copy, color: AppColors.textMuted, size: 16),
                            SizedBox(width: AppSpacing.xs),
                            Text('Copy text', style: AppTextStyles.caption),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

