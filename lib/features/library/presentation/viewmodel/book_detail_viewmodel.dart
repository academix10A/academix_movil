import 'package:flutter/material.dart';
import 'package:academix/features/library/domain/entities/library_resource_entity.dart';
import 'package:academix/features/library/domain/usecases/get_resource_by_id_usecase.dart';
import 'package:academix/features/library/domain/usecases/get_favorites_usecase.dart';
import 'package:academix/features/library/domain/usecases/toggle_favorite_usecase.dart';

class BookDetailViewModel {
  final GetResourceByIdUseCase getResourceByIdUseCase;
  final GetFavoritesUseCase getFavoritesUseCase;
  final ToggleFavoriteUseCase toggleFavoriteUseCase;
  final int idUsuario;

  BookDetailViewModel({
    required this.getResourceByIdUseCase,
    required this.getFavoritesUseCase,
    required this.toggleFavoriteUseCase,
    required this.idUsuario,
  });

  final ValueNotifier<LibraryResourceEntity?> resource = ValueNotifier(null);
  final ValueNotifier<bool> isLoading = ValueNotifier(true);
  final ValueNotifier<bool> isFavorite = ValueNotifier(false);

  Future<void> loadFavoriteStatus(int idRecurso) async {
    try {
      final favorites = await getFavoritesUseCase(idUsuario);
      isFavorite.value = favorites.any((e) => e.idRecurso == idRecurso);
    } catch (_) {
      // Non-critical
    }
  }

  Future<void> toggleFavorite(int idRecurso) async {
    try {
      await toggleFavoriteUseCase(
        idUsuario: idUsuario,
        idRecurso: idRecurso,
        isCurrentlyFavorite: isFavorite.value,
      );
      isFavorite.value = !isFavorite.value;
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
    }
  }

  Future<void> loadResource(int id) async {
    // Si ya hay datos precargados, NO mostramos spinner
    // Solo actualizamos en segundo plano silenciosamente
    final yaHayDatos = resource.value != null;
    if (!yaHayDatos) isLoading.value = true;

    try {
      final resultado = await getResourceByIdUseCase(id);
      resource.value = resultado;
    } catch (_) {
      // Sin internet: si había datos precargados los conservamos
      // Si no había nada, resource.value queda null
    } finally {
      isLoading.value = false;
    }
  }

  void dispose() {
    resource.dispose();
    isLoading.dispose();
    isFavorite.dispose();
  }
}