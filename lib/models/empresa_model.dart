import 'dart:convert';

class EmpresaModel {
  final String id;
  final String nombre;
  final DateTime fechaCreacion;

  EmpresaModel({
    required this.id,
    required this.nombre,
    DateTime? fechaCreacion,
  }) : fechaCreacion = fechaCreacion ?? DateTime.now();

  EmpresaModel copyWith({String? id, String? nombre, DateTime? fechaCreacion}) {
    return EmpresaModel(
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

  factory EmpresaModel.fromMap(Map<String, dynamic> map) {
    return EmpresaModel(
      id: map['id'] ?? '',
      nombre: map['nombre'] ?? '',
      fechaCreacion: map['fechaCreacion'] != null
          ? DateTime.parse(map['fechaCreacion'])
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());
  factory EmpresaModel.fromJson(String source) => EmpresaModel.fromMap(json.decode(source));

  static String generarId() => 'emp_${DateTime.now().millisecondsSinceEpoch}';

  @override
  String toString() => 'EmpresaModel(id: $id, nombre: $nombre)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EmpresaModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
