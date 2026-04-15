import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:academix/core/utils/env.dart';
import 'package:academix/features/home/data/utils/offline_crypto.dart';

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
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE recursos (
            id_recurso     INTEGER PRIMARY KEY,
            titulo         TEXT    NOT NULL,
            descripcion    TEXT,
            contenido      TEXT,
            url_archivo    TEXT,
            ruta_local     TEXT,
            id_subtema     INTEGER,
            id_tipo        INTEGER,
            external_id    TEXT,
            fecha_descarga TEXT    NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE recursos ADD COLUMN ruta_local TEXT',
          );
        }
      },
    );
  }

  // ── Descarga el PDF a través del proxy, lo encripta y lo guarda ───────────
  Future<String?> _descargarYEncriptar(
      int idRecurso, String urlArchivo) async {
    try {
      final backendBase = _backendRoot(Env.apiUrl);
      final proxiedUrl =
          '$backendBase/api/proxy/pdf?url=${Uri.encodeComponent(urlArchivo)}';

      final response = await http
          .get(Uri.parse(proxiedUrl))
          .timeout(const Duration(seconds: 60));

      if (response.statusCode != 200) return null;

      final encrypted = OfflineCrypto.encrypt(
        idRecurso,
        Uint8List.fromList(response.bodyBytes),
      );

      final dir  = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/offline_$idRecurso.bin');
      await file.writeAsBytes(encrypted);
      return file.path;
    } catch (_) {
      return null;
    }
  }

  String _backendRoot(String apiBase) {
    final clean = apiBase.replaceAll(RegExp(r'/+$'), '');
    return clean.endsWith('/api')
        ? clean.substring(0, clean.length - 4)
        : clean;
  }

  // ── Lee el .bin y devuelve los bytes del PDF original ─────────────────────
  Future<Uint8List?> leerPdfLocal(int idRecurso, String rutaLocal) async {
    try {
      final file = File(rutaLocal);
      if (!await file.exists()) return null;
      final binBytes = await file.readAsBytes();
      return OfflineCrypto.decrypt(idRecurso, binBytes);
    } catch (_) {
      return null;
    }
  }

  // ── Guardar metadata + archivo encriptado ─────────────────────────────────
  Future<void> guardarMetadata(Map<String, dynamic> recurso) async {
    final db         = await _database;
    final idRecurso  = recurso['id_recurso'] as int;
    final urlArchivo = recurso['url_archivo'] as String?;
    final idTipo     = recurso['id_tipo']     as int?;

    String? rutaLocal;
    final esPdf = idTipo == 1 ||
        (urlArchivo != null &&
            (urlArchivo.toLowerCase().endsWith('.pdf') ||
             urlArchivo.contains('drive.google.com') ||
             urlArchivo.contains('docs.google.com') ||
             urlArchivo.contains('documentos/')));

    if (esPdf && urlArchivo != null && urlArchivo.isNotEmpty) {
      rutaLocal = await _descargarYEncriptar(idRecurso, urlArchivo);
    }

    await db.insert(
      'recursos',
      {
        'id_recurso':     idRecurso,
        'titulo':         recurso['titulo']      ?? '',
        'descripcion':    recurso['descripcion'] ?? '',
        'contenido':      recurso['contenido'],
        'url_archivo':    urlArchivo,
        'ruta_local':     rutaLocal,
        'id_subtema':     recurso['id_subtema'],
        'id_tipo':        idTipo,
        'external_id':    recurso['external_id'],
        'fecha_descarga': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ── Eliminar metadata + archivo físico ────────────────────────────────────
  Future<void> eliminarMetadata(int idRecurso) async {
    final db = await _database;

    final rows = await db.query(
      'recursos',
      columns:   ['ruta_local'],
      where:     'id_recurso = ?',
      whereArgs: [idRecurso],
    );

    if (rows.isNotEmpty) {
      final ruta = rows.first['ruta_local'] as String?;
      if (ruta != null) {
        final file = File(ruta);
        if (await file.exists()) await file.delete();
      }
    }

    await db.delete(
      'recursos',
      where:     'id_recurso = ?',
      whereArgs: [idRecurso],
    );
  }

  Future<Map<String, dynamic>?> obtenerMetadata(int idRecurso) async {
    final db = await _database;
    final rows = await db.query(
      'recursos',
      where:     'id_recurso = ?',
      whereArgs: [idRecurso],
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<List<Map<String, dynamic>>> listarTodos() async {
    final db = await _database;
    return db.query('recursos', orderBy: 'fecha_descarga DESC');
  }
}