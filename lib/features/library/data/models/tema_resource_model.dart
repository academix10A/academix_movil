import 'package:academix/features/library/domain/entities/tema_resource_entity.dart';

/// Data model — lives in data/models.
/// Parses the nested temas → subtemas → recursos JSON structure.
class TemaResourceModel {
  final int id;
  final String titulo;
  final String descripcion;
  final String tema;
  final String subtema;
  final String? urlArchivo;
  final int? idTipo;

  const TemaResourceModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.tema,
    required this.subtema,
    this.urlArchivo,
    this.idTipo,
  });

  static List<TemaResourceModel> fromTemasJson(List<dynamic> data) {
    final List<TemaResourceModel> resources = [];

    for (final tema in data) {
      final String temaNombre = tema['nombre'] as String;

      for (final subtema in tema['subtemas'] as List) {
        final String subtemaNombre = subtema['nombre'] as String;

        for (final recurso in subtema['recursos'] as List) {
          resources.add(
            TemaResourceModel(
              id: recurso['id_recurso'] as int,
              titulo: recurso['titulo'] as String? ?? '',
              descripcion: recurso['descripcion'] as String? ?? '',
              tema: temaNombre,
              subtema: subtemaNombre,
              urlArchivo: recurso['url_archivo'] as String?,
              idTipo: recurso['id_tipo'] as int?,
            ),
          );
        }
      }
    }

    return resources;
  }

  TemaResourceEntity toEntity() {
    return TemaResourceEntity(
      id: id,
      titulo: titulo,
      descripcion: descripcion,
      tema: tema,
      subtema: subtema,
      urlArchivo: urlArchivo,
      idTipo: idTipo,
    );
  }
}