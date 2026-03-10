import '../repositories/home_repository.dart';
import '../entities/home_entity.dart';

class GetHomeDataUseCase {
  final HomeRepository repository;

  GetHomeDataUseCase(this.repository);

  Future<HomeData> call() async {
    final name = await repository.getUserName();
    final examProgress = await repository.getExamProgress();
    final recent = await repository.getRecentItems();
    final readResources = await repository.getReadResources();

    return HomeData(
      userName: name,
      examProgress: examProgress,
      recentItems: recent,
      readResources: readResources,
    );
  }
}

class HomeData {
  final String userName;
  final Map<String, dynamic> examProgress;
  final List<RecentItemEntity> recentItems;
  final List<Map<String, dynamic>> readResources;

  HomeData({
    required this.userName,
    required this.examProgress,
    required this.recentItems,
    required this.readResources,
  });
}
