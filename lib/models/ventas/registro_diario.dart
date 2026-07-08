// lib/models/ventas/registro_diario.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'carrito_item.dart';

class RegistroDiario {
  final String? id;
  final String usuarioId;
  final String usuarioNombre;
  final String sucursalId;
  final double totalVenta;
  final int totalRollos;
  final double totalMetros;
  final DateTime fechaVenta;
  final List<CarritoItem> itemsVendidos;

  const RegistroDiario({
    this.id,
    required this.usuarioId,
    required this.usuarioNombre,
    required this.sucursalId,
    required this.totalVenta,
    required this.totalRollos,
    required this.totalMetros,
    required this.fechaVenta,
    required this.itemsVendidos,
  });

  Map<String, dynamic> toMap() {
    return {
      'usuarioId': usuarioId,
      'usuarioNombre': usuarioNombre,
      'sucursalId': sucursalId,
      'totalVenta': totalVenta,
      'totalRollos': totalRollos,
      'totalMetros': totalMetros,
      'fechaVenta': Timestamp.fromDate(fechaVenta),
      'itemsVendidos': itemsVendidos
          .map(
            (item) => {
              'id': item.id,
              'tipoTelaId': item.tipoTelaId,
              'colorId': item.colorId,
              'loteId': item.loteId,
              'cantidadMetros': item.cantidadMetros,
              'cantidadRollos': item.cantidadRollos,
              'precioUnitario': item.precioUnitario,
              'subtotal': item.subtotal,
              'rollosSeleccionados': item.rollosSeleccionados
                  .map((r) => r.toMap())
                  .toList(),
            },
          )
          .toList(),
    };
  }
}
