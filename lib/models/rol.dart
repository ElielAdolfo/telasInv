class Rol {
  final String id;
  final String nombre;
  final bool activo;
  final List<String> menusPermitidos;
  final bool eliminado;

  Rol({
    required this.id,
    required this.nombre,
    this.activo = true,
    this.menusPermitidos = const [],
    this.eliminado = false,
  });

  factory Rol.fromJson(Map<String, dynamic> json) => Rol(
    id: json['id'] ?? '',
    nombre: json['nombre'] ?? '',
    activo: json['activo'] ?? true,
    menusPermitidos: json['menusPermitidos'] != null
        ? List<String>.from(json['menusPermitidos'])
        : [],
    eliminado: json['eliminado'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'activo': activo,
    'menusPermitidos': menusPermitidos,
    'eliminado': eliminado,
  };
}
