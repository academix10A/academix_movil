/// Entidades puras de dominio.
/// NO tienen fromJson — el parsing JSON ocurre solo en data/models.

class Beneficio {
  final int id;
  final String nombre;
  final String descripcion;

  Beneficio({
    required this.id,
    required this.nombre,
    required this.descripcion,
  });
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
}