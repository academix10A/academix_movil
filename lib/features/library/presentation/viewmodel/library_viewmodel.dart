import 'package:flutter/material.dart';
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

  const LibraryResource({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.durationMinutes,
    required this.pages,
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

  final ValueNotifier<List<String>> categories =
    ValueNotifier<List<String>>(['Todos']);
  
  final LibraryRemoteDataSource _remoteDataSource = LibraryRemoteDataSource();
  List<LibraryResource> _allResources = [];

  LibraryViewModel() {
    searchController.addListener(_applyFilters);
    selectedCategory.addListener(_applyFilters);
    loadResources();
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
        );
      }).toList();

      final uniqueCategories = entities
        .map((e) => e.tema)
        .toSet()
        .toList();

      categories.value = ['Todos', ...uniqueCategories];

      _applyFilters();
    } catch (e) {
      errorMessage.value = 'Error al cargar recursos: $e';
      _allResources = [];
    } finally {
      isLoading.value = false;
    }
  }

  void _applyFilters() {
    final query = searchController.text.toLowerCase();
    final category = selectedCategory.value;

    filteredResources.value = _allResources.where((r) {
      final matchesCategory = category == 'Todos' || r.category == category;
      final matchesQuery = query.isEmpty ||
          r.title.toLowerCase().contains(query) ||
          r.category.toLowerCase().contains(query) ||
          r.description.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
  }

  void onSearch(String query) {
    _applyFilters();
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
  }
}
