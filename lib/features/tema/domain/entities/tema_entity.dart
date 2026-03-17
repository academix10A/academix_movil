class TemaEntity {
  final String id;
  final String title;
  final String description;
  final List<String> subtemas;

  const TemaEntity({
    required this.id,
    required this.title,
    required this.description,
    this.subtemas = const [],
  });
}

class SubtemaEntity {
  final String id;
  final String title;
  final String temaId;

  const SubtemaEntity({
    required this.id,
    required this.title,
    required this.temaId,
  });
}

