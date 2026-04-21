import '../../domain/entities/membresia_entity.dart';

class BeneficioModel {
  final int id;
  final String nombre;
  final String descripcion;

  BeneficioModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
  });

  factory BeneficioModel.fromJson(Map<String, dynamic> json) {
    return BeneficioModel(
      id: json['id_beneficio'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
    );
  }

  Beneficio toEntity() {
    return Beneficio(id: id, nombre: nombre, descripcion: descripcion);
  }
}

class MembresiaModel {
  final int id;
  final String nombre;
  final String descripcion;
  final double costo;
  final String tipo;
  final int duracionDias;
  final List<BeneficioModel> beneficios;

  MembresiaModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.costo,
    required this.tipo,
    required this.duracionDias,
    required this.beneficios,
  });

  factory MembresiaModel.fromJson(Map<String, dynamic> json) {
    return MembresiaModel(
      id: json['id_membresia'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      costo: (json['costo'] as num).toDouble(),
      tipo: json['tipo'],
      duracionDias: json['duracion_dias'],
      beneficios: (json['beneficios'] as List)
          .map((b) => BeneficioModel.fromJson(b))
          .toList(),
    );
  }

  Membresia toEntity() {
    return Membresia(
      id: id,
      nombre: nombre,
      descripcion: descripcion,
      costo: costo,
      tipo: tipo,
      duracionDias: duracionDias,
      beneficios: beneficios.map((b) => b.toEntity()).toList(),
    );
  }
}