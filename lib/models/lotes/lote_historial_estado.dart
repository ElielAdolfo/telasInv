import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inv_telas/models/base/base_entity.dart';
import 'lote_estado.dart';

class LoteHistorialEstado extends BaseEntity {
  final String loteId;
  final LoteEstado estadoAnterior;
  final LoteEstado estadoNuevo;
  final String? observacion;

  /// Captura del lote con sus detalles y rollos en el momento del cambio
  final Map<String, dynamic> snapshot;

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
    required this.snapshot,
  });

  factory LoteHistorialEstado.fromMap(Map<String, dynamic> map) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value);
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
      snapshot: map['snapshot'] != null
          ? Map<String, dynamic>.from(map['snapshot'])
          : {},
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
      'snapshot': snapshot,
    };
  }
}
