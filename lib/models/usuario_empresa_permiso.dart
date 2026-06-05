import 'usuario_sucursal_rol.dart';

class UsuarioEmpresaPermiso {
  final String usuarioId;

  /// Sucursales y roles asignados dentro de cada sucursal
  final List<UsuarioSucursalRol> sucursales;

  /// Administrador principal de la empresa
  final bool esPrincipal;

  /// Puede realizar ventas
  final bool puedeVender;

  /// Puede consultar información
  final bool puedeConsultar;

  /// Auditoría
  final bool activo;
  final bool eliminado;

  final String? usuarioCreadorId;
  final String? usuarioModificadorId;
  final String? usuarioEliminadorId;

  final DateTime? fechaCreacion;
  final DateTime? fechaActualizacion;
  final DateTime? fechaEliminacion;

  const UsuarioEmpresaPermiso({
    required this.usuarioId,
    this.sucursales = const [],
    this.esPrincipal = false,
    this.puedeVender = false,
    this.puedeConsultar = true,
    this.activo = true,
    this.eliminado = false,
    this.usuarioCreadorId,
    this.usuarioModificadorId,
    this.usuarioEliminadorId,
    this.fechaCreacion,
    this.fechaActualizacion,
    this.fechaEliminacion,
  });

  factory UsuarioEmpresaPermiso.fromJson(Map<String, dynamic> json) {
    return UsuarioEmpresaPermiso(
      usuarioId: json['usuarioId'] ?? '',
      sucursales: json['sucursales'] != null
          ? (json['sucursales'] as List)
                .map(
                  (e) =>
                      UsuarioSucursalRol.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : [],
      esPrincipal: json['esPrincipal'] ?? false,
      puedeVender: json['puedeVender'] ?? false,
      puedeConsultar: json['puedeConsultar'] ?? true,
      activo: json['activo'] ?? true,
      eliminado: json['eliminado'] ?? false,
      usuarioCreadorId: json['usuarioCreadorId'],
      usuarioModificadorId: json['usuarioModificadorId'],
      usuarioEliminadorId: json['usuarioEliminadorId'],
      fechaCreacion: json['fechaCreacion'] != null
          ? DateTime.tryParse(json['fechaCreacion'])
          : null,
      fechaActualizacion: json['fechaActualizacion'] != null
          ? DateTime.tryParse(json['fechaActualizacion'])
          : null,
      fechaEliminacion: json['fechaEliminacion'] != null
          ? DateTime.tryParse(json['fechaEliminacion'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usuarioId': usuarioId,
      'sucursales': sucursales.map((e) => e.toJson()).toList(),
      'esPrincipal': esPrincipal,
      'puedeVender': puedeVender,
      'puedeConsultar': puedeConsultar,
      'activo': activo,
      'eliminado': eliminado,
      'usuarioCreadorId': usuarioCreadorId,
      'usuarioModificadorId': usuarioModificadorId,
      'usuarioEliminadorId': usuarioEliminadorId,
      'fechaCreacion': fechaCreacion?.toIso8601String(),
      'fechaActualizacion': fechaActualizacion?.toIso8601String(),
      'fechaEliminacion': fechaEliminacion?.toIso8601String(),
    };
  }

  UsuarioEmpresaPermiso copyWith({
    String? usuarioId,
    List<UsuarioSucursalRol>? sucursales,
    bool? esPrincipal,
    bool? puedeVender,
    bool? puedeConsultar,
    bool? activo,
    bool? eliminado,
    String? usuarioCreadorId,
    String? usuarioModificadorId,
    String? usuarioEliminadorId,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
    DateTime? fechaEliminacion,
  }) {
    return UsuarioEmpresaPermiso(
      usuarioId: usuarioId ?? this.usuarioId,
      sucursales: sucursales ?? this.sucursales,
      esPrincipal: esPrincipal ?? this.esPrincipal,
      puedeVender: puedeVender ?? this.puedeVender,
      puedeConsultar: puedeConsultar ?? this.puedeConsultar,
      activo: activo ?? this.activo,
      eliminado: eliminado ?? this.eliminado,
      usuarioCreadorId: usuarioCreadorId ?? this.usuarioCreadorId,
      usuarioModificadorId: usuarioModificadorId ?? this.usuarioModificadorId,
      usuarioEliminadorId: usuarioEliminadorId ?? this.usuarioEliminadorId,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
      fechaEliminacion: fechaEliminacion ?? this.fechaEliminacion,
    );
  }
}
