// archivo: models/proveedor.dart

class Proveedor {
  final String id;
  final String empresaId;
  final String nombre;

  // Campos de estado
  final bool activo;
  final bool eliminado;

  // Campos de auditoría (Usuarios)
  final String? usuarioCreadorId;
  final String? usuarioModificadorId;
  final String? usuarioEliminadorId;

  // Campos de auditoría (Fechas)
  final DateTime? fechaCreacion;
  final DateTime? fechaActualizacion;
  final DateTime? fechaEliminacion;

  const Proveedor({
    required this.id,
    required this.empresaId,
    required this.nombre,
    this.activo = true,
    this.eliminado = false,
    this.usuarioCreadorId,
    this.usuarioModificadorId,
    this.usuarioEliminadorId,
    this.fechaCreacion,
    this.fechaActualizacion,
    this.fechaEliminacion,
  });

  factory Proveedor.fromJson(Map<String, dynamic> json) {
    return Proveedor(
      id: json['id'] ?? '',
      empresaId: json['empresaId'] ?? '',
      nombre: json['nombre'] ?? 'Sin Nombre',
      activo: json['activo'] ?? true,
      eliminado: json['eliminado'] ?? false,
      usuarioCreadorId: json['usuarioCreadorId'],
      usuarioModificadorId: json['usuarioModificadorId'],
      usuarioEliminadorId: json['usuarioEliminadorId'],
      fechaCreacion: json['fechaCreacion'] != null
          ? DateTime.tryParse(json['fechaCreacion'])
          : null,
      fechaActualizacion: json['fechaActualizacion'] != null
          ? DateTime.tryParse(json['fechaActualizacion'])
          : null,
      fechaEliminacion: json['fechaEliminacion'] != null
          ? DateTime.tryParse(json['fechaEliminacion'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'empresaId': empresaId,
      'nombre': nombre,
      'activo': activo,
      'eliminado': eliminado,
      'usuarioCreadorId': usuarioCreadorId,
      'usuarioModificadorId': usuarioModificadorId,
      'usuarioEliminadorId': usuarioEliminadorId,
      'fechaCreacion': fechaCreacion?.toIso8601String(),
      'fechaActualizacion': fechaActualizacion?.toIso8601String(),
      'fechaEliminacion': fechaEliminacion?.toIso8601String(),
    };
  }

  // Método copyWith útil para actualizar el estado del modelo de forma inmutable
  Proveedor copyWith({
    String? id,
    String? empresaId,
    String? nombre,
    bool? activo,
    bool? eliminado,
    String? usuarioCreadorId,
    String? usuarioModificadorId,
    String? usuarioEliminadorId,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
    DateTime? fechaEliminacion,
  }) {
    return Proveedor(
      id: id ?? this.id,
      empresaId: empresaId ?? this.empresaId,
      nombre: nombre ?? this.nombre,
      activo: activo ?? this.activo,
      eliminado: eliminado ?? this.eliminado,
      usuarioCreadorId: usuarioCreadorId ?? this.usuarioCreadorId,
      usuarioModificadorId: usuarioModificadorId ?? this.usuarioModificadorId,
      usuarioEliminadorId: usuarioEliminadorId ?? this.usuarioEliminadorId,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
      fechaEliminacion: fechaEliminacion ?? this.fechaEliminacion,
    );
  }
}
