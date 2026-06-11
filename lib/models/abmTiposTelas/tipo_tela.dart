import 'campo_configurable.dart';
import 'tipo_tela_variante.dart';

class TipoTela {
  final String id;

  final String empresaId;

  final String nombre;

  /// Campos que aplican a este tipo de tela
  final List<CampoConfigurable> camposConfigurables;

  /// Variantes proveedor/precio/etc.
  final List<TipoTelaVariante> variantes;

  final bool activo;
  final bool eliminado;

  final String? usuarioCreadorId;
  final String? usuarioModificadorId;
  final String? usuarioEliminadorId;

  final DateTime? fechaCreacion;
  final DateTime? fechaActualizacion;
  final DateTime? fechaEliminacion;

  const TipoTela({
    required this.id,
    required this.empresaId,
    required this.nombre,
    this.camposConfigurables = const [],
    this.variantes = const [],
    this.activo = true,
    this.eliminado = false,
    this.usuarioCreadorId,
    this.usuarioModificadorId,
    this.usuarioEliminadorId,
    this.fechaCreacion,
    this.fechaActualizacion,
    this.fechaEliminacion,
  });

  factory TipoTela.fromJson(Map<String, dynamic> json) {
    return TipoTela(
      id: json['id'] ?? '',
      empresaId: json['empresaId'] ?? '',
      nombre: json['nombre'] ?? '',

      camposConfigurables: json['camposConfigurables'] != null
          ? (json['camposConfigurables'] as List)
                .map(
                  (e) =>
                      CampoConfigurable.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : [],

      variantes: json['variantes'] != null
          ? (json['variantes'] as List)
                .map(
                  (e) =>
                      TipoTelaVariante.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : [],

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
      'nombreNormalizado': nombre.trim().toLowerCase(),

      'camposConfigurables': camposConfigurables
          .map((e) => e.toJson())
          .toList(),

      'variantes': variantes.map((e) => e.toJson()).toList(),

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

  TipoTela copyWith({
    String? id,
    String? empresaId,
    String? nombre,
    List<CampoConfigurable>? camposConfigurables,
    List<TipoTelaVariante>? variantes,
    bool? activo,
    bool? eliminado,
    String? usuarioCreadorId,
    String? usuarioModificadorId,
    String? usuarioEliminadorId,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
    DateTime? fechaEliminacion,
  }) {
    return TipoTela(
      id: id ?? this.id,
      empresaId: empresaId ?? this.empresaId,
      nombre: nombre ?? this.nombre,

      camposConfigurables: camposConfigurables ?? this.camposConfigurables,

      variantes: variantes ?? this.variantes,

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
