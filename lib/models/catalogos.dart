class Empresa {
  final String id;
  final String nombre;
  final DateTime? fechaCreacion;
  Empresa({required this.id, required this.nombre, this.fechaCreacion});
  factory Empresa.fromJson(Map<String, dynamic> json) => Empresa(
    id: json['id'] ?? '',
    nombre: json['nombre'] ?? '',
    fechaCreacion: json['fechaCreacion'] != null
        ? DateTime.parse(json['fechaCreacion'])
        : null,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'fechaCreacion': fechaCreacion?.toIso8601String(),
  };
}

class Sucursal {
  final String id;
  final String nombre;
  final String color;
  final DateTime? fechaCreacion;
  Sucursal({
    required this.id,
    required this.nombre,
    this.color = '#3b82f6',
    this.fechaCreacion,
  });
  factory Sucursal.fromJson(Map<String, dynamic> json) => Sucursal(
    id: json['id'] ?? '',
    nombre: json['nombre'] ?? '',
    color: json['color'] ?? '#3b82f6',
    fechaCreacion: json['fechaCreacion'] != null
        ? DateTime.parse(json['fechaCreacion'])
        : null,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'color': color,
    'fechaCreacion': fechaCreacion?.toIso8601String(),
  };
}

class ColorTela {
  final String id;
  final String nombre;
  final String hex;
  final DateTime? fechaCreacion;
  ColorTela({
    required this.id,
    required this.nombre,
    this.hex = '#3b82f6',
    this.fechaCreacion,
  });
  factory ColorTela.fromJson(Map<String, dynamic> json) => ColorTela(
    id: json['id'] ?? '',
    nombre: json['nombre'] ?? '',
    hex: json['hex'] ?? '#3b82f6',
    fechaCreacion: json['fechaCreacion'] != null
        ? DateTime.parse(json['fechaCreacion'])
        : null,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'hex': hex,
    'fechaCreacion': fechaCreacion?.toIso8601String(),
  };
}

class TipoTela {
  final String id;
  final String nombre;
  final DateTime? fechaCreacion;
  TipoTela({required this.id, required this.nombre, this.fechaCreacion});
  factory TipoTela.fromJson(Map<String, dynamic> json) => TipoTela(
    id: json['id'] ?? '',
    nombre: json['nombre'] ?? '',
    fechaCreacion: json['fechaCreacion'] != null
        ? DateTime.parse(json['fechaCreacion'])
        : null,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'fechaCreacion': fechaCreacion?.toIso8601String(),
  };
}

class Ancho {
  final String id;
  final String nombre; // Ej: "1.50m", "1.60m"
  final DateTime? fechaCreacion;

  Ancho({required this.id, required this.nombre, this.fechaCreacion});

  factory Ancho.fromJson(Map<String, dynamic> json) => Ancho(
    id: json['id'] ?? '',
    nombre: json['nombre'] ?? '',
    fechaCreacion: json['fechaCreacion'] != null
        ? DateTime.parse(json['fechaCreacion'])
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'fechaCreacion': fechaCreacion?.toIso8601String(),
  };
}


