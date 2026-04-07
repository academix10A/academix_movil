import '../../../library/domain/entities/library_resource_entity.dart';
import '../../../library/data/models/library_resource_model.dart';

class NoteEntity {
  final int idNota;
  final String titulo;
  final String contenido;
  final DateTime fechaCreacion;
  final DateTime fechaActualizacion;
  final bool esCompartida;
  final int idUsuario;
  final int? idRecurso;
  final LibraryResourceEntity? recurso;

  NoteEntity({
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

  factory NoteEntity.fromJson(Map<String, dynamic> json) {
    return NoteEntity(
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
        ? LibraryResourceModel.fromJson(json['recurso']).toEntity()
        : null,
    );
  }

  // Mapper para compatibilidad con la UI existente
  String get title {
    final lines = titulo;
    return lines.isNotEmpty ? lines : 'Nota sin título';
  }

  String get preview {
    final lines = contenido.split('\n');
    if (lines.length > 1) {
      return lines.sublist(1).join('\n').trim();
    }
    return contenido.length > 50 ? '${contenido.substring(0, 50)}...' : contenido;
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(fechaCreacion);

    if (difference.inDays > 30) {
      return 'Hace más de un mes';
    } else if (difference.inDays > 0) {
      return 'Hace ${difference.inDays} días';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours} horas';
    } else if (difference.inMinutes > 0) {
      return 'Hace ${difference.inMinutes} minutos';
    } else {
      return 'Hace un momento';
    }
  }

  List<String> get tags {
    // Extraer etiquetas del contenido si existen
    return [];
  }

  bool get isShared => esCompartida;
  
  bool get hasResource => recurso != null;
}

