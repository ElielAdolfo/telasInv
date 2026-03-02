import 'dart:convert';

class TipoTelaModel {
  final String id;
  final String nombre;
  final DateTime fechaCreacion;

  TipoTelaModel({
    required this.id,
    required this.nombre,
    DateTime? fechaCreacion,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now();

  TipoTelaModel copyWith({String? id, String? nombre, DateTime? fechaCreacion}) {
    return TipoTelaModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }

  factory TipoTelaModel.fromMap(Map<String, dynamic> map) {
    return TipoTelaModel(
      id: map['id'] ?? '',
      nombre: map['nombre'] ?? '',
      fechaCreacion: map['fechaCreacion'] != null
          ? DateTime.parse(map['fechaCreacion'])
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());
  factory TipoTelaModel.fromJson(String source) => TipoTelaModel.fromMap(json.decode(source));

  static String generarId() => 'tip_${DateTime.now().millisecondsSinceEpoch}';

  @override
  String toString() => 'TipoTelaModel(id: $id, nombre: $nombre)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TipoTelaModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
