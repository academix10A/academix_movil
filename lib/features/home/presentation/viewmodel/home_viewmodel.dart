import 'package:flutter/material.dart';
import '../../domain/usecases/get_home_data_usecase.dart';
import '../../domain/entities/home_entity.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../data/datasources/home_remote_datasource.dart';

class HomeViewModel extends ChangeNotifier {

  final TextEditingController searchController = TextEditingController();

  late final GetHomeDataUseCase _getHomeDataUseCase;

  String userName = '';
  Map<String, dynamic> examProgress = {};
  List<RecentItemEntity> recentItems = [];
  List<Map<String, dynamic>> readResources = [];

  bool isLoading = false;
  String errorMessage = '';

  HomeViewModel() {
    final remote = HomeRemoteDataSource();
    final repository = HomeRepositoryImpl(remote);
    _getHomeDataUseCase = GetHomeDataUseCase(repository);

    loadHomeData();
  }

  Future<void> loadHomeData() async {
    try {
      isLoading = true;
      notifyListeners();

      final data = await _getHomeDataUseCase();

      userName = data.userName;
      examProgress = data.examProgress;
      recentItems = data.recentItems;
      readResources = data.readResources;

    } catch (e) {
      errorMessage = 'Error al cargar datos';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void onSearch(String query) {
    print("Buscando: $query");
  }

  void onRecentItemTap(RecentItemEntity item) {
    print("Item seleccionado: ${item.title}");
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
