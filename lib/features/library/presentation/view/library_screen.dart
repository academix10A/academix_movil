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
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  Text(
                    "ACADEMIX",
                    style: AppTextStyles.display.copyWith(
                      fontSize: 26,
                      letterSpacing: 2.0,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Section title
                  Text(
                    "Biblioteca",
                    style: AppTextStyles.h1.copyWith(
                      color: AppColors.primary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
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

                  // ── Search bar ──────────────────────────────────────────
                  TextField(
                    readOnly: true,
                    onTap: () {
                      Navigator.pushNamed(context, '/search');
                    },
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.text,
                    ),
                    decoration: InputDecoration(
                      hintText: "Buscar por tema, subtemas",
                      hintStyle: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                      filled: true,
                      fillColor: AppColors.backgroundCard,
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: AppColors.textMuted,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                      // return TextField(
                      //   textInputAction: TextInputAction.search,
                      //   focusNode: searchFocusNode,
                      //   controller: vm.searchController,
                      //   onTap: () {
                      //     Navigator.pushNamed(context, '/search');
                      //   },
                      //   readOnly: true,
                      //   // onSubmitted: (value) {
                      //   //   FocusScope.of(context).unfocus();
                      //   //   if (value.isNotEmpty) {
                      //   //     Navigator.pushReplacementNamed(
                      //   //       context,
                      //   //       '/search',
                      //   //       arguments: value,
                      //   //     );
                      //   //   }
                      //   // },
                      //   style: AppTextStyles.body.copyWith(
                      //     color: AppColors.text,
                      //   ),
                      //   decoration: InputDecoration(
                      //     hintText: isFocused
                      //         ? "Presiona Enter para buscar..."
                      //         : "Buscar por tema, subtemas",
                      //     hintStyle: AppTextStyles.bodySmall.copyWith(
                      //       color: AppColors.textMuted,
                      //     ),
                      //     filled: true,
                      //     fillColor: AppColors.backgroundCard,
                      //     prefixIcon: Icon(
                      //       Icons.search_rounded,
                      //       color: isFocused
                      //           ? AppColors.primary
                      //           : AppColors.textMuted,
                      //     ),
                      //     suffixIcon: ValueListenableBuilder<TextEditingValue>(
                      //       valueListenable: vm.searchController,
                      //       builder: (_, value, __) {
                      //         return value.text.isNotEmpty
                      //             ? IconButton(
                      //                 icon: Icon(
                      //                   Icons.close_rounded,
                      //                   color: AppColors.textMuted,
                      //                   size: 20,
                      //                 ),
                      //                 onPressed: () =>
                      //                     vm.searchController.clear(),
                      //               )
                      //             : const SizedBox.shrink();
                      //       },
                      //     ),
                      //     border: OutlineInputBorder(
                      //       borderRadius:
                      //           BorderRadius.circular(AppRadius.full),
                      //       borderSide: BorderSide.none,
                      //     ),
                      //     focusedBorder: OutlineInputBorder(
                      //       borderRadius:
                      //           BorderRadius.circular(AppRadius.full),
                      //       borderSide: BorderSide(
                      //         color: AppColors.primary.withOpacity(0.6),
                      //         width: 1.5,
                      //       ),
                      //     ),
                      //     contentPadding: const EdgeInsets.symmetric(
                      //       horizontal: AppSpacing.lg,
                      //       vertical: AppSpacing.md,
                      //     ),
                      //   ),
                      // );

                  const SizedBox(height: AppSpacing.md),

                  // ── Category chips ──────────────────────────────────────
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
                                  padding: const EdgeInsets.only(
                                      right: AppSpacing.sm),
                                  child: GestureDetector(
                                    onTap: () =>
                                        vm.selectCategory(category),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                          milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.md,
                                        vertical: AppSpacing.sm,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.primary
                                            : Colors.transparent,
                                        borderRadius:
                                            BorderRadius.circular(
                                                AppRadius.full),
                                        border: Border.all(
                                          color: isSelected
                                              ? AppColors.primary
                                              : AppColors.border,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Text(
                                        category,
                                        style: AppTextStyles.bodySmall
                                            .copyWith(
                                          color: isSelected
                                              ? AppColors.background
                                              : AppColors.text,
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.normal,
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
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),

            // ── Body: search hint OR resource list ───────────────────────
            Expanded(
              child: ValueListenableBuilder<List<LibraryResource>>(
                valueListenable: vm.filteredResources,
                builder: (context, resources, _) {
                  if (resources.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.menu_book_outlined,
                            size: 64,
                            color: AppColors.textMuted.withOpacity(0.5),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'No hay recursos disponibles',
                            style: AppTextStyles.h2.copyWith(
                              color: AppColors.textMuted,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      AppSpacing.lg,
                    ),
                    itemCount: resources.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      return Hero(
                        tag: 'book-${resources[index].id}',
                        child: Material(
                          color: Colors.transparent,
                          child: LibraryResourceCard(
                            resource: resources[index],
                            onTap: () =>
                                vm.onResourceTap(context, resources[index]),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            // Expanded(
            //   child: ValueListenableBuilder<bool>(
            //     valueListenable: vm.isSearchFocused,
            //     builder: (context, isFocused, _) {
            //       if (isFocused) {
            //         // Search hint state
            //         return Center(
            //           child: Column(
            //             mainAxisAlignment: MainAxisAlignment.center,
            //             children: [
            //               Container(
            //                 padding: const EdgeInsets.all(AppSpacing.lg),
            //                 decoration: BoxDecoration(
            //                   color: AppColors.backgroundCard,
            //                   shape: BoxShape.circle,
            //                 ),
            //                 child: Icon(
            //                   Icons.search_rounded,
            //                   size: 48,
            //                   color: AppColors.primary.withOpacity(0.6),
            //                 ),
            //               ),
            //               const SizedBox(height: AppSpacing.md),
            //               Text(
            //                 'Empieza a buscar',
            //                 style: AppTextStyles.h2.copyWith(
            //                   color: AppColors.text,
            //                 ),
            //               ),
            //               const SizedBox(height: AppSpacing.xs),
            //               Text(
            //                 'Presiona Enter para ver resultados',
            //                 style: AppTextStyles.bodySmall.copyWith(
            //                   color: AppColors.textMuted,
            //                 ),
            //               ),
            //             ],
            //           ),
            //         );
            //       }

            //       // Resource list
            //       return ValueListenableBuilder<List<LibraryResource>>(
            //         valueListenable: vm.filteredResources,
            //         builder: (context, resources, _) {
            //           if (resources.isEmpty) {
            //             return Center(
            //               child: Column(
            //                 mainAxisSize: MainAxisSize.min,
            //                 children: [
            //                   Icon(
            //                     Icons.menu_book_outlined,
            //                     size: 64,
            //                     color: AppColors.textMuted.withOpacity(0.5),
            //                   ),
            //                   const SizedBox(height: AppSpacing.md),
            //                   Text(
            //                     'No hay recursos disponibles',
            //                     style: AppTextStyles.h2.copyWith(
            //                       color: AppColors.textMuted,
            //                       fontSize: 18,
            //                     ),
            //                   ),
            //                 ],
            //               ),
            //             );
            //           }

            //           return ListView.separated(
            //             padding: const EdgeInsets.fromLTRB(
            //               AppSpacing.lg,
            //               0,
            //               AppSpacing.lg,
            //               AppSpacing.lg,
            //             ),
            //             itemCount: resources.length,
            //             separatorBuilder: (_, __) =>
            //                 const SizedBox(height: AppSpacing.md),
            //             itemBuilder: (context, index) {
            //               return Hero(
            //                 tag: 'book-${resources[index].id}',
            //                 child: Material(
            //                   color: Colors.transparent,
            //                   child: LibraryResourceCard(
            //                     resource: resources[index],
            //                     onTap: () =>
            //                         vm.onResourceTap(context, resources[index]),
            //                   ),
            //                 ),
            //               );
            //             },
            //           );
            //         },
            //       );
            //     },
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}