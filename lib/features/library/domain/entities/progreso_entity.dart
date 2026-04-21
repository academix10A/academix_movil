class ProgresoEntity {
  final double porcentajeLeido;
  final int    ultimaPosicion;
  final bool   completado;

  const ProgresoEntity({
    required this.porcentajeLeido,
    required this.ultimaPosicion,
    required this.completado,
  });

  factory ProgresoEntity.inicial() => const ProgresoEntity(
    porcentajeLeido: 0,
    ultimaPosicion:  0,
    completado:      false,
  );
}