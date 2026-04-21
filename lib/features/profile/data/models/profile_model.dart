import '../../domain/entities/profile_entity.dart';

/// Model vive en la capa data y se encarga de:
/// 1. Deserializar JSON → Model (fromJson)
/// 2. Convertir Model → Entity (toEntity) para exponer a domain/presentation
///
/// Las Entities de domain son puras (sin fromJson) — el parsing
/// siempre ocurre aquí, en data/models.

class UserProfileModel {
  final int idUsuario;
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String email;
  final String? fotoPerfil;
  final DateTime fechaRegistro;
  final DateTime? ultimoAcceso;
  final int rol;
  final bool estaActivo;
  final String? nombreRol;
  final int? idMembresia;

  UserProfileModel({
    required this.idUsuario,
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.email,
    this.fotoPerfil,
    required this.fechaRegistro,
    this.ultimoAcceso,
    required this.rol,
    required this.estaActivo,
    this.nombreRol,
    this.idMembresia,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      idUsuario: json['id_usuario'] ?? 0,
      nombre: json['nombre'] ?? '',
      apellidoPaterno: json['apellido_paterno'] ?? '',
      apellidoMaterno: json['apellido_materno'] ?? '',
      email: json['correo'] ?? json['email'] ?? '',
      fotoPerfil: json['foto_perfil'],
      fechaRegistro: json['fecha_registro'] != null
          ? DateTime.parse(json['fecha_registro'])
          : DateTime.now(),
      ultimoAcceso: json['ultimo_acceso'] != null
          ? DateTime.parse(json['ultimo_acceso'])
          : null,
      rol: json['rol'] ?? 1,
      estaActivo: json['esta_activo'] ?? true,
      nombreRol: json['nombre_rol'],
      idMembresia: json['id_membresia'],
    );
  }

  UserProfileEntity toEntity() {
    return UserProfileEntity(
      idUsuario: idUsuario,
      nombre: nombre,
      apellidoPaterno: apellidoPaterno,
      apellidoMaterno: apellidoMaterno,
      email: email,
      fotoPerfil: fotoPerfil,
      fechaRegistro: fechaRegistro,
      ultimoAcceso: ultimoAcceso,
      rol: rol,
      estaActivo: estaActivo,
      nombreRol: nombreRol,
      idMembresia: idMembresia,
    );
  }
}

class UserStatsModel {
  final int totalExamenesRealizados;
  final int examenesCompletados;
  final double promedioCalificacion;

  UserStatsModel({
    required this.totalExamenesRealizados,
    required this.examenesCompletados,
    required this.promedioCalificacion,
  });

  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    return UserStatsModel(
      totalExamenesRealizados: json['total_examenes_realizados'] ?? 0,
      examenesCompletados: json['examenes_completados'] ?? 0,
      promedioCalificacion:
          (json['promedio_calificacion'] ?? 0).toDouble(),
    );
  }

  UserStatsEntity toEntity() {
    return UserStatsEntity(
      totalExamenesRealizados: totalExamenesRealizados,
      examenesCompletados: examenesCompletados,
      promedioCalificacion: promedioCalificacion,
    );
  }
}