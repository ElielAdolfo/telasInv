import 'venta_rollo_seleccion.dart';

class CarritoItem {
  final String id;
  final String tipoTelaId;
  final String? colorId;
  final String loteId;
  final String detalleAgrupacionNombre;
  final double cantidadMetros;
  final int cantidadRollos;
  final double precioUnitario;
  final bool esContinuo;
  final List<VentaRolloSeleccion> rollosSeleccionados;

  const CarritoItem({
    required this.id,
    required this.tipoTelaId,
    this.colorId,
    required this.loteId,
    required this.detalleAgrupacionNombre,
    required this.cantidadMetros,
    required this.cantidadRollos,
    required this.precioUnitario,
    required this.esContinuo,
    required this.rollosSeleccionados,
  });

  double get subtotal =>
      (cantidadMetros > 0 ? cantidadMetros : cantidadRollos.toDouble()) *
      precioUnitario;
}
