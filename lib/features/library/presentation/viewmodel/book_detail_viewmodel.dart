import 'package:flutter/material.dart';
import 'package:academix/features/library/domain/entities/library_entity.dart';
import 'package:academix/features/library/data/datasources/library_remote_datasource.dart';

class BookDetailViewModel {
  final ValueNotifier<LibraryResourceEntity?> resource =
      ValueNotifier(null);

  final ValueNotifier<bool> isLoading = ValueNotifier(true);

  final LibraryRemoteDataSource _remoteDataSource =
      LibraryRemoteDataSource();

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

  Future<void> addFavorite(int idUsuario, int idRecurso) async {
    try {
      await _remoteDataSource.postFavorite(idUsuario, idRecurso);
    } catch (e) {
      // Handle error (snackbar in UI)
    }
  }

  Future<void> deleteFavorite(int idUsuario, int idRecurso) async {
    try {
      await _remoteDataSource.deleteFavorite(idUsuario, idRecurso);
    } catch (e) {
      // Handle error (snackbar in UI)
    }
  }

  void dispose() {
    resource.dispose();
    isLoading.dispose();
  }
}