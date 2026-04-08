import '../../domain/entities/note_entity.dart';
import '../../../library/data/models/library_resource_model.dart';

class NoteModel {
  final int idNota;
  final String titulo;
  final String contenido;
  final DateTime fechaCreacion;
  final DateTime fechaActualizacion;
  final bool esCompartida;
  final int idUsuario;
  final int? idRecurso;
  final LibraryResourceModel? recurso;

  NoteModel({
    required this.idNota,
    required this.titulo,
    required this.contenido,
    required this.fechaCreacion,
    required this.fechaActualizacion,
    required this.esCompartida,
    required this.idUsuario,
    this.idRecurso,
    this.recurso,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      idNota: json['id_nota'] ?? 0,
      titulo: json['titulo'] ?? '',
      contenido: json['contenido'] ?? '',
      fechaCreacion: json['fecha_creacion'] != null
          ? DateTime.parse(json['fecha_creacion'])
          : DateTime.now(),
      fechaActualizacion: json['fecha_actualizacion'] != null
          ? DateTime.parse(json['fecha_actualizacion'])
          : DateTime.now(),
      esCompartida: json['es_compartida'] ?? false,
      idUsuario: json['id_usuario'] ?? 0,
      idRecurso: json['id_recurso'],
      recurso: json['recurso'] != null
          ? LibraryResourceModel.fromJson(json['recurso'])
          : null,
    );
  }

  NoteEntity toEntity() {
    return NoteEntity(
      idNota: idNota,
      titulo: titulo,
      contenido: contenido,
      fechaCreacion: fechaCreacion,
      fechaActualizacion: fechaActualizacion,
      esCompartida: esCompartida,
      idUsuario: idUsuario,
      idRecurso: idRecurso,
      recurso: recurso?.toEntity(),
    );
  }
}