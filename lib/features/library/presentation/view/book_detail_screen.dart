import 'package:flutter/material.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/core/constants/app_radius.dart';
import 'package:academix/core/routes/app_routes.dart';
import 'package:academix/features/library/presentation/viewmodel/library_viewmodel.dart';

class BookDetailScreen extends StatefulWidget {
  final LibraryResource resource;

  const BookDetailScreen({super.key, required this.resource});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  double _fontSize = 16.0;
  bool _isReadingMode = false;

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
                      _ReadingContent(fontSize: _fontSize),
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

  const _ReadingContent({required this.fontSize});

  @override
  Widget build(BuildContext context) {
    // Contenido de ejemplo - reemplazar con contenido real del libro
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Text(
        _sampleContent,
        style: AppTextStyles.body.copyWith(
          color: AppColors.text,
          height: 1.8,
          fontSize: fontSize,
        ),
      ),
    );
  }

  static const String _sampleContent = '''
En este capítulo exploraremos los fundamentos del tema seleccionado.

Introducción
------------

El estudio de esta materia es fundamental para comprender los fenómenos que ocurren en nuestro entorno. A lo largo de este material, we'll cover los conceptos básicos que necesitas saber.

Conceptos Fundamentales
-----------------------

1. Definición del primer concepto
   El primer concepto fundamental establece las bases para comprender los temas más avanzados que se tratarán posteriormente.

2. Principios básicos
   Los principios que rigen esta disciplina son esenciales para cualquier estudiante que busque dominar la materia.

3. Aplicaciones prácticas
   Estas aplicaciones te permitirán ver cómo la teoría se traduce en práctica en situaciones reales.

Conclusión
----------

Este material te ha proporcionado las herramientas básicas para seguir avanzando en tu aprendizaje. Te recomendamos practicar con los ejercicios proporcionados al final de cada capítulo.
''';
}

