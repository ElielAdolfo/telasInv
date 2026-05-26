import 'package:cloud_firestore/cloud_firestore.dart';

class Sucursal {
  final String id;
  final String nombre;
  final String empresaId; // Relación: A qué empresa pertenece
  final String? direccion;
  final String? telefono;
  final bool activo;

  // Eliminación lógica
  final bool eliminado;
  final DateTime? fechaEliminacion;
  final String? usuarioEliminadorId;

  // Auditoría
  final DateTime? fechaCreacion;
  final String? usuarioCreadorId;
  final DateTime? fechaActualizacion;
  final String? usuarioModificadorId;

  Sucursal({
    required this.id,
    required this.nombre,
    required this.empresaId,
    this.direccion,
    this.telefono,
    this.activo = true,
    this.eliminado = false,
    this.fechaEliminacion,
    this.usuarioEliminadorId,
    this.fechaCreacion,
    this.usuarioCreadorId,
    this.fechaActualizacion,
    this.usuarioModificadorId,
  });

  factory Sucursal.fromJson(Map<String, dynamic> json) => Sucursal(
    id: json['id'] ?? '',
    nombre: json['nombre'] ?? '',
    empresaId: json['empresaId'] ?? '',
    direccion: json['direccion'],
    telefono: json['telefono'],
    activo: json['activo'] ?? true,
    eliminado: json['eliminado'] ?? false,
    fechaEliminacion: json['fechaEliminacion'] != null
        ? (json['fechaEliminacion'] as Timestamp).toDate()
        : null,
    usuarioEliminadorId: json['usuarioEliminadorId'],
    fechaCreacion: json['fechaCreacion'] != null
        ? (json['fechaCreacion'] as Timestamp).toDate()
        : null,
    usuarioCreadorId: json['usuarioCreadorId'],
    fechaActualizacion: json['fechaActualizacion'] != null
        ? (json['fechaActualizacion'] as Timestamp).toDate()
        : null,
    usuarioModificadorId: json['usuarioModificadorId'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'empresaId': empresaId,
    'direccion': direccion,
    'telefono': telefono,
    'activo': activo,
    'eliminado': eliminado,
    'fechaEliminacion': fechaEliminacion != null
        ? Timestamp.fromDate(fechaEliminacion!)
        : null,
    'usuarioEliminadorId': usuarioEliminadorId,
    'fechaCreacion': fechaCreacion != null
        ? Timestamp.fromDate(fechaCreacion!)
        : null,
    'usuarioCreadorId': usuarioCreadorId,
    'fechaActualizacion': fechaActualizacion != null
        ? Timestamp.fromDate(fechaActualizacion!)
        : null,
    'usuarioModificadorId': usuarioModificadorId,
  };
}
