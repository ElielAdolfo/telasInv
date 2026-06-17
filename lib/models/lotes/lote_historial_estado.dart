import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inv_telas/models/base/base_entity.dart';

import 'lote_estado.dart';

class LoteHistorialEstado extends BaseEntity {
  final String loteId;

  /// Estado anterior
  final LoteEstado estadoAnterior;

  /// Estado nuevo
  final LoteEstado estadoNuevo;

  /// Comentario opcional del usuario
  final String? observacion;

  /// Snapshot opcional del lote antes del cambio
  final Map<String, dynamic>? datosAntes;

  /// Snapshot opcional del lote después del cambio
  final Map<String, dynamic>? datosDespues;

  const LoteHistorialEstado({
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
    required this.estadoAnterior,
    required this.estadoNuevo,
    this.observacion,
    this.datosAntes,
    this.datosDespues,
  });

  factory LoteHistorialEstado.fromMap(Map<String, dynamic> map) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;

      if (value is Timestamp) {
        return value.toDate();
      }

      if (value is String) {
        return DateTime.tryParse(value);
      }

      return null;
    }

    return LoteHistorialEstado(
      id: map['id'] ?? '',
      activo: map['activo'] ?? true,
      eliminado: map['eliminado'] ?? false,
      usuarioCreacion: map['usuarioCreacion'] ?? '',
      usuarioModificacion: map['usuarioModificacion'],
      usuarioEliminacion: map['usuarioEliminacion'],
      fechaCreacion: parseDate(map['fechaCreacion']) ?? DateTime.now(),
      fechaModificacion: parseDate(map['fechaModificacion']),
      fechaEliminacion: parseDate(map['fechaEliminacion']),
      loteId: map['loteId'] ?? '',
      estadoAnterior: LoteEstadoExtension.fromString(
        map['estadoAnterior'] ?? 'BORRADOR',
      ),
      estadoNuevo: LoteEstadoExtension.fromString(
        map['estadoNuevo'] ?? 'BORRADOR',
      ),
      observacion: map['observacion'],
      datosAntes: map['datosAntes'] != null
          ? Map<String, dynamic>.from(map['datosAntes'])
          : null,
      datosDespues: map['datosDespues'] != null
          ? Map<String, dynamic>.from(map['datosDespues'])
          : null,
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

      'estadoAnterior': estadoAnterior.nombre,
      'estadoNuevo': estadoNuevo.nombre,

      'observacion': observacion,

      'datosAntes': datosAntes,
      'datosDespues': datosDespues,
    };
  }

  LoteHistorialEstado copyWith({
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
    LoteEstado? estadoAnterior,
    LoteEstado? estadoNuevo,
    String? observacion,
    Map<String, dynamic>? datosAntes,
    Map<String, dynamic>? datosDespues,
  }) {
    return LoteHistorialEstado(
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
      estadoAnterior: estadoAnterior ?? this.estadoAnterior,
      estadoNuevo: estadoNuevo ?? this.estadoNuevo,
      observacion: observacion ?? this.observacion,
      datosAntes: datosAntes ?? this.datosAntes,
      datosDespues: datosDespues ?? this.datosDespues,
    );
  }

  @override
  String toString() {
    return '''
LoteHistorialEstado(
  id: $id,
  loteId: $loteId,
  estadoAnterior: ${estadoAnterior.nombre},
  estadoNuevo: ${estadoNuevo.nombre},
  usuarioCreacion: $usuarioCreacion,
  fechaCreacion: $fechaCreacion
)
''';
  }
}
