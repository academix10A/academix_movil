import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as enc;

/// Encripta y desencripta los PDFs guardados offline.
/// El archivo en disco es un .bin inútil fuera de la app.
class OfflineCrypto {
  // Cámbialo por uno tuyo de exactamente 32 caracteres antes de producción.
  static const _appSecret = 'AcademixOffline2024SecretKey!!!!';

  static enc.Key _key(int idRecurso) {
    final raw = '$_appSecret:$idRecurso'.padRight(32).substring(0, 32);
    return enc.Key.fromUtf8(raw);
  }

  /// Recibe los bytes crudos del PDF y devuelve los bytes encriptados
  /// listos para guardar en disco (IV de 16 bytes + cifrado).
  static Uint8List encrypt(int idRecurso, Uint8List pdfBytes) {
    final key       = _key(idRecurso);
    final iv        = enc.IV.fromSecureRandom(16);
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    final encrypted = encrypter.encryptBytes(pdfBytes, iv: iv);
    return Uint8List.fromList([...iv.bytes, ...encrypted.bytes]);
  }

  /// Recibe los bytes del .bin guardado en disco y devuelve los bytes
  /// originales del PDF listos para mostrarse en PDF.js.
  static Uint8List decrypt(int idRecurso, Uint8List binBytes) {
    final key       = _key(idRecurso);
    final iv        = enc.IV(Uint8List.fromList(binBytes.sublist(0, 16)));
    final datos     = enc.Encrypted(Uint8List.fromList(binBytes.sublist(16)));
    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));
    return Uint8List.fromList(encrypter.decryptBytes(datos, iv: iv));
  }
}