class CourseProgressEntity {
  final String courseName;
  final int progress;

  CourseProgressEntity({
    required this.courseName,
    required this.progress,
  });
}

class RecentItemEntity {
  final int id;
  final String title;
  final String subtitle;
  final String category;

  RecentItemEntity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
  });
}