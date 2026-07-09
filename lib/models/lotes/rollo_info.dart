import 'package:cloud_firestore/cloud_firestore.dart';

class RolloInfo {
  final String id;
  final String loteDetalleId;

  /// Mantiene el orden exacto definido por el usuario
  final int orden;

  final double metraje;
  final String colorId;
  final String sucursalActualId;
  final String estado;
  final int cantidad;
  final DateTime? fechaCreacion;

  /// Futuros atributos dinámicos
  final Map<String, dynamic> atributosEspeciales;

  final double costoMetroOrigen;
  final double costoRolloOrigen;

  const RolloInfo({
    required this.id,
    required this.loteDetalleId,
    required this.orden,
    required this.metraje,
    required this.colorId,
    required this.cantidad,
    this.sucursalActualId = 'central',
    this.estado = 'disponible',
    this.fechaCreacion,
    this.atributosEspeciales = const {},
    required this.costoMetroOrigen,
    required this.costoRolloOrigen,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'loteDetalleId': loteDetalleId,

      // NUEVO
      'orden': orden,

      'metraje': metraje,
      'colorId': colorId,
      'cantidad': cantidad,
      'sucursalActualId': sucursalActualId,
      'estado': estado,

      'fechaCreacion': fechaCreacion != null
          ? Timestamp.fromDate(fechaCreacion!)
          : FieldValue.serverTimestamp(),

      'atributosEspeciales': atributosEspeciales,
      'costoMetroOrigen': costoMetroOrigen,
      'costoRolloOrigen': costoRolloOrigen,
    };
  }

  factory RolloInfo.fromMap(Map<String, dynamic> map) {
    return RolloInfo(
      id: map['id'] ?? '',
      loteDetalleId: map['loteDetalleId'] ?? '',

      // NUEVO
      orden: map['orden'] ?? 0,

      metraje: ((map['metraje'] ?? 0) as num).toDouble(),
      colorId: map['colorId'] ?? '',
      cantidad: map['cantidad'] ?? 0,

      sucursalActualId: map['sucursalActualId'] ?? 'central',
      estado: map['estado'] ?? 'disponible',

      fechaCreacion: (map['fechaCreacion'] as Timestamp?)?.toDate(),

      atributosEspeciales: Map<String, dynamic>.from(
        map['atributosEspeciales'] ?? {},
      ),
      costoMetroOrigen: ((map['costoMetroOrigen'] ?? 0) as num).toDouble(),
      costoRolloOrigen: ((map['costoRolloOrigen'] ?? 0) as num).toDouble(),
    );
  }

  RolloInfo copyWith({
    String? id,
    String? loteDetalleId,
    int? orden,
    double? metraje,
    String? colorId,
    String? sucursalActualId,
    String? estado,
    int? cantidad,
    DateTime? fechaCreacion,
    Map<String, dynamic>? atributosEspeciales,
    double? costoMetroOrigen,
    double? costoRolloOrigen,
  }) {
    return RolloInfo(
      id: id ?? this.id,
      loteDetalleId: loteDetalleId ?? this.loteDetalleId,
      orden: orden ?? this.orden,
      metraje: metraje ?? this.metraje,
      colorId: colorId ?? this.colorId,
      cantidad: cantidad ?? this.cantidad,
      sucursalActualId: sucursalActualId ?? this.sucursalActualId,
      estado: estado ?? this.estado,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      atributosEspeciales: atributosEspeciales ?? this.atributosEspeciales,
      costoMetroOrigen: costoMetroOrigen ?? this.costoMetroOrigen,
      costoRolloOrigen: costoRolloOrigen ?? this.costoRolloOrigen,
    );
  }

  @override
  String toString() {
    return 'RolloInfo(id: $id, orden: $orden, colorId: $colorId, cantidad: $cantidad)';
  }
}
