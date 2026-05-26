class UsuarioEmpresaRol {
  final String empresaId;
  final List<String> rolesIds;
  final List<String> sucursalesIds;

  UsuarioEmpresaRol({
    required this.empresaId,
    this.rolesIds = const [],
    this.sucursalesIds = const [],
  });

  factory UsuarioEmpresaRol.fromJson(Map<String, dynamic> json) {
    return UsuarioEmpresaRol(
      empresaId: json['empresaId'] ?? '',
      rolesIds: json['rolesIds'] != null
          ? List<String>.from(json['rolesIds'])
          : (json['rolId'] != null
                ? [
                    json['rolId'],
                  ] // Migración: si existe el campo antiguo, lo pasamos a lista
                : []),
      sucursalesIds: json['sucursalesIds'] != null
          ? List<String>.from(json['sucursalesIds'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'empresaId': empresaId,
      'empresaId': empresaId,
      'rolesIds': rolesIds,
      'sucursalesIds': sucursalesIds,
    };
  }
}
