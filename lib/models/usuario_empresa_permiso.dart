class UsuarioEmpresaPermiso {
  final String usuarioId;

  /// Roles SOLO para esta empresa
  final List<String> rolesIds;

  /// Puede administrar empresa
  final bool esPrincipal;

  /// Puede vender
  final bool puedeVender;

  /// Puede consultar
  final bool puedeConsultar;

  const UsuarioEmpresaPermiso({
    required this.usuarioId,
    this.rolesIds = const [],
    this.esPrincipal = false,
    this.puedeVender = false,
    this.puedeConsultar = true,
  });

  factory UsuarioEmpresaPermiso.fromJson(Map<String, dynamic> json) {
    return UsuarioEmpresaPermiso(
      usuarioId: json['usuarioId'] ?? '',
      rolesIds: List<String>.from(json['rolesIds'] ?? []),
      esPrincipal: json['esPrincipal'] ?? false,
      puedeVender: json['puedeVender'] ?? false,
      puedeConsultar: json['puedeConsultar'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usuarioId': usuarioId,
      'rolesIds': rolesIds,
      'esPrincipal': esPrincipal,
      'puedeVender': puedeVender,
      'puedeConsultar': puedeConsultar,
    };
  }
}
