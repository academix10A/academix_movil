import '../../domain/repositories/home_repository.dart';
import '../../domain/entities/home_entity.dart';
import '../datasources/home_remote_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {

  final HomeRemoteDataSource remote;

  HomeRepositoryImpl(this.remote);

  @override
  Future<String> getUserName() {
    return remote.getUserName();
  }

  @override
  Future<Map<String, dynamic>> getExamProgress() {
    return remote.getExamProgress();
  }

  @override
  Future<List<RecentItemEntity>> getRecentItems() {
    return remote.getRecentItems();
  }
  
  @override
  Future<List<Map<String, dynamic>>> getReadResources() {
    return remote.getReadResources();
  }
}
