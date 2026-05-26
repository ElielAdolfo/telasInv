import 'package:cloud_firestore/cloud_firestore.dart';

class MenuApp {
  final String id;
  final String nombre;
  final String icono; // String para mapear en Flutter
  final String ruta;
  final bool activo;
  final int ordenBase;
  final bool visible;

  // Eliminación lógica
  final bool eliminado;
  final DateTime? fechaEliminacion;
  final String? usuarioEliminadorId;

  // Auditoría
  final DateTime? fechaCreacion;
  final String? usuarioCreadorId;
  final DateTime? fechaActualizacion;
  final String? usuarioModificadorId;

  MenuApp({
    required this.id,
    required this.nombre,
    required this.icono,
    required this.ruta,
    this.activo = true,
    this.ordenBase = 0,
    this.visible = true,
    this.eliminado = false,
    this.fechaEliminacion,
    this.usuarioEliminadorId,
    this.fechaCreacion,
    this.usuarioCreadorId,
    this.fechaActualizacion,
    this.usuarioModificadorId,
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
    'icono': icono,
    'ruta': ruta,
    'activo': activo,
    'ordenBase': ordenBase,
    'visible': visible,
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

  MenuApp copyWith({
    String? id,
    String? nombre,
    String? icono,
    String? ruta,
    bool? activo,
    int? ordenBase,
    bool? visible,
    bool? eliminado,
    DateTime? fechaEliminacion,
    String? usuarioEliminadorId,
    DateTime? fechaCreacion,
    String? usuarioCreadorId,
    DateTime? fechaActualizacion,
    String? usuarioModificadorId,
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
      fechaEliminacion: fechaEliminacion ?? this.fechaEliminacion,
      usuarioEliminadorId: usuarioEliminadorId ?? this.usuarioEliminadorId,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      usuarioCreadorId: usuarioCreadorId ?? this.usuarioCreadorId,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
      usuarioModificadorId: usuarioModificadorId ?? this.usuarioModificadorId,
    );
  }
}
