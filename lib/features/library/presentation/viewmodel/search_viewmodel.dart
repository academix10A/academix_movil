import 'package:flutter/material.dart';
import 'dart:async';
import 'package:academix/features/library/data/datasources/search_remote_datasource.dart';
import 'package:academix/core/routes/app_routes.dart';
import 'package:academix/features/library/data/models/library_resource_ui_model.dart';

class SearchResult {
  final String id;
  final String type;
  final String title;
  final String preview;
  final String? usuario;
  final String imageUrl;

  const SearchResult({
    required this.id,
    required this.type,
    required this.title,
    required this.preview,
    this.usuario,
    required this.imageUrl,
  });

  factory SearchResult.fromBackend(Map<String, dynamic> json) {
    // El backend devuelve: RECURSO | NOTA | PUBLICACION | TEMA
    final String backendTipo =
        (json['tipo'] as String?)?.toUpperCase() ?? 'RECURSO';

    return SearchResult(
      id: json['id'].toString(),
      type: switch (backendTipo) {
        'RECURSO'     => 'resource',
        'NOTA'        => 'note',
        'PUBLICACION' => 'publication',
        // 'TEMA'        => 'tema',
        _             => 'resource',
      },
      title: json['titulo'] as String? ?? '',
      preview: json['descripcion'] as String? ?? '',
      usuario: json['usuario'] as String?,
      imageUrl: 'assets/images/icon.png',
    );
  }
}

class SearchViewModel {
  final SearchRemoteDataSource searchDataSource;

  SearchViewModel({required this.searchDataSource});

  final searchResults    = ValueNotifier<List<SearchResult>>([]);
  final isLoading        = ValueNotifier<bool>(false);
  final errorMessage     = ValueNotifier<String?>(null);
  final searchController = TextEditingController();

  /// Tabs visibles — "Temas" filtra por subtemas/temas en el backend
  final tabs = <String>['Todos', 'Recursos', 'Notas', 'Publicaciones', 'Temas'];

  /// ValueNotifier para que los chips se reconstruyan al cambiar tab
  final selectedTabNotifier = ValueNotifier<String>('Todos');

  String get selectedTab => selectedTabNotifier.value;

  /// Mapeo tab → tipo que entiende el backend
  String get _selectedTipo => switch (selectedTab) {
    'Todos'         => 'all',
    'Recursos'      => 'recursos',
    'Notas'         => 'notas',
    'Publicaciones' => 'publicaciones',
    'Temas'         => 'temas',
    _               => 'all',
  };

  Timer? _debounceTimer;

  // ── Acciones públicas ─────────────────────────────────────────────────────

  void selectTab(String tab) {
    selectedTabNotifier.value = tab;
    _fetchResults();
  }

  void onSearch(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      const Duration(milliseconds: 450),
      () => _fetchResults(query),
    );
  }

  /// Llamado externamente (p.ej. desde didChangeDependencies)
  Future<void> fetchResults(String query) => _fetchResults(query);

  Future<void> onResultTap(BuildContext context, SearchResult result) async {
    switch (result.type) {
      case 'resource':
        // AppNavigator.push(context, AppRoutes.bookDetail, arguments: result);
        final resource = LibraryResource(
          id: result.id,
          title: result.title,
          category: 'General',
          description: result.preview,
          durationMinutes: 30,
          pages: 10,
          isFavorite: false,
          urlArchivo: null,
          contenido: null,
          idTipo: null,
        );

        AppNavigator.push(
          context,
          AppRoutes.bookDetail,
          arguments: resource,
        );
        break;
      case 'note':
        AppNavigator.push(context, AppRoutes.noteDetailLibrary, arguments: result.id);
        break;
      case 'publication':
        AppNavigator.push(context, AppRoutes.publicationDetailLibrary, arguments: result.id);
        break;
      case 'tema':
        AppNavigator.push(context, AppRoutes.temaDetail, arguments: result.id);
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Abrir ${result.type}: ${result.title}')),
        );
    }
  }

  // ── Lógica interna ────────────────────────────────────────────────────────

  Future<void> _fetchResults([String? query]) async {
    final searchText = query ?? searchController.text;

    if (searchText.trim().isEmpty) {
      searchResults.value = [];
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;

    try {
      final backendResults = await searchDataSource.getSearchResults(
        query: searchText,
        tipo: _selectedTipo,
      );
      searchResults.value = backendResults
          .map((json) => SearchResult.fromBackend(json))
          .toList();
    } catch (e) {
      errorMessage.value = 'Error: $e';
      searchResults.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  void dispose() {
    _debounceTimer?.cancel();
    searchController.dispose();
    searchResults.dispose();
    isLoading.dispose();
    errorMessage.dispose();
    selectedTabNotifier.dispose();
  }
}