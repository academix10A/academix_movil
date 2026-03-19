import 'package:flutter/material.dart';

class FavoritesViewModel {
  final favorites = ValueNotifier<List<FavoriteItem>>(_mockFavorites());
  bool isLoading = false;

  Future<void> loadFavorites() async {
    isLoading = true;
    await Future.delayed(const Duration(seconds: 1));
    favorites.value = _mockFavorites();
    isLoading = false;
  }

  static List<FavoriteItem> _mockFavorites() {
    return [
      FavoriteItem(
        id: 'f1',
        type: 'resource',
        title: 'Favorito Álgebra',
        tema: 'Matemáticas',
        preview: 'Ecuaciones básicas.',
      ),
      FavoriteItem(
        id: 'f2',
        type: 'note',
        title: 'Mi nota favorita',
        tema: 'Historia',
        preview: 'Resumen importante.',
      ),
    ];
  }

  void toggleFavorite(FavoriteItem item) {
    // TODO
  }

  void onItemTap(BuildContext context, FavoriteItem item) {
    // Nav to detail
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Abrir ${item.title}')),
    );
  }

  void dispose() {
    favorites.dispose();
  }
}

class FavoriteItem {
  final String id;
  final String type;
  final String title;
  final String tema;
  final String preview;

  FavoriteItem({
    required this.id,
    required this.type,
    required this.title,
    required this.tema,
    required this.preview,
  });
}

