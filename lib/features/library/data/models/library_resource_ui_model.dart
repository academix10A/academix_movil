// import 'package:academix/features/library/domain/entities/library_resource_entity.dart';
// import 'package:academix/features/library/domain/entities/tema_resource_entity.dart';

// /// UI model — lives in data/models (or presentation/viewmodel).
// /// Adapts domain entities to what the Views need.
// /// Contains NO JSON parsing — that belongs to LibraryResourceModel.
// class LibraryResource {
//   final String id;
//   final String title;
//   final String category;
//   final String description;
//   final int durationMinutes;
//   final int pages;
//   final bool isFavorite;
//   final String? urlArchivo;
//   final int? idTipo;

//   const LibraryResource({
//     required this.id,
//     required this.title,
//     required this.category,
//     required this.description,
//     required this.durationMinutes,
//     required this.pages,
//     this.isFavorite = false,
//     this.urlArchivo,
//     this.idTipo,
//   });

//   factory LibraryResource.fromEntity(LibraryResourceEntity entity) {
//     return LibraryResource(
//       id: entity.idRecurso.toString(),
//       title: entity.titulo,
//       category: entity.nombreSubtema ?? 'General',
//       description: entity.descripcion ?? '',
//       durationMinutes: _estimateDuration(entity.contenido),
//       pages: _estimatePages(entity.contenido),
//       isFavorite: false,
//       urlArchivo: entity.urlArchivo,
//       idTipo: entity.idTipo,
//     );
//   }

//   factory LibraryResource.fromTemaEntity(TemaResourceEntity entity) {
//     return LibraryResource(
//       id: entity.id.toString(),
//       title: entity.titulo,
//       category: entity.tema,
//       description: entity.descripcion,
//       durationMinutes: 30,
//       pages: 10,
//       isFavorite: false,
//       urlArchivo: entity.urlArchivo,
//       idTipo: entity.idTipo,
//     );
//   }

//   LibraryResource copyWith({
//     String? id,
//     String? title,
//     String? category,
//     String? description,
//     int? durationMinutes,
//     int? pages,
//     bool? isFavorite,
//     String? urlArchivo,
//     int? idTipo,
//   }) {
//     return LibraryResource(
//       id: id ?? this.id,
//       title: title ?? this.title,
//       category: category ?? this.category,
//       description: description ?? this.description,
//       durationMinutes: durationMinutes ?? this.durationMinutes,
//       pages: pages ?? this.pages,
//       isFavorite: isFavorite ?? this.isFavorite,
//       urlArchivo: urlArchivo ?? this.urlArchivo,
//       idTipo: idTipo ?? this.idTipo,
//     );
//   }

//   static int _estimateDuration(String? contenido) {
//     if (contenido != null) return (contenido.length / 500).ceil();
//     return 30;
//   }

//   static int _estimatePages(String? contenido) {
//     if (contenido != null) return (contenido.length / 1000).ceil();
//     return 10;
//   }
// }

import 'package:academix/features/library/domain/entities/library_resource_entity.dart';
import 'package:academix/features/library/domain/entities/tema_resource_entity.dart';

class LibraryResource {
  final String  id;
  final String  title;
  final String  category;
  final String  description;
  final int     durationMinutes;
  final int     pages;
  final bool    isFavorite;
  final String? urlArchivo;
  final String? contenido;
  final int?    idTipo;

  const LibraryResource({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.durationMinutes,
    required this.pages,
    this.isFavorite = false,
    this.urlArchivo,
    this.contenido,
    this.idTipo,
  });

  factory LibraryResource.fromEntity(LibraryResourceEntity entity) {
    return LibraryResource(
      id:              entity.idRecurso.toString(),
      title:           entity.titulo,
      category:        entity.nombreSubtema ?? 'General',
      description:     entity.descripcion   ?? '',
      durationMinutes: _estimateDuration(entity.contenido),
      pages:           _estimatePages(entity.contenido),
      isFavorite:      false,
      urlArchivo:      entity.urlArchivo,
      contenido:       entity.contenido,
      idTipo:          entity.idTipo,
    );
  }

  factory LibraryResource.fromTemaEntity(TemaResourceEntity entity) {
    return LibraryResource(
      id:              entity.id.toString(),
      title:           entity.titulo,
      category:        entity.tema,
      description:     entity.descripcion,
      durationMinutes: 30,
      pages:           10,
      isFavorite:      false,
      urlArchivo:      entity.urlArchivo,
      contenido:       null,
      idTipo:          entity.idTipo,
    );
  }

  LibraryResource copyWith({
    String?  id,
    String?  title,
    String?  category,
    String?  description,
    int?     durationMinutes,
    int?     pages,
    bool?    isFavorite,
    String?  urlArchivo,
    String?  contenido,
    int?     idTipo,
  }) {
    return LibraryResource(
      id:              id              ?? this.id,
      title:           title           ?? this.title,
      category:        category        ?? this.category,
      description:     description     ?? this.description,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      pages:           pages           ?? this.pages,
      isFavorite:      isFavorite      ?? this.isFavorite,
      urlArchivo:      urlArchivo      ?? this.urlArchivo,
      contenido:       contenido       ?? this.contenido,
      idTipo:          idTipo          ?? this.idTipo,
    );
  }

  static int _estimateDuration(String? contenido) {
    if (contenido != null) return (contenido.length / 500).ceil();
    return 30;
  }

  static int _estimatePages(String? contenido) {
    if (contenido != null) return (contenido.length / 1000).ceil();
    return 10;
  }
}