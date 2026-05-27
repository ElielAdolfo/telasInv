import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:inv_telas/models/usuario_empresa_permiso.dart';

class Empresa {
  final String id;
  final String nombre;
  final String? nit;
  final bool activo;

  /// Usuarios permitidos en esta empresa
  /// Cada usuario tiene roles SOLO para esta empresa
  final List<UsuarioEmpresaPermiso> usuariosPermitidos;

  /// Eliminación lógica
  final bool eliminado;
  final DateTime? fechaEliminacion;
  final String? usuarioEliminadorId;

  /// Auditoría
  final DateTime? fechaCreacion;
  final String? usuarioCreadorId;
  final DateTime? fechaActualizacion;
  final String? usuarioModificadorId;

  const Empresa({
    required this.id,
    required this.nombre,
    this.nit,
    this.activo = true,
    this.usuariosPermitidos = const [],
    this.eliminado = false,
    this.fechaEliminacion,
    this.usuarioEliminadorId,
    this.fechaCreacion,
    this.usuarioCreadorId,
    this.fechaActualizacion,
    this.usuarioModificadorId,
  });

  /// Constructor vacío
  factory Empresa.empty() {
    return const Empresa(
      id: '',
      nombre: '',
      activo: true,
      usuariosPermitidos: [],
      eliminado: false,
    );
  }

  /// Desde JSON / Firestore
  factory Empresa.fromJson(Map<String, dynamic> json) {
    return Empresa(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      nit: json['nit'],
      activo: json['activo'] ?? true,

      usuariosPermitidos:
          (json['usuariosPermitidos'] as List<dynamic>?)
              ?.map(
                (e) => UsuarioEmpresaPermiso.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList() ??
          [],

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
  }

  /// Desde Firestore DocumentSnapshot
  factory Empresa.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();

    if (data == null) {
      return Empresa.empty();
    }

    return Empresa.fromJson({...data, 'id': doc.id});
  }

  /// A JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'nit': nit,
      'activo': activo,

      'usuariosPermitidos': usuariosPermitidos.map((e) => e.toJson()).toList(),

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

  /// Para Firestore (sin guardar ID dentro del documento)
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    return json;
  }

  /// CopyWith
  Empresa copyWith({
    String? id,
    String? nombre,
    String? nit,
    bool? activo,
    List<UsuarioEmpresaPermiso>? usuariosPermitidos,
    bool? eliminado,
    DateTime? fechaEliminacion,
    String? usuarioEliminadorId,
    DateTime? fechaCreacion,
    String? usuarioCreadorId,
    DateTime? fechaActualizacion,
    String? usuarioModificadorId,
  }) {
    return Empresa(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      nit: nit ?? this.nit,
      activo: activo ?? this.activo,
      usuariosPermitidos: usuariosPermitidos ?? this.usuariosPermitidos,
      eliminado: eliminado ?? this.eliminado,
      fechaEliminacion: fechaEliminacion ?? this.fechaEliminacion,
      usuarioEliminadorId: usuarioEliminadorId ?? this.usuarioEliminadorId,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      usuarioCreadorId: usuarioCreadorId ?? this.usuarioCreadorId,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
      usuarioModificadorId: usuarioModificadorId ?? this.usuarioModificadorId,
    );
  }

  @override
  String toString() {
    return '''
Empresa(
  id: $id,
  nombre: $nombre,
  nit: $nit,
  activo: $activo,
  usuariosPermitidos: ${usuariosPermitidos.length},
  eliminado: $eliminado
)
''';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Empresa &&
        other.id == id &&
        other.nombre == nombre &&
        other.nit == nit &&
        other.activo == activo &&
        listEquals(other.usuariosPermitidos, usuariosPermitidos) &&
        other.eliminado == eliminado &&
        other.fechaEliminacion == fechaEliminacion &&
        other.usuarioEliminadorId == usuarioEliminadorId &&
        other.fechaCreacion == fechaCreacion &&
        other.usuarioCreadorId == usuarioCreadorId &&
        other.fechaActualizacion == fechaActualizacion &&
        other.usuarioModificadorId == usuarioModificadorId;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      nombre,
      nit,
      activo,
      Object.hashAll(usuariosPermitidos),
      eliminado,
      fechaEliminacion,
      usuarioEliminadorId,
      fechaCreacion,
      usuarioCreadorId,
      fechaActualizacion,
      usuarioModificadorId,
    );
  }
}
