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

  SearchResult({
    required this.id,
    required this.type,
    required this.title,
    required this.preview,
    this.usuario,
    required this.imageUrl,
  });

  factory SearchResult.fromBackend(Map<String, dynamic> json) {
    final String backendTipo = (json['tipo'] as String?)?.toLowerCase() ?? 'recurso';

    return SearchResult(
      id: json['id'].toString(),
      type: switch (backendTipo) {
        'recurso' => 'resource',
        'nota' => 'note',
        'tema' => 'tema',
        _ => 'resource',
      },
      title: json['titulo'] ?? '',
      preview: json['descripcion'] ?? '',
      usuario: json['usuario'],
      imageUrl: 'assets/images/icon.png',
    );
  }
}

class SearchViewModel {
  final searchResults = ValueNotifier<List<SearchResult>>([]);
  final isLoading = ValueNotifier<bool>(false);
  final errorMessage = ValueNotifier<String?>(null);
  final TextEditingController searchController = TextEditingController();
  final tabs = <String>['Todos', 'Recursos', 'Notas', 'Temas'];
  String selectedTab = 'Todos';
  String currentQuery = '';
  String selectedTipo = 'all';
  Timer? _debounceTimer;

  SearchViewModel() {
    _updateTipo();
  }

  void _updateTipo() {
    selectedTipo = switch (selectedTab) {
      'Todos' => 'all',
      'Recursos' => 'recursos',
      'Notas' => 'notas',
      'Temas' => 'temas',
      _ => 'all',
    };
  }

  void selectTab(String tab) {
    selectedTab = tab;
    selectedTipo = switch (tab) {
      'Todos' => 'all',
      'Recursos' => 'recursos',
      'Notas' => 'notas',
      'Temas' => 'temas',
      _ => 'all',
    };
    _fetchResults();
  }

  Future<void> onSearch(String query) async {
    currentQuery = query;

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

  void dispose() {
    _debounceTimer?.cancel();
    searchController.dispose();
    searchResults.dispose();
    isLoading.dispose();
    errorMessage.dispose();
  }

  Future<void> _fetchResults([String? query]) async {
    final searchText = query ?? searchController.text;

    print("QUERY: $searchText");

    if (searchText.length < 2) {
      searchResults.value = [];
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;

    try {
      final backendResults = await SearchRemoteDataSource.getSearchResults(
        query: searchText,
        tipo: selectedTipo,
      );

      searchResults.value =
          backendResults.map((json) => SearchResult.fromBackend(json)).toList();
    } catch (e) {
      errorMessage.value = 'Error: $e';
      searchResults.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchResults(String query) async {
    await _fetchResults(query);
  }
}