// features/library/presentation/view/publication_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/core/constants/app_radius.dart';
import 'package:academix/core/routes/app_routes.dart';
import 'package:academix/features/library/domain/entities/publication_entity.dart';
import 'package:academix/features/library/presentation/viewmodel/publication_detail_viewmodel.dart';
import 'package:academix/features/library/presentation/viewmodel/library_di.dart';

class PublicationDetailScreen extends StatefulWidget {
  final String id;

  const PublicationDetailScreen({super.key, required this.id});

  @override
  State<PublicationDetailScreen> createState() =>
      _PublicationDetailScreenState();
}

class _PublicationDetailScreenState extends State<PublicationDetailScreen> {
  PublicationDetailViewModel? _vm;
  double _fontSize = 16.0;

  @override
  void initState() {
    super.initState();
    _initViewModel();
  }

  Future<void> _initViewModel() async {
    final vm = LibraryDI.publicationDetailViewModel();
    vm.loadPublication(int.parse(widget.id));

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
            return ValueListenableBuilder<PublicationEntity?>(
              valueListenable: vm.publication,
              builder: (context, pub, _) {
                if (pub == null) {
                  return _PublicationErrorState(
                    onBack: () => AppNavigator.pop(context),
                  );
                }
                return _PublicationDetailBody(
                  pub: pub,
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

class _PublicationDetailBody extends StatelessWidget {
  final PublicationEntity pub;
  final double fontSize;
  final VoidCallback onFontIncrease;
  final VoidCallback onFontDecrease;

  const _PublicationDetailBody({
    required this.pub,
    required this.fontSize,
    required this.onFontIncrease,
    required this.onFontDecrease,
  });

  // Mismo patrón que LibraryResourceCard
  static const List<Color> _accentColors = [
    Color(0xFFE8C547),
    Color(0xFF4CAF50),
    Color(0xFF2196F3),
    Color(0xFFFF5722),
    Color(0xFF9C27B0),
  ];

  Color get _accent => _accentColors[pub.id % _accentColors.length];

  String _readingTime(String texto) {
    final words = texto.trim().split(RegExp(r'\s+')).length;
    final minutes = (words / 200).ceil();
    return '$minutes min';
  }

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

              // Badge "COMUNIDAD"
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border:
                      Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.link_rounded,
                        color: AppColors.primary, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Comunidad',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

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

              // Copiar texto
              GestureDetector(
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: pub.texto));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            const Text('Texto copiado al portapapeles'),
                        backgroundColor: _accent,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadius.md),
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
                  pub.titulo,
                  style: AppTextStyles.h1.copyWith(
                    color: AppColors.primary,
                    fontSize: 26,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Etiquetas
                if (pub.etiquetas != null && pub.etiquetas!.isNotEmpty) ...[
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    children: pub.etiquetas!
                        .map((tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md, vertical: 6),
                              decoration: BoxDecoration(
                                color: _accent.withOpacity(0.15),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.full),
                                border: Border.all(
                                    color: _accent.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.local_offer_rounded,
                                      size: 12, color: _accent),
                                  const SizedBox(width: 4),
                                  Text(
                                    tag,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: _accent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],

                // Info chips: autor + fecha + tiempo de lectura
                Row(
                  children: [
                    _InfoChip(
                      icon: Icons.person_outline_rounded,
                      label: pub.usuarioNombre ?? 'Autor desconocido',
                    ),
                    const SizedBox(width: AppSpacing.md),
                    _InfoChip(
                      icon: Icons.access_time_rounded,
                      label: _readingTime(pub.texto),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                _InfoChip(
                  icon: Icons.calendar_today_rounded,
                  label: _formatDate(pub.fechaCreacion),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Descripción
                Text(
                  'Descripción',
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.text,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  pub.descripcion,
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.textMuted, height: 1.6),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Contenido de la publicación
                Text(
                  'Contenido',
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.text,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Texto principal (igual que _ReadingContent en BookDetailScreen)
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
                    pub.texto,
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

class _PublicationErrorState extends StatelessWidget {
  final VoidCallback onBack;

  const _PublicationErrorState({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.article_outlined,
              size: 64,
              color: AppColors.textMuted.withOpacity(0.4)),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Publicación no encontrada',
            style: AppTextStyles.h2.copyWith(color: AppColors.textMuted),
          ),
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
                      style:
                          AppTextStyles.body.copyWith(color: AppColors.text)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}