import 'package:flutter/material.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/features/library/presentation/viewmodel/library_viewmodel.dart';
import 'package:academix/features/profile/presentation/viewmodel/favorites_viewmodel.dart';
import 'package:academix/features/library/presentation/widgets/library_resource_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final LibraryFavoritesViewModel vm = LibraryFavoritesViewModel();
  final LibraryViewModel lvm = LibraryViewModel();

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
        title: Text('Favoritos', style: AppTextStyles.h2.copyWith(color: AppColors.text)),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: vm.favoritesResources,
        builder: (context, resources, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (resources.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: AppColors.textMuted),
                  const SizedBox(height: AppSpacing.md),
                  Text('No tienes favoritos aún', style: AppTextStyles.h2.copyWith(color: AppColors.textMuted)),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Guarda recursos y notas desde la biblioteca', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
                  const SizedBox(height: AppSpacing.lg),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.library_books),
                    label: const Text('Ir a Biblioteca'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: resources.length,
            separatorBuilder: (_,_) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final resource = resources[index];
              return Hero(
                tag: 'book-${resource.id}',
                child: Material(
                  color: Colors.transparent,
                  child: LibraryResourceCard(
                    resource: resource,
                    viewModel: lvm,
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
