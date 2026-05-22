class MenuApp {
  final String id;
  final String nombre;
  final String icono; // String para mapear en Flutter
  final String ruta;
  final bool activo;
  final int ordenBase;
  final bool visible;
  final bool eliminado;

  MenuApp({
    required this.id,
    required this.nombre,
    required this.icono,
    required this.ruta,
    this.activo = true,
    this.ordenBase = 0,
    this.visible = true,
    this.eliminado = false,
  });

  factory MenuApp.fromJson(Map<String, dynamic> json) => MenuApp(
    id: json['id'] ?? '',
    nombre: json['nombre'] ?? '',
    icono: json['icono'] ?? 'error',
    ruta: json['ruta'] ?? '/',
    activo: json['activo'] ?? true,
    ordenBase: json['ordenBase'] ?? 0,
    visible: json['visible'] ?? true,
    eliminado: json['eliminado'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'icono': icono,
    'ruta': ruta,
    'activo': activo,
    'ordenBase': ordenBase,
    'visible': visible,
    'eliminado': eliminado,
  };

  MenuApp copyWith({
    String? id,
    String? nombre,
    String? icono,
    String? ruta,
    bool? activo,
    int? ordenBase,
    bool? visible,
    bool? eliminado,
  }) {
    return MenuApp(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      icono: icono ?? this.icono,
      ruta: ruta ?? this.ruta,
      activo: activo ?? this.activo,
      ordenBase: ordenBase ?? this.ordenBase,
      visible: visible ?? this.visible,
      eliminado: eliminado ?? this.eliminado,
    );
  }
}
