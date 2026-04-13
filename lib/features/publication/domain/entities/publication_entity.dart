class PublicationEntity {
  final int id;
  final String titulo;
  final String descripcion;
  final String texto;
  final List<String>? etiquetas;
  final String? usuarioNombre;
  final DateTime fechaCreacion;
  final DateTime? fechaActualizacion;

  const PublicationEntity({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.texto,
    this.etiquetas,
    this.usuarioNombre,
    required this.fechaCreacion,
    this.fechaActualizacion,
  });
}
