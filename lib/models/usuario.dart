import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inv_telas/models/usuario_empresa_rol.dart';

class Usuario {
  final String id;
  final String email;
  final String nombre;

  /// NUEVO
  final bool esSuperAdmin;

  final List<UsuarioEmpresaRol> empresas;

  final bool activo;
  final bool eliminado;

  final DateTime? fechaCreacion;
  final String? usuarioCreadorId;
  final DateTime? fechaActualizacion;
  final String? usuarioModificadorId;

  Usuario({
    required this.id,
    required this.email,
    required this.nombre,

    this.esSuperAdmin = false,

    this.empresas = const [],
    this.activo = true,
    this.eliminado = false,
    this.fechaCreacion,
    this.usuarioCreadorId,
    this.fechaActualizacion,
    this.usuarioModificadorId,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    List<UsuarioEmpresaRol> empresasList = [];

    if (json['empresas'] != null) {
      empresasList = (json['empresas'] as List)
          .map((e) => UsuarioEmpresaRol.fromJson(e))
          .toList();
    }

    return Usuario(
      id: json['id'] ?? json['uid'] ?? '',
      email: json['email'] ?? json['correo'] ?? '',
      nombre: json['nombre'] ?? '',

      /// NUEVO
      esSuperAdmin: json['esSuperAdmin'] ?? false,

      empresas: empresasList,
      activo: json['activo'] ?? true,
      eliminado: json['eliminado'] ?? false,
      fechaCreacion: _parseDate(json['fechaCreacion'] ?? json['createdAt']),
      usuarioCreadorId: json['usuarioCreadorId'],
      fechaActualizacion: _parseDate(
        json['fechaActualizacion'] ?? json['updatedAt'],
      ),
      usuarioModificadorId: json['usuarioModificadorId'],
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;

    if (value is DateTime) return value;

    if (value is Timestamp) {
      return value.toDate();
    }

    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nombre': nombre,

      /// NUEVO
      'esSuperAdmin': esSuperAdmin,

      'empresas': empresas.map((e) => e.toJson()).toList(),
      'activo': activo,
      'eliminado': eliminado,
      'fechaCreacion': fechaCreacion?.toIso8601String(),
      'usuarioCreadorId': usuarioCreadorId,
      'fechaActualizacion': fechaActualizacion?.toIso8601String(),
      'usuarioModificadorId': usuarioModificadorId,
    };
  }

  Usuario copyWith({
    String? id,
    String? email,
    String? nombre,
    bool? esSuperAdmin,
    List<UsuarioEmpresaRol>? empresas,
    bool? activo,
    bool? eliminado,
    DateTime? fechaCreacion,
    String? usuarioCreadorId,
    DateTime? fechaActualizacion,
    String? usuarioModificadorId,
  }) {
    return Usuario(
      id: id ?? this.id,
      email: email ?? this.email,
      nombre: nombre ?? this.nombre,
      esSuperAdmin: esSuperAdmin ?? this.esSuperAdmin,
      empresas: empresas ?? this.empresas,
      activo: activo ?? this.activo,
      eliminado: eliminado ?? this.eliminado,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      usuarioCreadorId: usuarioCreadorId ?? this.usuarioCreadorId,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
      usuarioModificadorId: usuarioModificadorId ?? this.usuarioModificadorId,
    );
  }
}
