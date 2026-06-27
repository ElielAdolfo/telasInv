import 'package:inv_telas/models/base/base_entity.dart';

class Gasto extends BaseEntity {
  final String empresaId;
  final String loteId;
  final String? loteDetalleId;
  final String descripcion;
  final String monedaId;
  final String monedaCodigo;
  final double montoOrigen;
  final double factor;
  final double tipoCambio;
  final double totalBs;

  const Gasto({
    required super.id,
    required super.activo,
    required super.eliminado,
    required super.usuarioCreacion,
    super.usuarioModificacion,
    super.usuarioEliminacion,
    required super.fechaCreacion,
    super.fechaModificacion,
    super.fechaEliminacion,
    required this.empresaId,
    required this.loteId,
    this.loteDetalleId,
    required this.descripcion,
    required this.monedaId,
    required this.monedaCodigo,
    required this.montoOrigen,
    required this.factor,
    required this.tipoCambio,
    required this.totalBs,
  });

  Gasto copyWith({
    String? id,
    String? loteId,
    String? loteDetalleId,
    String? descripcion,
    double? montoOrigen,
    double? factor,
    double? tipoCambio,
    double? totalBs,
    bool? activo,
    bool? eliminado,
    String? usuarioModificacion,
    DateTime? fechaModificacion,
    String? usuarioEliminacion,
    DateTime? fechaEliminacion,
  }) {
    return Gasto(
      id: id ?? this.id,
      activo: activo ?? this.activo,
      eliminado: eliminado ?? this.eliminado,
      usuarioCreacion: usuarioCreacion,
      usuarioModificacion: usuarioModificacion ?? this.usuarioModificacion,
      usuarioEliminacion: usuarioEliminacion ?? this.usuarioEliminacion,
      fechaCreacion: fechaCreacion,
      fechaModificacion: fechaModificacion ?? this.fechaModificacion,
      fechaEliminacion: fechaEliminacion ?? this.fechaEliminacion,
      empresaId: empresaId,
      loteId: loteId ?? this.loteId,
      loteDetalleId: loteDetalleId ?? this.loteDetalleId,
      descripcion: descripcion ?? this.descripcion,
      monedaId: monedaId,
      monedaCodigo: monedaCodigo,
      montoOrigen: montoOrigen ?? this.montoOrigen,
      factor: factor ?? this.factor,
      tipoCambio: tipoCambio ?? this.tipoCambio,
      totalBs: totalBs ?? this.totalBs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'activo': activo,
      'eliminado': eliminado,
      'usuarioCreacion': usuarioCreacion,
      'usuarioModificacion': usuarioModificacion,
      'usuarioEliminacion': usuarioEliminacion,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'fechaModificacion': fechaModificacion?.toIso8601String(),
      'fechaEliminacion': fechaEliminacion?.toIso8601String(),
      'empresaId': empresaId,
      'loteId': loteId,
      'loteDetalleId': loteDetalleId,
      'descripcion': descripcion,
      'monedaId': monedaId,
      'monedaCodigo': monedaCodigo,
      'montoOrigen': montoOrigen,
      'factor': factor,
      'tipoCambio': tipoCambio,
      'totalBs': totalBs,
    };
  }

  factory Gasto.fromJson(Map<String, dynamic> json) {
    return Gasto(
      id: json['id'] as String,
      activo: json['activo'] as bool,
      eliminado: json['eliminado'] as bool,
      usuarioCreacion: json['usuarioCreacion'] as String,
      usuarioModificacion: json['usuarioModificacion'] as String?,
      usuarioEliminacion: json['usuarioEliminacion'] as String?,
      fechaCreacion: DateTime.parse(json['fechaCreacion'] as String),
      fechaModificacion: json['fechaModificacion'] != null
          ? DateTime.parse(json['fechaModificacion'] as String)
          : null,
      fechaEliminacion: json['fechaEliminacion'] != null
          ? DateTime.parse(json['fechaEliminacion'] as String)
          : null,
      empresaId: json['empresaId'] as String,
      loteId: json['loteId'] as String,
      loteDetalleId: json['loteDetalleId'] as String?,
      descripcion: json['descripcion'] as String,
      monedaId: json['monedaId'] as String,
      monedaCodigo: json['monedaCodigo'] as String,
      montoOrigen: (json['montoOrigen'] as num).toDouble(),
      factor: (json['factor'] as num).toDouble(),
      tipoCambio: (json['tipoCambio'] as num).toDouble(),
      totalBs: (json['totalBs'] as num).toDouble(),
    );
  }
}
