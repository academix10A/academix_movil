import 'package:academix/features/library/domain/entities/library_resource_entity.dart';

/// Data model — lives in data/models.
/// Responsible for JSON parsing (fromJson) and mapping to domain entity (toEntity).
class LibraryResourceModel {
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

  const LibraryResourceModel({
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

  factory LibraryResourceModel.fromJson(Map<String, dynamic> json) {
    return LibraryResourceModel(
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

  LibraryResourceEntity toEntity() {
    return LibraryResourceEntity(
      idRecurso: idRecurso,
      titulo: titulo,
      descripcion: descripcion,
      contenido: contenido,
      urlArchivo: urlArchivo,
      fechaPublicacion: fechaPublicacion,
      idTipo: idTipo,
      idEstado: idEstado,
      idSubtema: idSubtema,
      nombreTipo: nombreTipo,
      nombreSubtema: nombreSubtema,
    );
  }
}