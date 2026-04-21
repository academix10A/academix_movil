import '../../domain/entities/publication_entity.dart';

class PublicationModel {
  final PublicationEntity entity;

  const PublicationModel({
    required this.entity,
  });

  factory PublicationModel.fromJson(Map<String, dynamic> json) {
    return PublicationModel(
      entity: PublicationEntity(
        id: json['id_publicacion'] ?? 0,

        titulo: json['titulo'] ?? '',
        descripcion: json['descripcion'] ?? '',
        texto: json['texto'] ?? '',

        // El backend devuelve etiquetas como lista de objetos {id_etiqueta, nombre}
        // Extraemos solo el nombre (string) para la entidad
        etiquetas: json['etiquetas'] != null
            ? (json['etiquetas'] as List)
                .map((e) => e['nombre'] as String)
                .toList()
            : null,

        usuarioNombre: json['usuario'] != null
            ? "${json['usuario']['nombre']} ${json['usuario']['apellido_paterno']}"
            : '',

        fechaCreacion: json['fecha_creacion'] != null
            ? DateTime.parse(json['fecha_creacion'])
            : DateTime.now(),

        fechaActualizacion: json['fecha_actualizacion'] != null
            ? DateTime.parse(json['fecha_actualizacion'])
            : null,
      ),
    );
  }

  /// Serializa la entidad para enviarla al backend.
  /// - etiquetas: lista de strings (nombres). El backend las crea si no existen.
  /// - id_estado: no se envía; el backend asigna el estado 4 por defecto.
  /// - descripcion: puede ser vacía, el backend acepta string vacío.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'titulo': entity.titulo,
      'descripcion': entity.descripcion,
      'texto': entity.texto,
    };

    // Solo incluir etiquetas si hay al menos una
    if (entity.etiquetas != null && entity.etiquetas!.isNotEmpty) {
      map['etiquetas'] = entity.etiquetas;
    } else {
      map['etiquetas'] = <String>[];
    }

    return map;
  }
}