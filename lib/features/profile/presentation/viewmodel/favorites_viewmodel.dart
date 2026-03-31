import 'package:flutter/material.dart';
import 'package:academix/core/network/dio_client.dart';
import 'package:academix/core/routes/app_routes.dart';
import 'package:academix/features/library/data/datasources/library_remote_datasource.dart';
import 'package:academix/features/library/presentation/viewmodel/library_viewmodel.dart';

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
      debugPrint('Error loading user ID: $e');
      idUsuario = 1; // fallback
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
      final favorites = await _remoteDataSource.getFavorites(idUsuario!);
      final resources = favorites.map(LibraryResource.fromEntity).toList();
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
