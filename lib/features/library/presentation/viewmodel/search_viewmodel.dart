import 'package:flutter/material.dart';
import 'dart:async';
import 'package:academix/features/library/data/datasources/search_remote_datasource.dart';

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
    final String backendTipo =
        (json['tipo'] as String?)?.toLowerCase() ?? 'recurso';

    return SearchResult(
      id: json['id'].toString(),
      type: switch (backendTipo) {
        'recurso' => 'resource',
        'nota' => 'note',
        'tema' => 'tema',
        _ => 'resource',
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

  final searchResults = ValueNotifier<List<SearchResult>>([]);
  final isLoading = ValueNotifier<bool>(false);
  final errorMessage = ValueNotifier<String?>(null);
  final searchController = TextEditingController();
  final tabs = <String>['Todos', 'Recursos', 'Notas', 'Temas'];

  String selectedTab = 'Todos';
  String _selectedTipo = 'all';
  Timer? _debounceTimer;

  void selectTab(String tab) {
    selectedTab = tab;
    _selectedTipo = switch (tab) {
      'Todos' => 'all',
      'Recursos' => 'recursos',
      'Notas' => 'notas',
      'Temas' => 'temas',
      _ => 'all',
    };
    _fetchResults();
  }

  Future<void> onSearch(String query) async {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      const Duration(milliseconds: 500),
      () => _fetchResults(query),
    );
  }

  void onResultTap(BuildContext context, SearchResult result) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Abrir ${result.type}: ${result.title}')),
    );
  }

  Future<void> fetchResults(String query) async {
    await _fetchResults(query);
  }

  Future<void> _fetchResults([String? query]) async {
    final searchText = query ?? searchController.text;

    if (searchText.length < 2) {
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
  }
}