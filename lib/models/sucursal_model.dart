import 'dart:convert';

class SucursalModel {
  final String id;
  final String nombre;
  final String color;
  final DateTime fechaCreacion;

  SucursalModel({
    required this.id,
    required this.nombre,
    this.color = '#3b82f6',
    DateTime? fechaCreacion,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now();

  SucursalModel copyWith({String? id, String? nombre, String? color, DateTime? fechaCreacion}) {
    return SucursalModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      color: color ?? this.color,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'color': color,
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }

  factory SucursalModel.fromMap(Map<String, dynamic> map) {
    return SucursalModel(
      id: map['id'] ?? '',
      nombre: map['nombre'] ?? '',
      color: map['color'] ?? '#3b82f6',
      fechaCreacion: map['fechaCreacion'] != null
          ? DateTime.parse(map['fechaCreacion'])
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());
  factory SucursalModel.fromJson(String source) => SucursalModel.fromMap(json.decode(source));

  static String generarId() => 'suc_${DateTime.now().millisecondsSinceEpoch}';

  int get colorValue {
    try {
      String hexColor = color.replaceAll('#', '');
      if (hexColor.length == 6) hexColor = 'FF$hexColor';
      return int.parse(hexColor, radix: 16);
    } catch (e) {
      return 0xFF3B82F6;
    }
  }

  @override
  String toString() => 'SucursalModel(id: $id, nombre: $nombre, color: $color)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SucursalModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
