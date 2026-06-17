import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inv_telas/models/base/base_entity.dart';

import 'lote_estado.dart';
import 'lote_tipo.dart';

class Lote extends BaseEntity {
  final String empresaId;
  final String sucursalId;
  final String proveedorId;
  final String monedaId;
  final String numeroLote;
  final String? observacion;
  final LoteTipo tipo;
  final LoteEstado estado;
  final double tipoCambioRegistro;
  final double? tipoCambioFinal;
  final double subtotalMonedaOrigen;
  final double subtotalMonedaBase;
  final double totalGastos;
  final double totalFinal;
  final bool stockGenerado;

  const Lote({
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
    required this.sucursalId,
    required this.proveedorId,
    required this.monedaId,
    required this.numeroLote,
    this.observacion,
    required this.tipo,
    required this.estado,
    required this.tipoCambioRegistro,
    this.tipoCambioFinal,
    required this.subtotalMonedaOrigen,
    required this.subtotalMonedaBase,
    required this.totalGastos,
    required this.totalFinal,
    this.stockGenerado = false,
  });

  factory Lote.fromMap(Map<String, dynamic> map) {
    DateTime? parse(dynamic value) {
      if (value == null) return null;

      if (value is Timestamp) {
        return value.toDate();
      }

      return DateTime.tryParse(value.toString());
    }

    return Lote(
      id: map['id'] ?? '',
      activo: map['activo'] ?? true,
      eliminado: map['eliminado'] ?? false,
      usuarioCreacion: map['usuarioCreacion'] ?? '',
      usuarioModificacion: map['usuarioModificacion'],
      usuarioEliminacion: map['usuarioEliminacion'],
      fechaCreacion: parse(map['fechaCreacion']) ?? DateTime.now(),
      fechaModificacion: parse(map['fechaModificacion']),
      fechaEliminacion: parse(map['fechaEliminacion']),
      empresaId: map['empresaId'] ?? '',
      sucursalId: map['sucursalId'] ?? '',
      proveedorId: map['proveedorId'] ?? '',
      monedaId: map['monedaId'] ?? '',
      numeroLote: map['numeroLote'] ?? '',
      observacion: map['observacion'],
      tipo: LoteTipoExtension.fromString(map['tipo'] ?? 'LOCAL'),
      estado: LoteEstadoExtension.fromString(map['estado'] ?? 'BORRADOR'),
      tipoCambioRegistro: (map['tipoCambioRegistro'] ?? 1).toDouble(),
      tipoCambioFinal: map['tipoCambioFinal'] != null
          ? (map['tipoCambioFinal']).toDouble()
          : null,
      subtotalMonedaOrigen: (map['subtotalMonedaOrigen'] ?? 0).toDouble(),
      subtotalMonedaBase: (map['subtotalMonedaBase'] ?? 0).toDouble(),
      totalGastos: (map['totalGastos'] ?? 0).toDouble(),
      totalFinal: (map['totalFinal'] ?? 0).toDouble(),
      stockGenerado: map['stockGenerado'] ?? false,
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
      'empresaId': empresaId,
      'sucursalId': sucursalId,
      'proveedorId': proveedorId,
      'monedaId': monedaId,
      'numeroLote': numeroLote,
      'observacion': observacion,
      'tipo': tipo.nombre,
      'estado': estado.nombre,
      'tipoCambioRegistro': tipoCambioRegistro,
      'tipoCambioFinal': tipoCambioFinal,
      'subtotalMonedaOrigen': subtotalMonedaOrigen,
      'subtotalMonedaBase': subtotalMonedaBase,
      'totalGastos': totalGastos,
      'totalFinal': totalFinal,
      'stockGenerado': stockGenerado,
    };
  }

  Lote copyWith({
    String? id,
    bool? activo,
    bool? eliminado,
    String? usuarioCreacion,
    String? usuarioModificacion,
    String? usuarioEliminacion,
    DateTime? fechaCreacion,
    DateTime? fechaModificacion,
    DateTime? fechaEliminacion,
    String? empresaId,
    String? sucursalId,
    String? proveedorId,
    String? monedaId,
    String? numeroLote,
    String? observacion,
    LoteTipo? tipo,
    LoteEstado? estado,
    double? tipoCambioRegistro,
    double? tipoCambioFinal,
    double? subtotalMonedaOrigen,
    double? subtotalMonedaBase,
    double? totalGastos,
    double? totalFinal,
    bool? stockGenerado,
  }) {
    return Lote(
      id: id ?? this.id,
      activo: activo ?? this.activo,
      eliminado: eliminado ?? this.eliminado,
      usuarioCreacion: usuarioCreacion ?? this.usuarioCreacion,
      usuarioModificacion: usuarioModificacion ?? this.usuarioModificacion,
      usuarioEliminacion: usuarioEliminacion ?? this.usuarioEliminacion,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaModificacion: fechaModificacion ?? this.fechaModificacion,
      fechaEliminacion: fechaEliminacion ?? this.fechaEliminacion,
      empresaId: empresaId ?? this.empresaId,
      sucursalId: sucursalId ?? this.sucursalId,
      proveedorId: proveedorId ?? this.proveedorId,
      monedaId: monedaId ?? this.monedaId,
      numeroLote: numeroLote ?? this.numeroLote,
      observacion: observacion ?? this.observacion,
      tipo: tipo ?? this.tipo,
      estado: estado ?? this.estado,
      tipoCambioRegistro: tipoCambioRegistro ?? this.tipoCambioRegistro,
      tipoCambioFinal: tipoCambioFinal ?? this.tipoCambioFinal,
      subtotalMonedaOrigen: subtotalMonedaOrigen ?? this.subtotalMonedaOrigen,
      subtotalMonedaBase: subtotalMonedaBase ?? this.subtotalMonedaBase,
      totalGastos: totalGastos ?? this.totalGastos,
      totalFinal: totalFinal ?? this.totalFinal,
      stockGenerado: stockGenerado ?? this.stockGenerado,
    );
  }
}
