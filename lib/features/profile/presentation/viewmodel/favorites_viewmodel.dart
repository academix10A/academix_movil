import 'package:flutter/material.dart';
import 'package:academix/core/network/dio_client.dart';
import 'package:academix/core/routes/app_routes.dart';
import 'package:academix/features/library/data/datasources/library_remote_datasource.dart';
import 'package:academix/features/library/data/models/library_resource_ui_model.dart';

class LibraryFavoritesViewModel {
  final favoritesResources = ValueNotifier<List<LibraryResource>>([]);
  bool isLoading = false;
  int? idUsuario;
  final LibraryRemoteDataSource _remoteDataSource = LibraryRemoteDataSource();

  Future<void> _loadUserId() async {
    try {
      final userResponse = await DioClient.dio.get('/usuarios/me');
      idUsuario = userResponse.data['id_usuario'];
    } catch (e) {
      idUsuario = 1;
    }
  }

  Future<void> loadFavorites() async {
    isLoading = true;
    await _loadUserId();
    if (idUsuario == null) {
      isLoading = false;
      return;
    }
    try {
      // getFavorites() now returns List<LibraryResourceModel>
      // We need .toEntity() first, then LibraryResource.fromEntity()
      final models = await _remoteDataSource.getFavorites(idUsuario!);
      final resources = models
          .map((m) => LibraryResource.fromEntity(m.toEntity()))
          .toList();
      favoritesResources.value = resources;
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    } finally {
      isLoading = false;
    }
  }

  void onItemTap(BuildContext context, LibraryResource resource) {
    AppNavigator.push(context, AppRoutes.bookDetail, arguments: resource);
  }

  void dispose() {
    favoritesResources.dispose();
  }
}