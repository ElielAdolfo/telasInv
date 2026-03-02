import 'dart:convert';

class ColorTelaModel {
  final String id;
  final String nombre;
  final String hex;
  final DateTime fechaCreacion;

  ColorTelaModel({
    required this.id,
    required this.nombre,
    this.hex = '#94a3b8',
    DateTime? fechaCreacion,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now();

  ColorTelaModel copyWith({String? id, String? nombre, String? hex, DateTime? fechaCreacion}) {
    return ColorTelaModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      hex: hex ?? this.hex,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'hex': hex,
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }

  factory ColorTelaModel.fromMap(Map<String, dynamic> map) {
    return ColorTelaModel(
      id: map['id'] ?? '',
      nombre: map['nombre'] ?? '',
      hex: map['hex'] ?? '#94a3b8',
      fechaCreacion: map['fechaCreacion'] != null
          ? DateTime.parse(map['fechaCreacion'])
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());
  factory ColorTelaModel.fromJson(String source) => ColorTelaModel.fromMap(json.decode(source));

  static String generarId() => 'col_${DateTime.now().millisecondsSinceEpoch}';

  int get colorValue {
    try {
      String hexColor = hex.replaceAll('#', '');
      if (hexColor.length == 6) hexColor = 'FF$hexColor';
      return int.parse(hexColor, radix: 16);
    } catch (e) {
      return 0xFF94A3B8;
    }
  }

  @override
  String toString() => 'ColorTelaModel(id: $id, nombre: $nombre, hex: $hex)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ColorTelaModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
