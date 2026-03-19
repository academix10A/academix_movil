import 'package:flutter/material.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/core/constants/app_radius.dart';
import 'package:academix/features/library/presentation/viewmodel/library_viewmodel.dart';
import 'package:academix/features/library/presentation/widgets/library_resource_card.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final LibraryViewModel vm = LibraryViewModel();

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con logo
                  Text(
                    "ACADEMIX",
                    style: AppTextStyles.display.copyWith(
                      fontSize: 28,
                      letterSpacing: 1.5,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Título sección
                  Text(
                    "Biblioteca",
                    style: AppTextStyles.h1.copyWith(
                      color: AppColors.primary,
                      fontSize: 28,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  Text(
                    "Explora recursos educativos",
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Barra de búsqueda - Navega a SearchScreen
                  TextField(
                    controller: vm.searchController,
                    onSubmitted: (value) {
                      vm.onSearch(value);
                      Navigator.pushNamed(context, '/search');
                    },
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textMuted,
                    ),
                    decoration: InputDecoration(
                      hintText: "Buscar por tema, subtemas",
                      hintStyle: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                      filled: true,
                      fillColor: AppColors.backgroundCard,
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.textMuted,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                    ),
                  ),


                  const SizedBox(height: AppSpacing.md),

                  // Filtros de categorías
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ValueListenableBuilder<List<String>>(
                      valueListenable: vm.categories,
                      builder: (context, categories, _) {
                        return ValueListenableBuilder<String>(
                          valueListenable: vm.selectedCategory,
                          builder: (context, selected, _) {
                            return Row(
                              children: categories.map((category) {
                                final isSelected = selected == category;
                                return Padding(
                                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                                  child: GestureDetector(
                                    onTap: () => vm.selectCategory(category),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.md,
                                        vertical: AppSpacing.sm,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.primary
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(AppRadius.full),
                                        border: Border.all(
                                          color: isSelected
                                              ? AppColors.primary
                                              : AppColors.border,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Text(
                                        category,
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: isSelected
                                              ? AppColors.background
                                              : AppColors.text,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        );
                      },
                    )
                  ),

                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),

            // Contenido scrollable - Always show resources
            Expanded(
              child: ValueListenableBuilder<List<LibraryResource>>(
                valueListenable: vm.filteredResources,
                builder: (context, resources, _) {
                  if (resources.isEmpty) {
                    return const Center(child: Text("No hay recursos"));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    itemCount: resources.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) => LibraryResourceCard(
                      resource: resources[index],
                      onTap: () => vm.onResourceTap(context, resources[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
