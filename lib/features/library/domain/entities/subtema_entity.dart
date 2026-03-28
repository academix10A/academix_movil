class SubtemaEntity {
  final String id;
  final String temaId;
  final String title;
  final String description;
  final int resourceCount;
  final int examCount;

  const SubtemaEntity({
    required this.id,
    required this.temaId,
    required this.title,
    required this.description,
    required this.resourceCount,
    required this.examCount,
  });
}
