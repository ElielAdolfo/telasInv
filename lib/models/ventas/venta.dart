// lib/models/ventas/venta.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Venta {
  final String id;
  final String jornadaId;
  final String empresaId;
  final String sucursalId;
  final String usuarioId;
  final double totalBs;
  final double tipoCambioAplicado;
  final DateTime fechaVenta;
  final List<VentaDetalle> detalles;

  const Venta({
    required this.id,
    required this.jornadaId,
    required this.empresaId,
    required this.sucursalId,
    required this.usuarioId,
    required this.totalBs,
    required this.tipoCambioAplicado,
    required this.fechaVenta,
    required this.detalles,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'jornadaId': jornadaId,
      'empresaId': empresaId,
      'sucursalId': sucursalId,
      'usuarioId': usuarioId,
      'totalBs': totalBs,
      'tipoCambioAplicado': tipoCambioAplicado,
      'fechaVenta': Timestamp.fromDate(fechaVenta),
    };
  }
}

class VentaDetalle {
  final String stockActualId; // ID del rollo físico afectado
  final String tipoTelaId;
  final String idRollo;
  final bool esVentaPorRolloEntero;
  final double metrajeVendido;
  final double precioUnitarioBs; // Precio calculado en base al T.C.
  final double subtotalBs;

  const VentaDetalle({
    required this.stockActualId,
    required this.tipoTelaId,
    required this.idRollo,
    required this.esVentaPorRolloEntero,
    required this.metrajeVendido,
    required this.precioUnitarioBs,
    required this.subtotalBs,
  });

  Map<String, dynamic> toMap() {
    return {
      'stockActualId': stockActualId,
      'tipoTelaId': tipoTelaId,
      'idRollo': idRollo,
      'esVentaPorRolloEntero': esVentaPorRolloEntero,
      'metrajeVendido': metrajeVendido,
      'precioUnitarioBs': precioUnitarioBs,
      'subtotalBs': subtotalBs,
    };
  }
}
