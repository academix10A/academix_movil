import 'package:flutter/material.dart';
import 'package:academix/core/network/dio_client.dart';
import 'package:academix/features/library/domain/entities/library_entity.dart';
import 'package:academix/features/library/data/datasources/library_remote_datasource.dart';

class BookDetailViewModel {
  final ValueNotifier<LibraryResourceEntity?> resource =
      ValueNotifier(null);

  final ValueNotifier<bool> isLoading = ValueNotifier(true);

  final ValueNotifier<bool> isFavorite = ValueNotifier(false);

  int? idUsuario;

  final LibraryRemoteDataSource _remoteDataSource =
      LibraryRemoteDataSource();

  Future<void> loadUserId() async {
    try {
      final userResponse = await DioClient.dio.get('/usuarios/me');
      idUsuario = userResponse.data['id_usuario'];
    } catch (e) {
      debugPrint('Error loading user ID: $e');
      idUsuario = 1; // fallback
    }
  }

  Future<void> loadFavoriteStatus(int idRecurso) async {
    if (idUsuario == null) await loadUserId();
    if (idUsuario == null) return;

    try {
      final favorites = await _remoteDataSource.getFavorites(idUsuario!);
      isFavorite.value = favorites.any((e) => e.idRecurso == idRecurso);
    } catch (e) {
      debugPrint('Error loading favorite status: $e');
    }
  }

  Future<void> toggleFavorite(int idRecurso) async {
    if (idUsuario == null) await loadUserId();
    if (idUsuario == null) return;

    try {
      if (isFavorite.value) {
        await _remoteDataSource.deleteFavorite(idUsuario!, idRecurso);
      } else {
        await _remoteDataSource.postFavorite(idUsuario!, idRecurso);
      }
      isFavorite.value = !isFavorite.value;
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
    }
  }

  Future<void> loadResource(int id) async {
    try {
      isLoading.value = true;

      final data = await _remoteDataSource.getRecursoById(id);

      resource.value = data;
    } catch (e) {
      resource.value = null;
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
