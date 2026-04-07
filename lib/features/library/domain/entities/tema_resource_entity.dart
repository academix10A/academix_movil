class TemaResourceEntity {
  final int id;
  final String titulo;
  final String descripcion;
  final String tema;
  final String subtema;
  final String? urlArchivo;
  final int? idTipo;

  const TemaResourceEntity({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.tema,
    required this.subtema,
    this.urlArchivo,
    this.idTipo,
  });
}