import 'package:cloud_firestore/cloud_firestore.dart';

class RolloInfo {
  final String id;
  final String loteDetalleId;
  final double metraje;
  final String colorId;
  final String sucursalActualId;
  final String estado;
  final int cantidad;
  final DateTime? fechaCreacion;
  // Aquí guardaremos numRollo, peso, gramaje, etc., dinámicamente
  final Map<String, dynamic> atributosEspeciales;

  RolloInfo({
    required this.id,
    required this.loteDetalleId,
    required this.metraje,
    required this.colorId,
    required this.cantidad,
    this.sucursalActualId = 'central',
    this.estado = 'disponible',
    this.fechaCreacion,
    this.atributosEspeciales = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'loteDetalleId': loteDetalleId,
      'metraje': metraje,
      'colorId': colorId,
      'cantidad': cantidad,
      'sucursalActualId': sucursalActualId,
      'estado': estado,
      'fechaCreacion': fechaCreacion != null
          ? Timestamp.fromDate(fechaCreacion!)
          : FieldValue.serverTimestamp(),
      'atributosEspeciales': atributosEspeciales,
    };
  }

  factory RolloInfo.fromMap(Map<String, dynamic> map) {
    return RolloInfo(
      id: map['id'] ?? '',
      loteDetalleId: map['loteDetalleId'] ?? '',
      metraje: (map['metraje'] as num).toDouble(),
      colorId: map['colorId'] ?? '',
      cantidad: map['cantidad'] ?? -1,
      sucursalActualId: map['sucursalActualId'] ?? 'central',
      estado: map['estado'] ?? 'disponible',
      fechaCreacion: (map['fechaCreacion'] as Timestamp?)?.toDate(),
      atributosEspeciales:
          map['atributosEspeciales'] as Map<String, dynamic>? ?? {},
    );
  }
}
