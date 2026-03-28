class UserEntity {
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String correo;
  final String contrasena;
  final int idRol;
  final int idEstado;

  const UserEntity({
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.correo,
    required this.contrasena,
    this.idRol = 2,
    this.idEstado = 1,
  });

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
