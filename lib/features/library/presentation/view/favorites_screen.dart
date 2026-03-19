import 'package:flutter/material.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/constants/app_radius.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/themes/app_colors.dart';
import '../viewmodel/favorites_viewmodel.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesViewModel vm = FavoritesViewModel();

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
        valueListenable: vm.favorites,
        builder: (context, favorites, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (favorites.isEmpty) {
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
            itemCount: favorites.length,
            separatorBuilder: (_,_) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final item = favorites[index];
              GestureDetector(
                onTap: () => vm.onItemTap(context, item),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundCard,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(Icons.favorite, color: AppColors.accent),
                    ),
                    title: Text(item.title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                    subtitle: Text(item.tema + ' • ' + item.preview, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
                    trailing: Icon(Icons.arrow_forward_ios, color: AppColors.textMuted, size: 16),
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

