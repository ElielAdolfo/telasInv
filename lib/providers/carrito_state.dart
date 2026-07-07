import 'package:inv_telas/models/ventas/carrito_item.dart';

class CarritoState {
  final List<CarritoItem> items;
  final bool guardandoEnBaseDeDatos; // Para saber si está trabajando de fondo
  final bool tieneErrorSincronizacion; // Para saber si falló el guardado remoto

  const CarritoState({
    this.items = const [],
    this.guardandoEnBaseDeDatos = false,
    this.tieneErrorSincronizacion = false,
  });

  double get totalMetros =>
      items.fold(0.0, (sum, item) => sum + item.cantidadMetros);
  int get totalRollos =>
      items.fold(0, (sum, item) => sum + item.cantidadRollos);
  double get total => items.fold(0.0, (sum, item) => sum + item.subtotal);

  CarritoState copyWith({
    List<CarritoItem>? items,
    bool? guardandoEnBaseDeDatos,
    bool? tieneErrorSincronizacion,
  }) {
    return CarritoState(
      items: items ?? this.items,
      guardandoEnBaseDeDatos:
          guardandoEnBaseDeDatos ?? this.guardandoEnBaseDeDatos,
      tieneErrorSincronizacion:
          tieneErrorSincronizacion ?? this.tieneErrorSincronizacion,
    );
  }
}
