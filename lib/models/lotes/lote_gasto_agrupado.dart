class LoteGastoAgrupado {
  final String key;
  final String loteDetalleId;
  final String proveedor;
  final String tipoTela;
  final int cantidadRollos;
  final double totalMetros;
  final String? monedaId;
  final String monedaNombre;
  final String monedaSimbolo;
  final double costoMetroOrigen;

  double get totalCosto => totalMetros * costoMetroOrigen;
  

  LoteGastoAgrupado({
    required this.key,
    required this.loteDetalleId,
    required this.proveedor,
    required this.tipoTela,
    required this.cantidadRollos,
    required this.totalMetros,
    required this.monedaId,
    required this.monedaNombre,
    required this.monedaSimbolo,
    required this.costoMetroOrigen,
  });
}
