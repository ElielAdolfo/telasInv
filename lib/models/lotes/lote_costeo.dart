import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inv_telas/models/base/base_entity.dart';

class LoteCosteo extends BaseEntity {
  final String loteId;

  final double subtotalCompra;
  final double subtotalGastos;

  final double costoFinal;

  final double costoMetroFinal;
  final double costoRolloFinal;

  final String jsonDesglose;

  const LoteCosteo({
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
    required this.subtotalCompra,
    required this.subtotalGastos,
    required this.costoFinal,
    required this.costoMetroFinal,
    required this.costoRolloFinal,
    required this.jsonDesglose,
  });

  factory LoteCosteo.fromMap(Map<String, dynamic> map) {
    DateTime? parse(dynamic value) {
      if (value == null) return null;

      if (value is Timestamp) {
        return value.toDate();
      }

      return DateTime.tryParse(value.toString());
    }

    return LoteCosteo(
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
      subtotalCompra: (map['subtotalCompra'] ?? 0).toDouble(),
      subtotalGastos: (map['subtotalGastos'] ?? 0).toDouble(),
      costoFinal: (map['costoFinal'] ?? 0).toDouble(),
      costoMetroFinal: (map['costoMetroFinal'] ?? 0).toDouble(),
      costoRolloFinal: (map['costoRolloFinal'] ?? 0).toDouble(),
      jsonDesglose: map['jsonDesglose'] ?? '',
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
      'subtotalCompra': subtotalCompra,
      'subtotalGastos': subtotalGastos,
      'costoFinal': costoFinal,
      'costoMetroFinal': costoMetroFinal,
      'costoRolloFinal': costoRolloFinal,
      'jsonDesglose': jsonDesglose,
    };
  }

  LoteCosteo copyWith({
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
    double? subtotalCompra,
    double? subtotalGastos,
    double? costoFinal,
    double? costoMetroFinal,
    double? costoRolloFinal,
    String? jsonDesglose,
  }) {
    return LoteCosteo(
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
      subtotalCompra: subtotalCompra ?? this.subtotalCompra,
      subtotalGastos: subtotalGastos ?? this.subtotalGastos,
      costoFinal: costoFinal ?? this.costoFinal,
      costoMetroFinal: costoMetroFinal ?? this.costoMetroFinal,
      costoRolloFinal: costoRolloFinal ?? this.costoRolloFinal,
      jsonDesglose: jsonDesglose ?? this.jsonDesglose,
    );
  }
}
