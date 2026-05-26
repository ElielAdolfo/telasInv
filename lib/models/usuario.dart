import 'package:inv_telas/models/usuario_empresa_rol.dart';

class Usuario {
  final String id;
  final String email;
  final String nombre;

  // NUEVA ESTRUCTURA: Lista de relaciones Usuario-Empresa-Rol
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
    this.empresas = const [],
    this.activo = true,
    this.eliminado = false,
    this.fechaCreacion,
    this.usuarioCreadorId,
    this.fechaActualizacion,
    this.usuarioModificadorId,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    // Mapeo de la nueva estructura
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
      'empresas': empresas.map((e) => e.toJson()).toList(),
      'activo': activo,
      'eliminado': eliminado,
      'fechaCreacion': fechaCreacion?.toIso8601String(),
      'usuarioCreadorId': usuarioCreadorId,
      'fechaActualizacion': fechaActualizacion?.toIso8601String(),
      'usuarioModificadorId': usuarioModificadorId,
    };
  }
}
