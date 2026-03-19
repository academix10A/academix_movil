class Beneficio {
  final int id;
  final String nombre;
  final String descripcion;

  Beneficio({
    required this.id,
    required this.nombre,
    required this.descripcion,
  });

  factory Beneficio.fromJson(Map<String, dynamic> json) {
    return Beneficio(
      id: json['id_beneficio'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
    );
  }
}

class Membresia {
  final int id;
  final String nombre;
  final String descripcion;
  final double costo;
  final String tipo;
  final int duracionDias;
  final List<Beneficio> beneficios;

  Membresia({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.costo,
    required this.tipo,
    required this.duracionDias,
    required this.beneficios,
  });

  factory Membresia.fromJson(Map<String, dynamic> json) {
    return Membresia(
      id: json['id_membresia'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      costo: (json['costo'] as num).toDouble(),
      tipo: json['tipo'],
      duracionDias: json['duracion_dias'],
      beneficios: (json['beneficios'] as List)
          .map((b) => Beneficio.fromJson(b))
          .toList(),
    );
  }
}