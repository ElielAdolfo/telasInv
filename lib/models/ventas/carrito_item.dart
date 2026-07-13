import 'venta_rollo_seleccion.dart';

class CarritoItem {
  final String id;
  final String tipoTelaId;
  final String? colorId;
  final String loteId;
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
    required this.cantidadMetros,
    required this.cantidadRollos,
    required this.precioUnitario,
    required this.esContinuo,
    required this.rollosSeleccionados,
  });
  CarritoItem copyWith({
    String? id,
    String? tipoTelaId,
    String? colorId,
    String? loteId,
    double? cantidadMetros,
    int? cantidadRollos,
    double? precioUnitario,
    bool? esContinuo,
    List<VentaRolloSeleccion>? rollosSeleccionados,
  }) {
    return CarritoItem(
      id: id ?? this.id,
      tipoTelaId: tipoTelaId ?? this.tipoTelaId,
      colorId: colorId ?? this.colorId,
      loteId: loteId ?? this.loteId,
      cantidadMetros: cantidadMetros ?? this.cantidadMetros,
      cantidadRollos: cantidadRollos ?? this.cantidadRollos,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      esContinuo: esContinuo ?? this.esContinuo,
      rollosSeleccionados: rollosSeleccionados ?? this.rollosSeleccionados,
    );
  }

  double get subtotal =>
      (cantidadMetros > 0 ? cantidadMetros : cantidadRollos.toDouble()) *
      precioUnitario;
}
