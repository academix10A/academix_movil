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

class TemaResourceEntity {
  final int id;
  final String titulo;
  final String descripcion;
  final String tema;
  final String subtema;

  TemaResourceEntity({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.tema,
    required this.subtema,
  });
}