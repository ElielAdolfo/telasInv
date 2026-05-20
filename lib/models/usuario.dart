class Usuario {
  final String id;
  final String email;
  final String nombre;

  // CAMBIO: De String a List<String> para multi-rol
  final List<String> rolesIds;

  // CAMBIO: De String? a List<String> para multi-sucursal
  final List<String> sucursalesIds;

  final bool activo;

  // Nuevo: Orden personalizado del menú
  final List<MenuItemPersonalizado> menuPersonalizado;

  Usuario({
    required this.id,
    required this.email,
    required this.nombre,
    this.rolesIds = const [],
    this.sucursalesIds = const [],
    this.activo = true,
    this.menuPersonalizado = const [],
  });

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
    id: json['id'] ?? '',
    email: json['email'] ?? '',
    nombre: json['nombre'] ?? '',
    // Compatibilidad hacia atrás: si existe 'rol' antiguo, lo migra, si no, lee la lista
    rolesIds: json['rolesIds'] != null
        ? List<String>.from(json['rolesIds'])
        : (json['rol'] != null ? [json['rol']] : []),
    sucursalesIds: json['sucursalesIds'] != null
        ? List<String>.from(json['sucursalesIds'])
        : (json['sucursalId'] != null ? [json['sucursalId']] : []),
    activo: json['activo'] ?? true,
    menuPersonalizado: json['menuPersonalizado'] != null
        ? (json['menuPersonalizado'] as List)
              .map((e) => MenuItemPersonalizado.fromJson(e))
              .toList()
        : [],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'nombre': nombre,
    'rolesIds': rolesIds,
    'sucursalesIds': sucursalesIds,
    'activo': activo,
    'menuPersonalizado': menuPersonalizado.map((e) => e.toJson()).toList(),
  };
}

// Modelo auxiliar para el orden del menú
class MenuItemPersonalizado {
  final String menuId;
  final int orden;
  final bool favorito;

  MenuItemPersonalizado({
    required this.menuId,
    required this.orden,
    this.favorito = false,
  });

  factory MenuItemPersonalizado.fromJson(Map<String, dynamic> json) =>
      MenuItemPersonalizado(
        menuId: json['menuId'] ?? '',
        orden: json['orden'] ?? 0,
        favorito: json['favorito'] ?? false,
      );

  Map<String, dynamic> toJson() => {
    'menuId': menuId,
    'orden': orden,
    'favorito': favorito,
  };
}
