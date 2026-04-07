import 'package:flutter/material.dart';
import '../../domain/usecases/get_home_data_usecase.dart';
import '../../domain/entities/home_entity.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../data/datasources/home_remote_datasource.dart';
import 'package:academix/core/routes/app_routes.dart';
import 'package:academix/features/library/data/models/library_resource_ui_model.dart';

class HomeViewModel {

  final TextEditingController searchController = TextEditingController();

  final ValueNotifier<String> userName = ValueNotifier('');
  final ValueNotifier<Map<String, dynamic>> examProgress = ValueNotifier({});
  final ValueNotifier<List<RecentItemEntity>> recentItems =
      ValueNotifier([]);
  final ValueNotifier<List<Map<String, dynamic>>> readResources =
      ValueNotifier([]);

  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier(null);

  late final GetHomeDataUseCase _getHomeDataUseCase;

  HomeViewModel() {
    final remote = HomeRemoteDataSource();
    final repository = HomeRepositoryImpl(remote);
    _getHomeDataUseCase = GetHomeDataUseCase(repository);
  }

  Future<void> loadHomeData() async {
    isLoading.value = true;

    try {
      final data = await _getHomeDataUseCase();

      userName.value = data.userName;
      examProgress.value = data.examProgress;
      recentItems.value = data.recentItems;
      readResources.value = data.readResources;

    } catch (e) {
      errorMessage.value = 'Error al cargar datos';
    } finally {
      isLoading.value = false;
    }
  }

  void onRecentItemTap(BuildContext context, RecentItemEntity item) {
    final resource = LibraryResource(
      id: item.id.toString(),
      title: item.title,
      category: item.category,
      description: item.subtitle,
      durationMinutes: 0,
      pages: 0,
    );

    AppNavigator.push(
      context,
      AppRoutes.bookDetail,
      arguments: resource,
    );
  }

  void onReadResourceTap(BuildContext context, Map<String, dynamic> item) {
    final resource = LibraryResource(
      id: item['id_recurso'].toString(),
      title: item['titulo'] ?? '',
      category: item['categoria'] ?? '',
      description: item['descripcion'] ?? '',
      durationMinutes: 0,
      pages: 0,
    );

    AppNavigator.push(
      context,
      AppRoutes.bookDetail,
      arguments: resource,
    );
  }

  void dispose() {
    searchController.dispose();
    userName.dispose();
    examProgress.dispose();
    recentItems.dispose();
    readResources.dispose();
    isLoading.dispose();
    errorMessage.dispose();
  }
}