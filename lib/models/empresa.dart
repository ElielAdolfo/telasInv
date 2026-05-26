import 'package:cloud_firestore/cloud_firestore.dart';

class Empresa {
  final String id;
  final String nombre;
  final String? nit; // Opcional: Identificación fiscal
  final bool activo;

  // Eliminación lógica
  final bool eliminado;
  final DateTime? fechaEliminacion;
  final String? usuarioEliminadorId;

  // Auditoría
  final DateTime? fechaCreacion;
  final String? usuarioCreadorId; // Quién creó la empresa
  final DateTime? fechaActualizacion;
  final String? usuarioModificadorId;

  Empresa({
    required this.id,
    required this.nombre,
    this.nit,
    this.activo = true,
    this.eliminado = false,
    this.fechaEliminacion,
    this.usuarioEliminadorId,
    this.fechaCreacion,
    this.usuarioCreadorId,
    this.fechaActualizacion,
    this.usuarioModificadorId,
  });

  factory Empresa.fromJson(Map<String, dynamic> json) => Empresa(
    id: json['id'] ?? '',
    nombre: json['nombre'] ?? '',
    nit: json['nit'],
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
    'nit': nit,
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
