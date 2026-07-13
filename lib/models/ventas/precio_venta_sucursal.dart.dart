import 'package:inv_telas/models/base/base_entity.dart';

class PrecioVentaSucursal extends BaseEntity {
  final String sucursalId;
  final String tipoTelaId;

  final double precioVentaMetro;

  // Campos opcionales (Nullables)
  final double? precioVentaXMayor;
  final double? metrosMinimoXMayor;

  final double? precioVentaSuperMayor;
  final double? metrosMinimoSuperMayor;

  final double? precioXRollo;

  const PrecioVentaSucursal({
    required super.id,
    required super.activo,
    required super.eliminado,
    required super.usuarioCreacion,
    super.usuarioModificacion,
    super.usuarioEliminacion,
    required super.fechaCreacion,
    super.fechaModificacion,
    super.fechaEliminacion,
    required this.sucursalId,
    required this.tipoTelaId,
    required this.precioVentaMetro,
    this.precioVentaXMayor,
    this.metrosMinimoXMayor,
    this.precioVentaSuperMayor,
    this.metrosMinimoSuperMayor,
    this.precioXRollo,
  });

  Map<String, dynamic> toMap() {
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
      'sucursalId': sucursalId,
      'tipoTelaId': tipoTelaId,
      'precioVentaMetro': precioVentaMetro,
      'precioVentaXMayor': precioVentaXMayor,
      'metrosMinimoXMayor': metrosMinimoXMayor,
      'precioVentaSuperMayor': precioVentaSuperMayor,
      'metrosMinimoSuperMayor': metrosMinimoSuperMayor,
      'precioXRollo': precioXRollo,
    };
  }

  factory PrecioVentaSucursal.fromMap(Map<String, dynamic> map) {
    return PrecioVentaSucursal(
      id: map['id'] ?? '',
      activo: map['activo'] ?? true,
      eliminado: map['eliminado'] ?? false,
      usuarioCreacion: map['usuarioCreacion'] ?? '',
      usuarioModificacion: map['usuarioModificacion'],
      usuarioEliminacion: map['usuarioEliminacion'],
      fechaCreacion: DateTime.parse(map['fechaCreacion']),
      fechaModificacion: map['fechaModificacion'] != null
          ? DateTime.parse(map['fechaModificacion'])
          : null,
      fechaEliminacion: map['fechaEliminacion'] != null
          ? DateTime.parse(map['fechaEliminacion'])
          : null,
      sucursalId: map['sucursalId'] ?? '',
      tipoTelaId: map['tipoTelaId'] ?? '',
      precioVentaMetro: (map['precioVentaMetro'] as num).toDouble(),
      precioVentaXMayor: map['precioVentaXMayor'] != null
          ? (map['precioVentaXMayor'] as num).toDouble()
          : null,
      metrosMinimoXMayor: map['metrosMinimoXMayor'] != null
          ? (map['metrosMinimoXMayor'] as num).toDouble()
          : null,
      precioVentaSuperMayor: map['precioVentaSuperMayor'] != null
          ? (map['precioVentaSuperMayor'] as num).toDouble()
          : null,
      metrosMinimoSuperMayor: map['metrosMinimoSuperMayor'] != null
          ? (map['metrosMinimoSuperMayor'] as num).toDouble()
          : null,
      precioXRollo: map['precioXRollo'] != null
          ? (map['precioXRollo'] as num).toDouble()
          : null,
    );
  }
}
