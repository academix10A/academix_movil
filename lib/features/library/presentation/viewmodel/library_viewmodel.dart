import 'package:flutter/material.dart';
import '../../../../core/network/dio_client.dart';
import 'package:academix/core/routes/app_routes.dart';
import 'package:academix/features/library/domain/entities/library_entity.dart';
import 'package:academix/features/library/data/datasources/library_remote_datasource.dart';

class LibraryResource {
  final String id;
  final String title;
  final String category;
  final String description;
  final int durationMinutes;
final int pages;
  final bool isFavorite;

  const LibraryResource({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.durationMinutes,
    required this.pages,
    this.isFavorite = false,
  });



  // Mapper desde entity
  factory LibraryResource.fromEntity(LibraryResourceEntity entity) {
    return LibraryResource(
      id: entity.idRecurso.toString(),
      title: entity.titulo,
      category: entity.category,
      description: entity.descripcion ?? '',
      durationMinutes: entity.durationMinutes,
      pages: entity.pages,
      isFavorite: false,
    );
  }
}

class LibraryViewModel {

  final TextEditingController searchController = TextEditingController();
  final ValueNotifier<String> selectedCategory = ValueNotifier<String>('Todos');
  final ValueNotifier<List<LibraryResource>> filteredResources =
      ValueNotifier<List<LibraryResource>>([]);

  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);
  final ValueNotifier<bool> isSearchFocused = ValueNotifier<bool>(false);

  final ValueNotifier<Set<String>> favoriteResourceIds = ValueNotifier<Set<String>>( {});
  int? idUsuario;

  Future<void> _loadUserId() async {
    try {
      final userResponse = await DioClient.dio.get('/usuarios/me');
      idUsuario = userResponse.data['id_usuario'];
    } catch (e) {
      debugPrint('Error loading user ID: $e');
      idUsuario = 1; // fallback
    }
  }

  final ValueNotifier<List<String>> categories =
    ValueNotifier<List<String>>(['Todos']);
  
  final LibraryRemoteDataSource _remoteDataSource = LibraryRemoteDataSource();
  List<LibraryResource> _allResources = [];

  LibraryViewModel() {
    selectedCategory.addListener(_applyFilters);
    _loadUserId().then((_) => loadResources());
  }

  Future<void> loadFavorites() async {
    if (idUsuario == null) return;
    try {
      final favorites = await _remoteDataSource.getFavorites(idUsuario!);
      final ids = favorites.map((e) => e.idRecurso.toString()).toSet();
      favoriteResourceIds.value = ids;

      _updateResourceFavorites();
      _applyFilters();
    } catch (e) {
      errorMessage.value = 'Error al cargar favoritos: $e';
    }
  }

  Future<void> loadResources() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final entities = await _remoteDataSource.getResourcesFromTemas();

      _allResources = entities.map((e) {
        return LibraryResource(
          id: e.id.toString(),
          title: e.titulo,
          category: e.tema,
          description: e.descripcion,
          durationMinutes: 30,
          pages: 10,
          isFavorite: false,
        );
      }).toList();

      final uniqueCategories = entities
        .map((e) => e.tema)
        .toSet()
        .toList();

      categories.value = ['Todos', ...uniqueCategories];

      await loadFavorites();

      _applyFilters();
    } catch (e) {
      errorMessage.value = 'Error al cargar recursos: $e';
      _allResources = [];
    } finally {
      isLoading.value = false;
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

  void onSearch(String query) {
    // No local filter, navigate to search
  }

  Future<void> toggleFavorite(String idRecurso) async {
    try {
      final currentFavorites = favoriteResourceIds.value;
      final isCurrentlyFavorite = currentFavorites.contains(idRecurso);

      if (isCurrentlyFavorite) {
        await _remoteDataSource.deleteFavorite(idUsuario!, int.parse(idRecurso));
      } else {
        await _remoteDataSource.postFavorite(idUsuario!, int.parse(idRecurso));
      }

      // Update local state
      final updated = Set<String>.from(currentFavorites);
      if (isCurrentlyFavorite) {
        updated.remove(idRecurso);
      } else {
        updated.add(idRecurso);
      }
      favoriteResourceIds.value = updated;

      // Update _allResources isFavorite and refresh
      _updateResourceFavorites();
      _applyFilters();
    } catch (e) {
      errorMessage.value = 'Error al toggle favorito: $e';
    }
  }

  void _updateResourceFavorites() {
    final ids = favoriteResourceIds.value;
    _allResources = _allResources.map((r) {
      return LibraryResource(
        id: r.id,
        title: r.title,
        category: r.category,
        description: r.description,
        durationMinutes: r.durationMinutes,
        pages: r.pages,
        isFavorite: ids.contains(r.id),
      );
    }).toList();
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
  }
}
