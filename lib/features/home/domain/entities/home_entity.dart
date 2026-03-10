// lib/features/home/domain/entities/home_entity.dart

class CourseProgressEntity {
  final String courseName;
  final int progress; // 0-100

  CourseProgressEntity({
    required this.courseName,
    required this.progress,
  });
}

class RecentItemEntity {
  final String title;
  final String subtitle;
  final String category;

  RecentItemEntity({
    required this.title,
    required this.subtitle,
    required this.category,
  });
}