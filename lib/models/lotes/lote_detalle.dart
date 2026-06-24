import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inv_telas/models/base/base_entity.dart';

class LoteDetalle extends BaseEntity {
  final String loteId;
  final String tipoTelaId;
  final String? varianteId;
  final String? colorId;
  final int cantidadRollos;
  final double metrosPorRollo;
  final double totalMetros;
  final double costoMetroOrigen;
  final double costoMetroBase;
  final double costoRolloOrigen;
  final double costoRolloBase;
  final String? codigoTelaProveedorId; //hay que agregar esto

  const LoteDetalle({
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
    required this.tipoTelaId,
    this.varianteId,
    this.colorId,

    this.codigoTelaProveedorId,
    required this.cantidadRollos,
    required this.metrosPorRollo,
    required this.totalMetros,
    required this.costoMetroOrigen,
    required this.costoMetroBase,
    required this.costoRolloOrigen,
    required this.costoRolloBase,
  });

  factory LoteDetalle.fromMap(Map<String, dynamic> map) {
    DateTime? parse(dynamic value) {
      if (value == null) return null;

      if (value is Timestamp) {
        return value.toDate();
      }

      return DateTime.tryParse(value.toString());
    }

    return LoteDetalle(
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
      tipoTelaId: map['tipoTelaId'] ?? '',
      varianteId: map['varianteId'],
      colorId: map['colorId'],
      codigoTelaProveedorId: map['codigoTelaProveedorId'],
      cantidadRollos: map['cantidadRollos'] ?? 0,
      metrosPorRollo: (map['metrosPorRollo'] ?? 0).toDouble(),
      totalMetros: (map['totalMetros'] ?? 0).toDouble(),
      costoMetroOrigen: (map['costoMetroOrigen'] ?? 0).toDouble(),
      costoMetroBase: (map['costoMetroBase'] ?? 0).toDouble(),
      costoRolloOrigen: (map['costoRolloOrigen'] ?? 0).toDouble(),
      costoRolloBase: (map['costoRolloBase'] ?? 0).toDouble(),
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
      'tipoTelaId': tipoTelaId,
      'varianteId': varianteId,
      'colorId': colorId,
      'codigoTelaProveedorId': codigoTelaProveedorId,
      'cantidadRollos': cantidadRollos,
      'metrosPorRollo': metrosPorRollo,
      'totalMetros': totalMetros,
      'costoMetroOrigen': costoMetroOrigen,
      'costoMetroBase': costoMetroBase,
      'costoRolloOrigen': costoRolloOrigen,
      'costoRolloBase': costoRolloBase,
    };
  }

  LoteDetalle copyWith({
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
    String? tipoTelaId,
    String? varianteId,
    String? colorId,
    String? codigoTelaProveedorId,
    int? cantidadRollos,
    double? metrosPorRollo,
    double? totalMetros,
    double? costoMetroOrigen,
    double? costoMetroBase,
    double? costoRolloOrigen,
    double? costoRolloBase,
  }) {
    return LoteDetalle(
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
      tipoTelaId: tipoTelaId ?? this.tipoTelaId,
      varianteId: varianteId ?? this.varianteId,
      colorId: colorId ?? this.colorId,
      codigoTelaProveedorId:
          codigoTelaProveedorId ?? this.codigoTelaProveedorId,
      cantidadRollos: cantidadRollos ?? this.cantidadRollos,
      metrosPorRollo: metrosPorRollo ?? this.metrosPorRollo,
      totalMetros: totalMetros ?? this.totalMetros,
      costoMetroOrigen: costoMetroOrigen ?? this.costoMetroOrigen,
      costoMetroBase: costoMetroBase ?? this.costoMetroBase,
      costoRolloOrigen: costoRolloOrigen ?? this.costoRolloOrigen,
      costoRolloBase: costoRolloBase ?? this.costoRolloBase,
    );
  }
}
