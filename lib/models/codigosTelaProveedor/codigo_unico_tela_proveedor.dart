import 'package:cloud_firestore/cloud_firestore.dart';

import '../base/base_entity.dart';
import 'color_codigo.dart';

class CodigoUnicoTelaProveedor extends BaseEntity {
  final String empresaId;
  final String proveedorId;
  final String tipoTelaId;

  /// Lista de colores asociados al proveedor + tipo tela
  final List<ColorCodigo> colores;

  const CodigoUnicoTelaProveedor({
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
    required this.proveedorId,
    required this.tipoTelaId,
    required this.colores,
  });

  factory CodigoUnicoTelaProveedor.fromMap(Map<String, dynamic> map) {
    DateTime? parse(dynamic value) {
      if (value == null) return null;

      if (value is Timestamp) {
        return value.toDate();
      }

      return DateTime.tryParse(value.toString());
    }

    return CodigoUnicoTelaProveedor(
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

      proveedorId: map['proveedorId'] ?? '',

      tipoTelaId: map['tipoTelaId'] ?? '',

      colores: (map['colores'] as List<dynamic>? ?? [])
          .map((e) => ColorCodigo.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
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

      'proveedorId': proveedorId,

      'tipoTelaId': tipoTelaId,

      'colores': colores.map((e) => e.toMap()).toList(),
    };
  }

  CodigoUnicoTelaProveedor copyWith({
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

    String? proveedorId,

    String? tipoTelaId,

    List<ColorCodigo>? colores,
  }) {
    return CodigoUnicoTelaProveedor(
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

      proveedorId: proveedorId ?? this.proveedorId,

      tipoTelaId: tipoTelaId ?? this.tipoTelaId,

      colores: colores ?? this.colores,
    );
  }
}
