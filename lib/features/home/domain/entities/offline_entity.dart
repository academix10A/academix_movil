class OfflineEntity {
  final int      idRecurso;
  final String   titulo;
  final String   descripcion;
  final String?  urlArchivo;
  final String?  rutaLocal;
  final String?  contenido;
  final int?     idTipo;
  final int?     idSubtema;
  final String?  externalId;
  final DateTime fechaDescarga;

  const OfflineEntity({
    required this.idRecurso,
    required this.titulo,
    required this.descripcion,
    this.urlArchivo,
    this.rutaLocal,
    this.contenido,
    this.idTipo,
    this.idSubtema,
    this.externalId,
    required this.fechaDescarga,
  });
}