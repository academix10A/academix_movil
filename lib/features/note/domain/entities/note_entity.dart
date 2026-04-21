import '../../../library/domain/entities/library_resource_entity.dart';

/// Entidad pura de dominio.
/// NO contiene fromJson ni imports de data/.
/// El mapeo JSON vive en NoteModel (capa data).
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

  const NoteEntity({
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

  // ── Computed getters de presentación ──────────────────────────────────────
  // Estos getters son lógica de dominio (formateo de datos propios de la entidad)
  // y es aceptable mantenerlos aquí.

  String get title => titulo.isNotEmpty ? titulo : 'Nota sin título';

  String get preview {
    final lines = contenido.split('\n');
    if (lines.length > 1) {
      return lines.sublist(1).join('\n').trim();
    }
    return contenido.length > 50
        ? '${contenido.substring(0, 50)}...'
        : contenido;
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(fechaCreacion);

    if (difference.inDays > 30) return 'Hace más de un mes';
    if (difference.inDays > 0) return 'Hace ${difference.inDays} días';
    if (difference.inHours > 0) return 'Hace ${difference.inHours} horas';
    if (difference.inMinutes > 0) return 'Hace ${difference.inMinutes} minutos';
    return 'Hace un momento';
  }

  List<String> get tags => [];

  bool get isShared => esCompartida;
  bool get hasResource => recurso != null;
}