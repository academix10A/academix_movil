import 'package:flutter/material.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/core/constants/app_radius.dart';
import 'package:academix/core/routes/app_routes.dart';
import 'package:academix/features/ai/presentation/view/ai_chat_screen.dart';
import 'package:academix/features/library/presentation/viewmodel/book_detail_viewmodel.dart';
import 'package:academix/features/library/presentation/viewmodel/library_viewmodel.dart';
import 'package:academix/features/library/domain/entities/library_entity.dart';

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

  @override
  void initState() {
    super.initState();
    vm.loadResource(int.parse(widget.resource.id));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
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
                      // Botón modo lectura
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isReadingMode = !_isReadingMode;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: _isReadingMode
                                ? AppColors.primary
                                : AppColors.backgroundCard,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Icon(
                            Icons.menu_book_rounded,
                            color: _isReadingMode
                                ? AppColors.background
                                : AppColors.text,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      // Botón aumentar fonte
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _fontSize = (_fontSize + 2).clamp(14.0, 28.0);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundCard,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Icon(
                            Icons.text_increase_rounded,
                            color: AppColors.text,
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
                        // Título
                        Text(
                          widget.resource.title,
                          style: AppTextStyles.h1.copyWith(
                            color: AppColors.primary,
                            fontSize: 26,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.sm),

                        // Categoría
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            widget.resource.category,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        // Info: Duración y páginas
                        Row(
                          children: [
                            _InfoChip(
                              icon: Icons.access_time_rounded,
                              label: "${widget.resource.durationMinutes} min",
                            ),
                            const SizedBox(width: AppSpacing.md),
                            _InfoChip(
                              icon: Icons.description_outlined,
                              label: "${widget.resource.pages} páginas",
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        // Descripción
                        Text(
                          "Descripción",
                          style: AppTextStyles.h2.copyWith(
                            color: AppColors.text,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          widget.resource.description,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textMuted,
                            height: 1.6,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        // Contenido del libro (modo lectura)
                        if (_isReadingMode) ...[
                          Text(
                            "Contenido",
                            style: AppTextStyles.h2.copyWith(
                              color: AppColors.text,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          ValueListenableBuilder<bool>(
                            valueListenable: vm.isLoading,
                            builder: (context, loading, _) {
                              if (loading) {
                                return const Center(child: CircularProgressIndicator());
                              }

                              return ValueListenableBuilder<LibraryResourceEntity?>(
                                valueListenable: vm.resource,
                                builder: (context, resource, _) {
                                  if (resource == null) {
                                    return const Text("Error al cargar contenido");
                                  }

                                  return _ReadingContent(
                                    fontSize: _fontSize,
                                    content: resource.contenido ?? "Sin contenido",
                                  );
                                },
                              );
                            },
                          )
                        ],

                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
                ),

                // Botón empezar a leer
                if (!_isReadingMode)
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isReadingMode = true;
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.auto_stories_rounded,
                              color: AppColors.background,
                              size: 22,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              "Empezar a leer",
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.background,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // AI Button overlay when reading
          if (_isReadingMode)
            Positioned(
              right: AppSpacing.xl,
              bottom: AppSpacing.xxl,
              child: GestureDetector(
                onTap: () => _showAiModal(context),
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
                  child: const Icon(
                    Icons.smart_toy,
                    color: AppColors.background,
                    size: 28,
                  ),
                ),
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
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
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
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadingContent extends StatelessWidget {
  final double fontSize;
  final String content;

  const _ReadingContent({
    required this.fontSize,
    required this.content,
  });

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
          color: AppColors.text,
          height: 1.8,
          fontSize: fontSize,
        ),
      ),
    );
  }
}
