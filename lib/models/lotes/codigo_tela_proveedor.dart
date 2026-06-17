import 'package:cloud_firestore/cloud_firestore.dart';
import '../base/base_entity.dart';
import 'precio_config.dart';
import 'precio_sucursal_config.dart';
import 'lote_tipo.dart'; // Tu enum con LOCAL e IMPORTACION

class CodigoTelaProveedor extends BaseEntity {
  final String empresaId;
  final String proveedorId;
  final String tipoTelaId;

  // NUEVOS CAMPOS ESTRUCTURALES DE PRECIOS
  final PrecioConfig
  precioImportacion; // Único y global para todas las sucursales
  final PrecioConfig
  precioLocalGeneral; // Fallback local si la sucursal no tiene precio propio
  final List<PrecioSucursalConfig>
  preciosLocalPorSucursal; // Precios locales específicos

  const CodigoTelaProveedor({
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
    required this.precioImportacion,
    required this.precioLocalGeneral,
    this.preciosLocalPorSucursal = const [],
  });

  /// MÉTODO CLAVE: Resuelve automáticamente qué precio usar en caliente
  PrecioConfig obtenerPrecioAutomatizado({
    required LoteTipo tipoLote,
    required String sucursalId,
  }) {
    // Regla 1: Si es importación, es el mismo para todos sin importar la sucursal
    if (tipoLote == LoteTipo.importacion) {
      return precioImportacion;
    }

    // Regla 2: Si es local, buscar primero si existe una configuración específica para esta sucursal
    final precioEspecifico = preciosLocalPorSucursal.firstWhere(
      (element) => element.sucursalId == sucursalId,
      orElse: () => const PrecioSucursalConfig(
        sucursalId: '',
        precio: PrecioConfig(monedaId: '', precioMetro: 0, precioRollo: 0),
      ),
    );

    if (precioEspecifico.sucursalId.isNotEmpty) {
      return precioEspecifico.precio;
    }

    // Regla 3: Si no tiene asignado un precio por sucursal, usar el precio local general
    return precioLocalGeneral;
  }

  factory CodigoTelaProveedor.fromMap(Map<String, dynamic> map) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      return DateTime.tryParse(value.toString());
    }

    return CodigoTelaProveedor(
      id: map['id'] ?? '',
      activo: map['activo'] ?? true,
      eliminado: map['eliminado'] ?? false,
      usuarioCreacion: map['usuarioCreacion'] ?? '',
      usuarioModificacion: map['usuarioModificacion'],
      usuarioEliminacion: map['usuarioEliminacion'],
      fechaCreacion: parseDate(map['fechaCreacion']) ?? DateTime.now(),
      fechaModificacion: parseDate(map['fechaModificacion']),
      fechaEliminacion: parseDate(map['fechaEliminacion']),
      empresaId: map['empresaId'] ?? '',
      proveedorId: map['proveedorId'] ?? '',
      tipoTelaId: map['tipoTelaId'] ?? '',

      // Mapeo de nuevas estructuras de precios
      precioImportacion: PrecioConfig.fromMap(
        Map<String, dynamic>.from(map['precioImportacion'] ?? {}),
      ),
      precioLocalGeneral: PrecioConfig.fromMap(
        Map<String, dynamic>.from(map['precioLocalGeneral'] ?? {}),
      ),
      preciosLocalPorSucursal: map['preciosLocalPorSucursal'] != null
          ? (map['preciosLocalPorSucursal'] as List)
                .map(
                  (e) => PrecioSucursalConfig.fromMap(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList()
          : const [],
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

      // Serialización nativa para Firestore de los sub-objetos
      'precioImportacion': precioImportacion.toMap(),
      'precioLocalGeneral': precioLocalGeneral.toMap(),
      'preciosLocalPorSucursal': preciosLocalPorSucursal
          .map((e) => e.toMap())
          .toList(),
    };
  }

  CodigoTelaProveedor copyWith({
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
    String? colorId,
    String? codigoColor,
    PrecioConfig? precioImportacion,
    PrecioConfig? precioLocalGeneral,
    List<PrecioSucursalConfig>? preciosLocalPorSucursal,
  }) {
    return CodigoTelaProveedor(
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
      precioImportacion: precioImportacion ?? this.precioImportacion,
      precioLocalGeneral: precioLocalGeneral ?? this.precioLocalGeneral,
      preciosLocalPorSucursal:
          preciosLocalPorSucursal ?? this.preciosLocalPorSucursal,
    );
  }
}
