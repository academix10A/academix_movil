import 'package:academix/features/library/domain/entities/publication_entity.dart';

class PublicationModel {
  final PublicationEntity entity;

  const PublicationModel(this.entity);

  factory PublicationModel.fromJson(Map<String, dynamic> json) {
    final entity = PublicationEntity(
      id: json['id'] ?? 0,
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      texto: json['texto'] ?? '',
      etiquetas: json['etiquetas'] != null
          ? List<String>.from((json['etiquetas'] as List).map((e) => e['nombre']?.toString() ?? ''))
          : null,
      usuarioNombre: json['usuario'] != null
          ? '${json['usuario']['nombre']} ${json['usuario']['apellido_paterno'] ?? ''}'
          : null,
      fechaCreacion: DateTime.parse(json['fecha_creacion'] ?? DateTime.now().toIso8601String()),
      fechaActualizacion: json['fecha_actualizacion'] != null
          ? DateTime.parse(json['fecha_actualizacion'])
          : null,
    );
    return PublicationModel(entity);
  }

  PublicationEntity get publication => entity;
}
