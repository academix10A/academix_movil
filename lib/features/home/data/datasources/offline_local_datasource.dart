// // import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// // import 'package:sqflite/sqflite.dart';
// // import 'package:path/path.dart';

// // class OfflineLocalDataSource {
// //   static Database? _db;

// //   static bool _esUrlCacheable(String? url) {
// //     if (url == null || url.isEmpty) return false;
// //     if (url.contains('drive.google.com')) return false;
// //     if (url.contains('youtube.com')) return false;
// //     if (url.contains('youtu.be')) return false;
// //     return true;
// //   }

// //   static Future<Database> get _database async {
// //     _db ??= await _initDB();
// //     return _db!;
// //   }

// //   static Future<Database> _initDB() async {
// //     final path = join(await getDatabasesPath(), 'academix_offline.db');
// //     return openDatabase(
// //       path,
// //       version: 1,
// //       onCreate: (db, version) async {
// //         await db.execute('''
// //           CREATE TABLE recursos (
// //             id_recurso    INTEGER PRIMARY KEY,
// //             titulo        TEXT    NOT NULL,
// //             descripcion   TEXT,
// //             contenido     TEXT,
// //             url_archivo   TEXT,
// //             id_subtema    INTEGER,
// //             external_id   TEXT,
// //             fecha_descarga TEXT   NOT NULL
// //           )
// //         ''');
// //       },
// //     );
// //   }

// //   Future<void> guardarMetadata(Map<String, dynamic> recurso) async {
// //     final db = await _database;
// //     await db.insert(
// //       'recursos',
// //       {
// //         'id_recurso':     recurso['id_recurso'],
// //         'titulo':         recurso['titulo']       ?? '',
// //         'descripcion':    recurso['descripcion']  ?? '',
// //         'contenido':      recurso['contenido'],
// //         'url_archivo':    recurso['url_archivo'],
// //         'id_subtema':     recurso['id_subtema'],
// //         'external_id':    recurso['external_id'],
// //         'fecha_descarga': DateTime.now().toIso8601String(),
// //       },
// //       conflictAlgorithm: ConflictAlgorithm.replace,
// //     );
// //   }

// //   Future<void> eliminarMetadata(int idRecurso) async {
// //     final db = await _database;
// //     await db.delete(
// //       'recursos',
// //       where: 'id_recurso = ?',
// //       whereArgs: [idRecurso],
// //     );
// //   }

// //   Future<Map<String, dynamic>?> obtenerMetadata(int idRecurso) async {
// //     final db = await _database;
// //     final rows = await db.query(
// //       'recursos',
// //       where: 'id_recurso = ?',
// //       whereArgs: [idRecurso],
// //     );
// //     return rows.isEmpty ? null : rows.first;
// //   }

// //   Future<List<Map<String, dynamic>>> listarTodos() async {
// //     final db = await _database;
// //     return db.query('recursos', orderBy: 'fecha_descarga DESC');
// //   }

// //   Future<void> cachearArchivo(String? url) async {
// //     if (!_esUrlCacheable(url)) return;
// //     try {
// //       await DefaultCacheManager().downloadFile(url!);
// //     } catch (_) {}
// //   }

// //   Future<void> eliminarArchivo(String? url) async {
// //     if (url == null) return;
// //     try {
// //       await DefaultCacheManager().removeFile(url);
// //     } catch (_) {}
// //   }

// //   Future<String?> rutaLocalArchivo(String? url) async {
// //     if (url == null) return null;
// //     try {
// //       final info = await DefaultCacheManager().getFileFromCache(url);
// //       return info?.file.path;
// //     } catch (_) {
// //       return null;
// //     }
// //   }
// // }

// import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';

// class OfflineLocalDataSource {
//   static Database? _db;

//   static bool _esUrlCacheable(String? url) {
//     if (url == null || url.isEmpty) return false;
//     if (url.contains('drive.google.com')) return false;
//     if (url.contains('youtube.com'))      return false;
//     if (url.contains('youtu.be'))         return false;
//     return true;
//   }

//   static Future<Database> get _database async {
//     _db ??= await _initDB();
//     return _db!;
//   }

//   static Future<Database> _initDB() async {
//     final path = join(await getDatabasesPath(), 'academix_offline.db');
//     return openDatabase(
//       path,
//       version: 2, // bump version para agregar columnas nuevas
//       onCreate: (db, version) async {
//         await db.execute('''
//           CREATE TABLE recursos (
//             id_recurso     INTEGER PRIMARY KEY,
//             titulo         TEXT    NOT NULL,
//             descripcion    TEXT,
//             contenido      TEXT,
//             url_archivo    TEXT,
//             id_subtema     INTEGER,
//             id_tipo        INTEGER,
//             external_id    TEXT,
//             fecha_descarga TEXT    NOT NULL
//           )
//         ''');
//       },
//       onUpgrade: (db, oldVersion, newVersion) async {
//         if (oldVersion < 2) {
//           // Migración: agrega columnas que faltaban en v1
//           await db.execute('ALTER TABLE recursos ADD COLUMN id_tipo INTEGER');
//           await db.execute('ALTER TABLE recursos ADD COLUMN contenido TEXT');
//         }
//       },
//     );
//   }

//   Future<void> guardarMetadata(Map<String, dynamic> recurso) async {
//     final db = await _database;
//     await db.insert(
//       'recursos',
//       {
//         'id_recurso':     recurso['id_recurso'],
//         'titulo':         recurso['titulo']      ?? '',
//         'descripcion':    recurso['descripcion'] ?? '',
//         'contenido':      recurso['contenido'],
//         'url_archivo':    recurso['url_archivo'],
//         'id_subtema':     recurso['id_subtema'],
//         'id_tipo':        recurso['id_tipo'],
//         'external_id':    recurso['external_id'],
//         'fecha_descarga': DateTime.now().toIso8601String(),
//       },
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }

//   Future<void> eliminarMetadata(int idRecurso) async {
//     final db = await _database;
//     await db.delete(
//       'recursos',
//       where: 'id_recurso = ?',
//       whereArgs: [idRecurso],
//     );
//   }

//   Future<Map<String, dynamic>?> obtenerMetadata(int idRecurso) async {
//     final db = await _database;
//     final rows = await db.query(
//       'recursos',
//       where: 'id_recurso = ?',
//       whereArgs: [idRecurso],
//     );
//     return rows.isEmpty ? null : rows.first;
//   }

//   Future<List<Map<String, dynamic>>> listarTodos() async {
//     final db = await _database;
//     return db.query('recursos', orderBy: 'fecha_descarga DESC');
//   }

//   Future<void> cachearArchivo(String? url) async {
//     if (!_esUrlCacheable(url)) return;
//     try {
//       await DefaultCacheManager().downloadFile(url!);
//     } catch (_) {}
//   }

//   Future<void> eliminarArchivo(String? url) async {
//     if (url == null) return;
//     try {
//       await DefaultCacheManager().removeFile(url);
//     } catch (_) {}
//   }

//   Future<String?> rutaLocalArchivo(String? url) async {
//     if (url == null) return null;
//     try {
//       final info = await DefaultCacheManager().getFileFromCache(url);
//       return info?.file.path;
//     } catch (_) {
//       return null;
//     }
//   }
// }

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class OfflineLocalDataSource {
  static Database? _db;

  static Future<Database> get _database async {
    _db ??= await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'academix_offline.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE recursos (
            id_recurso     INTEGER PRIMARY KEY,
            titulo         TEXT    NOT NULL,
            descripcion    TEXT,
            contenido      TEXT,
            url_archivo    TEXT,
            id_subtema     INTEGER,
            id_tipo        INTEGER,
            external_id    TEXT,
            fecha_descarga TEXT    NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> guardarMetadata(Map<String, dynamic> recurso) async {
    final db = await _database;
    await db.insert(
      'recursos',
      {
        'id_recurso':     recurso['id_recurso'],
        'titulo':         recurso['titulo']      ?? '',
        'descripcion':    recurso['descripcion'] ?? '',
        'contenido':      recurso['contenido'],
        'url_archivo':    recurso['url_archivo'],
        'id_subtema':     recurso['id_subtema'],
        'id_tipo':        recurso['id_tipo'],
        'external_id':    recurso['external_id'],
        'fecha_descarga': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> eliminarMetadata(int idRecurso) async {
    final db = await _database;
    await db.delete('recursos', where: 'id_recurso = ?', whereArgs: [idRecurso]);
  }

  Future<Map<String, dynamic>?> obtenerMetadata(int idRecurso) async {
    final db = await _database;
    final rows = await db.query(
      'recursos',
      where: 'id_recurso = ?',
      whereArgs: [idRecurso],
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<List<Map<String, dynamic>>> listarTodos() async {
    final db = await _database;
    return db.query('recursos', orderBy: 'fecha_descarga DESC');
  }
}