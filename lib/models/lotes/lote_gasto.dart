import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inv_telas/models/base/base_entity.dart';

class LoteGasto extends BaseEntity {
  final String loteId;
  final String descripcion;
  final String monedaId;
  final double monto;
  final double tipoCambio;
  final double montoBase;

  const LoteGasto({
    required super.id,
    required super.activo,
    required super.eliminado,
    required super.usuarioCreacion,
    super.usuarioModificacion,
    super.usuarioEliminacion,
    required super.fechaCreacion,
    super.fechaModificacion,
    super.fechaEliminacion,
    required this.loteId,
    required this.descripcion,
    required this.monedaId,
    required this.monto,
    required this.tipoCambio,
    required this.montoBase,
  });

  factory LoteGasto.fromMap(Map<String, dynamic> map) {
    DateTime? parse(dynamic value) {
      if (value == null) return null;

      if (value is Timestamp) {
        return value.toDate();
      }

      return DateTime.tryParse(value.toString());
    }

    return LoteGasto(
      id: map['id'] ?? '',
      activo: map['activo'] ?? true,
      eliminado: map['eliminado'] ?? false,
      usuarioCreacion: map['usuarioCreacion'] ?? '',
      usuarioModificacion: map['usuarioModificacion'],
      usuarioEliminacion: map['usuarioEliminacion'],
      fechaCreacion: parse(map['fechaCreacion']) ?? DateTime.now(),
      fechaModificacion: parse(map['fechaModificacion']),
      fechaEliminacion: parse(map['fechaEliminacion']),
      loteId: map['loteId'] ?? '',
      descripcion: map['descripcion'] ?? '',
      monedaId: map['monedaId'] ?? '',
      monto: (map['monto'] ?? 0).toDouble(),
      tipoCambio: (map['tipoCambio'] ?? 1).toDouble(),
      montoBase: (map['montoBase'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'activo': activo,
      'eliminado': eliminado,
      'usuarioCreacion': usuarioCreacion,
      'usuarioModificacion': usuarioModificacion,
      'usuarioEliminacion': usuarioEliminacion,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'fechaModificacion': fechaModificacion != null
          ? Timestamp.fromDate(fechaModificacion!)
          : null,
      'fechaEliminacion': fechaEliminacion != null
          ? Timestamp.fromDate(fechaEliminacion!)
          : null,
      'loteId': loteId,
      'descripcion': descripcion,
      'monedaId': monedaId,
      'monto': monto,
      'tipoCambio': tipoCambio,
      'montoBase': montoBase,
    };
  }

  LoteGasto copyWith({
    String? id,
    bool? activo,
    bool? eliminado,
    String? usuarioCreacion,
    String? usuarioModificacion,
    String? usuarioEliminacion,
    DateTime? fechaCreacion,
    DateTime? fechaModificacion,
    DateTime? fechaEliminacion,
    String? loteId,
    String? descripcion,
    String? monedaId,
    double? monto,
    double? tipoCambio,
    double? montoBase,
  }) {
    return LoteGasto(
      id: id ?? this.id,
      activo: activo ?? this.activo,
      eliminado: eliminado ?? this.eliminado,
      usuarioCreacion: usuarioCreacion ?? this.usuarioCreacion,
      usuarioModificacion: usuarioModificacion ?? this.usuarioModificacion,
      usuarioEliminacion: usuarioEliminacion ?? this.usuarioEliminacion,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaModificacion: fechaModificacion ?? this.fechaModificacion,
      fechaEliminacion: fechaEliminacion ?? this.fechaEliminacion,
      loteId: loteId ?? this.loteId,
      descripcion: descripcion ?? this.descripcion,
      monedaId: monedaId ?? this.monedaId,
      monto: monto ?? this.monto,
      tipoCambio: tipoCambio ?? this.tipoCambio,
      montoBase: montoBase ?? this.montoBase,
    );
  }
}
