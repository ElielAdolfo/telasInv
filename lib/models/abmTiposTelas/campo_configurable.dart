enum TipoCampo { texto, entero, decimal, booleano }

class CampoConfigurable {
  final String id;

  final String empresaId;

  final String nombre;

  final TipoCampo tipo;

  /// Si es true aparecerá automáticamente
  /// al crear variantes.
  final bool requerido;

  final bool activo;
  final bool eliminado;

  final String? usuarioCreadorId;
  final String? usuarioModificadorId;
  final String? usuarioEliminadorId;

  final DateTime? fechaCreacion;
  final DateTime? fechaActualizacion;
  final DateTime? fechaEliminacion;

  const CampoConfigurable({
    required this.id,
    required this.empresaId,
    required this.nombre,
    required this.tipo,
    this.requerido = false,
    this.activo = true,
    this.eliminado = false,
    this.usuarioCreadorId,
    this.usuarioModificadorId,
    this.usuarioEliminadorId,
    this.fechaCreacion,
    this.fechaActualizacion,
    this.fechaEliminacion,
  });

  factory CampoConfigurable.fromJson(Map<String, dynamic> json) {
    return CampoConfigurable(
      id: json['id'] ?? '',
      empresaId: json['empresaId'] ?? '',
      nombre: json['nombre'] ?? '',
      tipo: TipoCampo.values.firstWhere(
        (e) => e.name == json['tipo'],
        orElse: () => TipoCampo.texto,
      ),
      requerido: json['requerido'] ?? false,
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
      'tipo': tipo.name,
      'requerido': requerido,
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
}
