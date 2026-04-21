import 'package:flutter/material.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/constants/app_radius.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/features/library/data/models/library_resource_ui_model.dart';
import 'package:academix/features/profile/presentation/viewmodel/favorites_viewmodel.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final LibraryFavoritesViewModel vm = LibraryFavoritesViewModel();

  @override
  void initState() {
    super.initState();
    vm.loadFavorites();
  }

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Favoritos',
            style: AppTextStyles.h2.copyWith(color: AppColors.text)),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ValueListenableBuilder<List<LibraryResource>>(
        valueListenable: vm.favoritesResources,
        builder: (context, resources, _) {
          if (vm.isLoading) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (resources.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border,
                      size: 80, color: AppColors.textMuted),
                  const SizedBox(height: AppSpacing.md),
                  Text('No tienes favoritos aún',
                      style: AppTextStyles.h2
                          .copyWith(color: AppColors.textMuted)),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Guarda recursos y notas desde la biblioteca',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.library_books),
                    label: const Text('Ir a Biblioteca'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: resources.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final resource = resources[index];
              return Hero(
                tag: 'book-${resource.id}',
                child: Material(
                  color: Colors.transparent,
                  child: _FavoriteResourceCard(
                    resource: resource,
                    onTap: () => vm.onItemTap(context, resource),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Simplified card for the favorites screen.
/// Does not need a LibraryViewModel — favorite toggling is handled by FavoritesViewModel.
class _FavoriteResourceCard extends StatelessWidget {
  final LibraryResource resource;
  final VoidCallback onTap;

  const _FavoriteResourceCard({
    required this.resource,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(Icons.menu_book_rounded,
                  size: 28, color: AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.md),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resource.title,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    resource.category,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.primary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${resource.pages} págs • ${resource.durationMinutes} min',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.favorite_rounded,
                color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}