class Usuario {
  final String id;
  final String email;
  final String nombre;
  final String rol; // ADMIN, VENDEDOR, SUCURSAL, CONSULTAS
  final String? sucursalId; // Solo para Vendedor/Responsable
  final bool activo;

  Usuario({
    required this.id,
    required this.email,
    required this.nombre,
    this.rol = 'VENDEDOR',
    this.sucursalId,
    this.activo = true,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
    id: json['id'] ?? '',
    email: json['email'] ?? '',
    nombre: json['nombre'] ?? '',
    rol: json['rol'] ?? 'VENDEDOR',
    sucursalId: json['sucursalId'],
    activo: json['activo'] ?? true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'nombre': nombre,
    'rol': rol,
    'sucursalId': sucursalId,
    'activo': activo,
  };
}
