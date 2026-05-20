class MenuApp {
  final String id;
  final String nombre;
  final String icono; // String para mapear en Flutter
  final String ruta;
  final bool activo;
  final int ordenBase;

  MenuApp({
    required this.id,
    required this.nombre,
    required this.icono,
    required this.ruta,
    this.activo = true,
    this.ordenBase = 0,
  });

  factory MenuApp.fromJson(Map<String, dynamic> json) => MenuApp(
    id: json['id'] ?? '',
    nombre: json['nombre'] ?? '',
    icono: json['icono'] ?? 'error',
    ruta: json['ruta'] ?? '/',
    activo: json['activo'] ?? true,
    ordenBase: json['ordenBase'] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'icono': icono,
    'ruta': ruta,
    'activo': activo,
    'ordenBase': ordenBase,
  };
}
