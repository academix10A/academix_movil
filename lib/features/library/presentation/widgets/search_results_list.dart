import 'package:flutter/material.dart';
import 'package:academix/core/constants/app_spacing.dart';
import 'package:academix/core/constants/app_radius.dart';
import 'package:academix/core/themes/app_text_styles.dart';
import 'package:academix/core/themes/app_colors.dart';
import 'package:academix/features/library/presentation/viewmodel/search_viewmodel.dart';

/// Lista de resultados de búsqueda reutilizable.
/// Se usa dentro de LibraryScreen (inline) y puede usarse en SearchScreen standalone.
class SearchResultsList extends StatelessWidget {
  final SearchViewModel searchVm;

  const SearchResultsList({super.key, required this.searchVm});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: searchVm.isLoading,
      builder: (context, isLoading, _) {
        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return ValueListenableBuilder<List<SearchResult>>(
          valueListenable: searchVm.searchResults,
          builder: (context, results, _) {
            // Sin texto aún
            if (results.isEmpty &&
                searchVm.searchController.text.trim().isEmpty) {
              return _EmptySearchPrompt();
            }

            // Sin resultados
            if (results.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off,
                        size: 64, color: AppColors.textMuted),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'No se encontraron resultados',
                      style: AppTextStyles.h2
                          .copyWith(color: AppColors.textMuted),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Prueba con otra palabra clave',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              itemCount: results.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final result = results[index];
                return _SearchResultCard(
                  result: result,
                  onTap: () => searchVm.onResultTap(context, result),
                );
              },
            );
          },
        );
      },
    );
  }
}

// Estado inicial (sin texto en el buscador)

class _EmptySearchPrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.manage_search_rounded,
              size: 64, color: AppColors.textMuted.withOpacity(0.4)),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Busca algo para empezar',
            style: AppTextStyles.h2
                .copyWith(color: AppColors.textMuted, fontSize: 18),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Recursos, notas, publicaciones y temas',
            style:
                AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

// Card de resultado

class _SearchResultCard extends StatelessWidget {
  final SearchResult result;
  final VoidCallback onTap;

  const _SearchResultCard({required this.result, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = _getTypeColor(result.type);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          children: [
            // Icono por tipo
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(_getTypeIcon(result.type), color: color, size: 26),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge tipo
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      _getTypeLabel(result.type),
                      style: AppTextStyles.caption.copyWith(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    result.title,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (result.usuario != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      result.usuario!,
                      style:
                          AppTextStyles.caption.copyWith(color: AppColors.primary),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    result.preview,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textMuted),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'resource':
        return AppColors.primary;
      case 'note':
        return AppColors.secondary;
      case 'publication':
        return AppColors.accent;
      case 'tema':
        return const Color(0xFF4CAF50); // verde — diferenciado del resto
      default:
        return AppColors.textMuted;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'resource':
        return Icons.menu_book_rounded;
      case 'note':
        return Icons.sticky_note_2_rounded;
      case 'publication':
        return Icons.article_rounded;
      case 'tema':
        return Icons.category_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'resource':
        return 'RECURSO';
      case 'note':
        return 'NOTA';
      case 'publication':
        return 'PUBLICACIÓN';
      case 'tema':
        return 'TEMA';
      default:
        return type.toUpperCase();
    }
  }
}