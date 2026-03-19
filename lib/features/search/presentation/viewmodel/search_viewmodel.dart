import 'package:flutter/material.dart';

class SearchResult {
  final String id;
  final String type; // 'resource', 'note', 'exam'
  final String title;
  final String tema;
  final String preview;
  final String imageUrl;

  SearchResult({
    required this.id,
    required this.type,
    required this.title,
    required this.tema,
    required this.preview,
    required this.imageUrl,
  });
}

class SearchViewModel {
  final searchResults = ValueNotifier<List<SearchResult>>(_getMockData());
  final TextEditingController searchController = TextEditingController();
  final tabs = <String>['Todos', 'Recursos', 'Notas', 'Exámenes'];
  String selectedTab = 'Todos';

  void selectTab(String tab) {
    selectedTab = tab;
    _filterResults();
  }

  void onSearch(String query) {
    searchController.text = query;
    _filterResults();
  }

  void onResultTap(BuildContext context, SearchResult result) {
    // TODO: Nav to detail based type
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Abrir ${result.type}: ${result.title}')),
    );
  }

  void dispose() {
    searchController.dispose();
    searchResults.dispose();
  }

  void _filterResults() {
    List<SearchResult> results = _getMockData();
    if (searchController.text.isNotEmpty) {
      results = results.where((r) => r.title.toLowerCase().contains(
        searchController.text.toLowerCase()
      ) || r.tema.toLowerCase().contains(searchController.text.toLowerCase())).toList();
    }
    if (selectedTab != 'Todos') {
      results = results.where((r) => r.type == selectedTab.toLowerCase()).toList();
    }
    searchResults.value = results;
  }

  static List<SearchResult> _getMockData() {
    return [
      SearchResult(
        id: '1',
        type: 'resource',
        title: 'Introducción a Álgebra',
        tema: 'Matemáticas / Álgebra',
        preview: 'Conceptos básicos de ecuaciones lineales y funciones.',
        imageUrl: 'assets/images/icon.png',
      ),
      SearchResult(
        id: '2',
        type: 'note',
        title: 'Mis notas sobre Historia Antigua',
        tema: 'Historia / Antigua',
        preview: 'Resumen del Imperio Romano y Grecia Clásica.',
        imageUrl: 'assets/images/icon.png',
      ),
      SearchResult(
        id: '3',
        type: 'exam',
        title: 'Examen de Biología Celular',
        tema: 'Biología / Celular',
        preview: '20 preguntas sobre mitosis y meiosis.',
        imageUrl: 'assets/images/icon.png',
      ),
      SearchResult(
        id: '4',
        type: 'resource',
        title: 'Física Newtoniana',
        tema: 'Física / Mecánica',
        preview: 'Leyes del movimiento.',
        imageUrl: 'assets/images/icon.png',
      ),
      SearchResult(
        id: '5',
        type: 'note',
        title: 'Notas Literatura',
        tema: 'Literatura / Siglo XIX',
        preview: 'Romanticismo.',
        imageUrl: 'assets/images/icon.png',
      ),
    ];
  }
}

