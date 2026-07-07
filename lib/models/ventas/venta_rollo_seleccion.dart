import 'stock_actual.dart';

class VentaRolloSeleccion {
  final String rolloId;
  final double metrosExtraidos;
  final StockRolloEstado estadoAnterior;
  final StockRolloEstado estadoNuevo;

  const VentaRolloSeleccion({
    required this.rolloId,
    required this.metrosExtraidos,
    required this.estadoAnterior,
    required this.estadoNuevo,
  });

  Map<String, dynamic> toMap() {
    return {
      'rolloId': rolloId,
      'metrosExtraidos': metrosExtraidos,
      'estadoAnterior': estadoAnterior.nombre,
      'estadoNuevo': estadoNuevo.nombre,
    };
  }
}
