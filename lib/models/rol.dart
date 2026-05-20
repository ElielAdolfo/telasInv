class Rol {
  final String id;
  final String nombre;
  final bool activo;
  final List<String> menusPermitidos;

  Rol({
    required this.id,
    required this.nombre,
    this.activo = true,
    this.menusPermitidos = const [],
  });

  factory Rol.fromJson(Map<String, dynamic> json) => Rol(
    id: json['id'] ?? '',
    nombre: json['nombre'] ?? '',
    activo: json['activo'] ?? true,
    menusPermitidos: json['menusPermitidos'] != null
        ? List<String>.from(json['menusPermitidos'])
        : [],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'activo': activo,
    'menusPermitidos': menusPermitidos,
  };
}
