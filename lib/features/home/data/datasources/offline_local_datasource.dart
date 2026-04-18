import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:academix/core/utils/env.dart';
import 'package:academix/features/home/data/utils/offline_crypto.dart';
import 'package:academix/features/library/presentation/viewmodel/url_detector.dart';

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

  // ── Determina si el recurso es un PDF descargable ─────────────────────────
  // UrlDetector es la única fuente de verdad, igual que en el resto de la app.
  static bool _esPdfDescargable(Map<String, dynamic> recurso) {
    final idTipo = recurso['id_tipo'] as int?;
    if (idTipo == 1) return true; // siempre PDF sin importar la URL

    final tipo = UrlDetector.detect(recurso['url_archivo'] as String?);
    return tipo == UrlType.pdf || tipo == UrlType.drive;
  }

  // ── Descarga el PDF a través del proxy, lo encripta y lo guarda ───────────
  // Lanza [OfflineDescargaException] con mensaje amigable si algo falla.
  Future<String> _descargarYEncriptar(
      int idRecurso, String urlArchivo) async {
    final backendBase = _backendRoot(Env.apiUrl);
    final proxiedUrl =
        '$backendBase/api/proxy/pdf?url=${Uri.encodeComponent(urlArchivo)}';

    final http.Response response;
    try {
      response = await http
          .get(Uri.parse(proxiedUrl))
          .timeout(const Duration(seconds: 60));
    } catch (_) {
      throw const OfflineDescargaException(
        'No se pudo conectar al servidor. Verifica tu conexión.',
      );
    }

    if (response.statusCode != 200) {
      throw OfflineDescargaException(
        'El servidor respondió con error ${response.statusCode} '
        'al descargar el PDF.',
      );
    }

    // Verificar firma %PDF para detectar páginas de error disfrazadas
    final bytes = Uint8List.fromList(response.bodyBytes);
    if (bytes.length < 4 ||
        bytes[0] != 0x25 || // %
        bytes[1] != 0x50 || // P
        bytes[2] != 0x44 || // D
        bytes[3] != 0x46) { // F
      throw const OfflineDescargaException(
        'El archivo descargado no es un PDF válido. '
        'Puede que requiera autenticación adicional.',
      );
    }

    final encrypted = OfflineCrypto.encrypt(idRecurso, bytes);
    final dir  = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/offline_$idRecurso.bin');
    await file.writeAsBytes(encrypted);
    return file.path;
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
  // Retorna [GuardarResultado] para que el caller pueda mostrar errores al usuario.
  Future<GuardarResultado> guardarMetadata(
      Map<String, dynamic> recurso) async {
    final db         = await _database;
    final idRecurso  = recurso['id_recurso']  as int;
    final urlArchivo = recurso['url_archivo'] as String?;

    String? rutaLocal;
    String? errorDescarga;

    if (_esPdfDescargable(recurso) &&
        urlArchivo != null &&
        urlArchivo.isNotEmpty) {
      try {
        rutaLocal = await _descargarYEncriptar(idRecurso, urlArchivo);
      } on OfflineDescargaException catch (e) {
        errorDescarga = e.message;
      } catch (_) {
        errorDescarga = 'Error inesperado al descargar el PDF.';
      }
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
        'id_tipo':        recurso['id_tipo'],
        'external_id':    recurso['external_id'],
        'fecha_descarga': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return GuardarResultado(rutaLocal: rutaLocal, errorDescarga: errorDescarga);
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

// ── Tipos auxiliares ──────────────────────────────────────────────────────────

class GuardarResultado {
  /// Ruta del .bin encriptado. Null si no era PDF o si falló la descarga.
  final String? rutaLocal;

  /// Mensaje de error si la descarga del PDF falló. Null si fue exitosa o no aplica.
  final String? errorDescarga;

  const GuardarResultado({this.rutaLocal, this.errorDescarga});

  bool get pdfDescargado => rutaLocal != null;
  bool get pdfFallo      => errorDescarga != null;
}

class OfflineDescargaException implements Exception {
  final String message;
  const OfflineDescargaException(this.message);
}