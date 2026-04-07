import '../../domain/entities/user_entity.dart';

// UserModel vive en la capa data porque conoce detalles de la API (claves JSON).
// UserEntity en domain permanece pura, sin acoplarse al formato de red.
class UserModel extends UserEntity {
  const UserModel({
    required super.nombre,
    required super.apellidoPaterno,
    required super.apellidoMaterno,
    required super.correo,
    required super.contrasena,
    super.idRol = 2,
    super.idEstado = 1,
  });

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      nombre: entity.nombre,
      apellidoPaterno: entity.apellidoPaterno,
      apellidoMaterno: entity.apellidoMaterno,
      correo: entity.correo,
      contrasena: entity.contrasena,
      idRol: entity.idRol,
      idEstado: entity.idEstado,
    );
  }

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'apellido_paterno': apellidoPaterno,
    'apellido_materno': apellidoMaterno,
    'correo': correo,
    'contrasena': contrasena,
    'id_rol': idRol,
    'id_estado': idEstado,
  };
}