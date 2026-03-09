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

  LibraryResourceEntity({
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

  factory LibraryResourceEntity.fromJson(Map<String, dynamic> json) {
    return LibraryResourceEntity(
      idRecurso: json['id_recurso'] ?? 0,
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'],
      contenido: json['contenido'],
      urlArchivo: json['url_archivo'],
      fechaPublicacion: json['fecha_publicacion'] != null
          ? DateTime.parse(json['fecha_publicacion'])
          : DateTime.now(),
      idTipo: json['id_tipo'] ?? 2,
      idEstado: json['id_estado'] ?? 1,
      idSubtema: json['id_subtema'] ?? 1,
      nombreTipo: json['nombre_tipo'],
      nombreSubtema: json['nombre_subtema'],
    );
  }

  // Mapper para compatibilidad con la UI existente
  String get category => nombreSubtema ?? 'General';
  
  int get durationMinutes {
    // Estimación basada en la longitud del contenido
    if (contenido != null) {
      return (contenido!.length / 500).ceil();
    }
    return 30;
  }
  
  int get pages {
    // Estimación de páginas
    if (contenido != null) {
      return (contenido!.length / 1000).ceil();
    }
    return 10;
  }
}

