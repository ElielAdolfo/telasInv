class DesgloseRollo {
  final String id;

  // agrupación
  final int cantidad;

  // datos comunes
  final double metraje;
  final String? colorId;

  // modo individual
  final String? numeroRollo;
  final String? codigoUnico;

  final bool individual;

  DesgloseRollo({
    required this.id,
    required this.cantidad,
    required this.metraje,
    this.colorId,
    this.numeroRollo,
    this.codigoUnico,
    this.individual = false,
  });
}
