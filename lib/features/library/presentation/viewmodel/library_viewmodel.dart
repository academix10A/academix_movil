import 'package:flutter/material.dart';
import 'package:academix/core/routes/app_routes.dart';
import 'package:academix/features/library/domain/usecases/get_resources_from_temas_usecase.dart';
import 'package:academix/features/library/domain/usecases/get_favorites_usecase.dart';
import 'package:academix/features/library/domain/usecases/toggle_favorite_usecase.dart';
import 'package:academix/features/library/data/models/library_resource_ui_model.dart';

class LibraryViewModel {
  final GetResourcesFromTemasUseCase getResourcesFromTemasUseCase;
  final GetFavoritesUseCase getFavoritesUseCase;
  final ToggleFavoriteUseCase toggleFavoriteUseCase;

  // Required externally — injected by the View after obtaining the current user
  final int idUsuario;

  LibraryViewModel({
    required this.getResourcesFromTemasUseCase,
    required this.getFavoritesUseCase,
    required this.toggleFavoriteUseCase,
    required this.idUsuario,
  }) {
    selectedCategory.addListener(_applyFilters);
    loadResources();
  }

  final TextEditingController searchController = TextEditingController();
  final ValueNotifier<String> selectedCategory = ValueNotifier<String>('Todos');
  final ValueNotifier<List<LibraryResource>> filteredResources =
      ValueNotifier<List<LibraryResource>>([]);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);
  final ValueNotifier<Set<String>> favoriteResourceIds =
      ValueNotifier<Set<String>>({});
  final ValueNotifier<List<String>> categories =
      ValueNotifier<List<String>>(['Todos']);

  List<LibraryResource> _allResources = [];

  Future<void> loadResources() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final entities = await getResourcesFromTemasUseCase();
      _allResources = entities
          .map((e) => LibraryResource.fromTemaEntity(e))
          .toList();

      final uniqueCategories = entities.map((e) => e.tema).toSet().toList();
      categories.value = ['Todos', ...uniqueCategories];

      await _loadFavorites();
      _applyFilters();
    } catch (e) {
      errorMessage.value = 'Error al cargar recursos: $e';
      _allResources = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadFavorites() async {
    try {
      final favorites = await getFavoritesUseCase(idUsuario);
      final ids = favorites.map((e) => e.idRecurso.toString()).toSet();
      favoriteResourceIds.value = ids;
      _updateResourceFavorites();
    } catch (_) {
      // Favorites are non-critical; silently ignore errors
    }
  }

  void _applyFilters() {
    final category = selectedCategory.value;
    filteredResources.value = _allResources.where((r) {
      return category == 'Todos' || r.category == category;
    }).toList();
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
  }

  Future<void> toggleFavorite(String idRecurso) async {
    final isCurrentlyFavorite = favoriteResourceIds.value.contains(idRecurso);

    try {
      await toggleFavoriteUseCase(
        idUsuario: idUsuario,
        idRecurso: int.parse(idRecurso),
        isCurrentlyFavorite: isCurrentlyFavorite,
      );

      final updated = Set<String>.from(favoriteResourceIds.value);
      if (isCurrentlyFavorite) {
        updated.remove(idRecurso);
      } else {
        updated.add(idRecurso);
      }
      favoriteResourceIds.value = updated;
      _updateResourceFavorites();
      _applyFilters();
    } catch (e) {
      errorMessage.value = 'Error al actualizar favorito: $e';
    }
  }

  void _updateResourceFavorites() {
    final ids = favoriteResourceIds.value;
    _allResources = _allResources
        .map((r) => r.copyWith(isFavorite: ids.contains(r.id)))
        .toList();
  }

  void onResourceTap(BuildContext context, LibraryResource resource) {
    AppNavigator.push(
      context,
      AppRoutes.bookDetail,
      arguments: resource,
    );
  }

  void dispose() {
    searchController.dispose();
    selectedCategory.dispose();
    filteredResources.dispose();
    isLoading.dispose();
    errorMessage.dispose();
    favoriteResourceIds.dispose();
    categories.dispose();
  }
}