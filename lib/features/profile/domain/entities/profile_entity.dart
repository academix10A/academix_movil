/// Entidades puras de dominio.
/// NO tienen fromJson — el parsing JSON ocurre solo en data/models.

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

  String get fullName => '$nombre $apellidoPaterno $apellidoMaterno'.trim();

  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts.isNotEmpty ? parts[0].substring(0, 2).toUpperCase() : 'U';
  }

  String get email_ => email;
  String get avatarUrl => fotoPerfil ?? '';
  bool get isActive => estaActivo;
  String get roleName => nombreRol ?? (rol == 1 ? 'Estudiante' : 'Usuario');
  bool get isPremium => idMembresia != null && idMembresia != 1;

  String get memberSince {
    final difference = DateTime.now().difference(fechaRegistro);
    if (difference.inDays > 365) {
      final y = (difference.inDays / 365).floor();
      return 'Miembro desde hace $y ${y == 1 ? 'año' : 'años'}';
    } else if (difference.inDays > 30) {
      final m = (difference.inDays / 30).floor();
      return 'Miembro desde hace $m ${m == 1 ? 'mes' : 'meses'}';
    } else if (difference.inDays > 0) {
      return 'Miembro desde hace ${difference.inDays} ${difference.inDays == 1 ? 'día' : 'días'}';
    }
    return 'Miembro desde hoy';
  }

  String get lastAccess {
    if (ultimoAcceso == null) return 'Nunca';
    final difference = DateTime.now().difference(ultimoAcceso!);
    if (difference.inDays > 30) return 'Hace más de un mes';
    if (difference.inDays > 0) return 'Hace ${difference.inDays} días';
    if (difference.inHours > 0) return 'Hace ${difference.inHours} horas';
    if (difference.inMinutes > 0) return 'Hace ${difference.inMinutes} minutos';
    return 'En este momento';
  }
}

class UserStatsEntity {
  final int totalExamenesRealizados;
  final int examenesCompletados;
  final double promedioCalificacion;

  UserStatsEntity({
    required this.totalExamenesRealizados,
    required this.examenesCompletados,
    required this.promedioCalificacion,
  });
}