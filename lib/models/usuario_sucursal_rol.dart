class UsuarioSucursalRol {
  final String sucursalId;

  final List<String> rolesIds;

  final bool activo;
  final bool eliminado;

  final String? usuarioCreadorId;
  final String? usuarioModificadorId;
  final String? usuarioEliminadorId;

  final DateTime? fechaCreacion;
  final DateTime? fechaActualizacion;
  final DateTime? fechaEliminacion;

  const UsuarioSucursalRol({
    required this.sucursalId,
    this.rolesIds = const [],
    this.activo = true,
    this.eliminado = false,
    this.usuarioCreadorId,
    this.usuarioModificadorId,
    this.usuarioEliminadorId,
    this.fechaCreacion,
    this.fechaActualizacion,
    this.fechaEliminacion,
  });

  factory UsuarioSucursalRol.fromJson(Map<String, dynamic> json) {
    return UsuarioSucursalRol(
      sucursalId: json['sucursalId'] ?? '',
      rolesIds: json['rolesIds'] != null
          ? List<String>.from(json['rolesIds'])
          : [],
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
      'sucursalId': sucursalId,
      'rolesIds': rolesIds,
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

  UsuarioSucursalRol copyWith({
    String? sucursalId,
    List<String>? rolesIds,
    bool? activo,
    bool? eliminado,
    String? usuarioCreadorId,
    String? usuarioModificadorId,
    String? usuarioEliminadorId,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
    DateTime? fechaEliminacion,
  }) {
    return UsuarioSucursalRol(
      sucursalId: sucursalId ?? this.sucursalId,
      rolesIds: rolesIds ?? this.rolesIds,
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
