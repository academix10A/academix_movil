import '../entities/home_entity.dart';

abstract class HomeRepository {
  Future<String> getUserName();
  Future<Map<String, dynamic>> getExamProgress();
  Future<List<RecentItemEntity>> getRecentItems();
  Future<List<Map<String, dynamic>>> getReadResources();
}
