class UserProfileEntity {
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

  UserProfileEntity({
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

  factory UserProfileEntity.fromJson(Map<String, dynamic> json) {
    return UserProfileEntity(
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

  /// Full name combining nombre, apellido_paterno and apellido_materno
  String get fullName => '$nombre $apellidoPaterno $apellidoMaterno'.trim();

  /// Get initials from full name
  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts.isNotEmpty ? parts[0].substring(0, 2).toUpperCase() : 'U';
  }

  // Mapper para compatibilidad con la UI existente
  String get userName => nombre;

  String get apellidoPaternoName => apellidoPaterno;

  String get apellidoMaternoName => apellidoMaterno;

  String get userEmail => email;

  String get avatarUrl => fotoPerfil ?? '';

  bool get isActive => estaActivo;

  String get roleName => nombreRol ?? (rol == 1 ? 'Estudiante' : 'Usuario');

  bool get isPremium => idMembresia != null && idMembresia != 1; // 1 = Freemium

  String get memberSince {
    final now = DateTime.now();
    final difference = now.difference(fechaRegistro);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return 'Miembro desde hace $years ${years == 1 ? 'año' : 'años'}';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return 'Miembro desde hace $months ${months == 1 ? 'mes' : 'meses'}';
    } else if (difference.inDays > 0) {
      return 'Miembro desde hace ${difference.inDays} ${difference.inDays == 1 ? 'día' : 'días'}';
    } else {
      return 'Miembro desde hoy';
    }
  }

  String get lastAccess {
    if (ultimoAcceso == null) return 'Nunca';
    final now = DateTime.now();
    final difference = now.difference(ultimoAcceso!);

    if (difference.inDays > 30) {
      return 'Hace más de un mes';
    } else if (difference.inDays > 0) {
      return 'Hace ${difference.inDays} días';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours} horas';
    } else if (difference.inMinutes > 0) {
      return 'Hace ${difference.inMinutes} minutos';
    } else {
      return 'En este momento';
    }
  }
}

/// Entity for user statistics from /home/usuario/progreso-examenes
class UserStatsEntity {
  final int totalExamenesRealizados;
  final int examenesCompletados;
  final double promedioCalificacion;

  UserStatsEntity({
    required this.totalExamenesRealizados,
    required this.examenesCompletados,
    required this.promedioCalificacion,
  });

  factory UserStatsEntity.fromJson(Map<String, dynamic> json) {
    return UserStatsEntity(
      totalExamenesRealizados: json['total_examenes_realizados'] ?? 0,
      examenesCompletados: json['examenes_completados'] ?? 0,
      promedioCalificacion: (json['promedio_calificacion'] ?? 0).toDouble(),
    );
  }
}

