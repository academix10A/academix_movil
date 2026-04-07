/// Pure domain entity. No fromJson, no UI getters.
/// JSON parsing belongs to LibraryResourceModel in data/models.
class LibraryResourceEntity {
  final int idRecurso;
  final String titulo;
  final String? descripcion;
  final String? contenido;
  final String? urlArchivo;
  final DateTime fechaPublicacion;
  final int idTipo;
  final int idEstado;
  final int idSubtema;
  final String? nombreTipo;
  final String? nombreSubtema;

  const LibraryResourceEntity({
    required this.idRecurso,
    required this.titulo,
    this.descripcion,
    this.contenido,
    this.urlArchivo,
    required this.fechaPublicacion,
    required this.idTipo,
    required this.idEstado,
    required this.idSubtema,
    this.nombreTipo,
    this.nombreSubtema,
  });
}