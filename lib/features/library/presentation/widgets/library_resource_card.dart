import 'package:flutter/material.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/constants/app_radius.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/features/library/data/models/library_resource_ui_model.dart';
import 'package:academix/features/library/presentation/viewmodel/library_viewmodel.dart';

class LibraryResourceCard extends StatelessWidget {
  final LibraryResource resource;
  final VoidCallback onTap;
  final LibraryViewModel viewModel;

  const LibraryResourceCard({
    super.key,
    required this.resource,
    required this.onTap,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Row(
            children: [
              // Left thumbnail / icon section
              Container(
                width: 110,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withOpacity(0.25),
                      AppColors.primary.withOpacity(0.08),
                    ],
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      size: 30,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),

              // Right content section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Category badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          borderRadius:
                              BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          resource.category,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xs),

                      // Title
                      Text(
                        resource.title,
                        style: AppTextStyles.h2.copyWith(
                          color: AppColors.text,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: AppSpacing.xs),

                      // Stats row
                      Row(
                        children: [
                          // const Icon(
                          //   Icons.access_time_rounded,
                          //   size: 12,
                          //   color: AppColors.textMuted,
                          // ),
                          // const SizedBox(width: 3),
                          // Text(
                          //   '${resource.durationMinutes} min',
                          //   style: AppTextStyles.caption.copyWith(
                          //     color: AppColors.textMuted,
                          //   ),
                          // ),
                          // const SizedBox(width: AppSpacing.sm),
                          // const Icon(
                          //   Icons.description_outlined,
                          //   size: 12,
                          //   color: AppColors.textMuted,
                          // ),
                          // const SizedBox(width: 3),
                          // Text(
                          //   '${resource.pages} págs',
                          //   style: AppTextStyles.caption.copyWith(
                          //     color: AppColors.textMuted,
                          //   ),
                          // ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.xs),

                      // Rating + Favorite row
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          // Stars
                          // Row(
                          //   children: [
                          //     ...List.generate(
                          //       5,
                          //       (i) => Icon(
                          //         i < 4
                          //             ? Icons.star_rounded
                          //             : Icons.star_border_rounded,
                          //         color: AppColors.primary,
                          //         size: 13,
                          //       ),
                          //     ),
                          //     const SizedBox(width: 4),
                          //     Text(
                          //       '4.5',
                          //       style: AppTextStyles.caption.copyWith(
                          //         color: AppColors.textMuted,
                          //       ),
                          //     ),
                          //   ],
                          // ),

                          // Favorite button
                          ValueListenableBuilder<Set<String>>(
                            valueListenable:
                                viewModel.favoriteResourceIds,
                            builder: (context, favorites, _) {
                              final isFavorite =
                                  favorites.contains(resource.id);
                              return GestureDetector(
                                onTap: () => viewModel
                                    .toggleFavorite(resource.id),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: isFavorite
                                        ? AppColors.accent
                                            .withOpacity(0.1)
                                        : AppColors.background
                                            .withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isFavorite
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    color: isFavorite
                                        ? AppColors.accent
                                        : AppColors.textMuted,
                                    size: 16,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}