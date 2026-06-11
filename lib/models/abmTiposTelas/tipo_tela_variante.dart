import 'campo_valor.dart';

class TipoTelaVariante {
  final String id;

  final String proveedor;

  final double precioCompra;

  final String monedaId;

  final List<CampoValor> campos;

  final bool activo;
  final bool eliminado;

  final String? usuarioCreadorId;
  final String? usuarioModificadorId;
  final String? usuarioEliminadorId;

  final DateTime? fechaCreacion;
  final DateTime? fechaActualizacion;
  final DateTime? fechaEliminacion;

  const TipoTelaVariante({
    required this.id,
    required this.proveedor,
    required this.precioCompra,
    required this.monedaId,
    this.campos = const [],
    this.activo = true,
    this.eliminado = false,
    this.usuarioCreadorId,
    this.usuarioModificadorId,
    this.usuarioEliminadorId,
    this.fechaCreacion,
    this.fechaActualizacion,
    this.fechaEliminacion,
  });

  factory TipoTelaVariante.fromJson(Map<String, dynamic> json) {
    return TipoTelaVariante(
      id: json['id'] ?? '',
      proveedor: json['proveedor'] ?? '',
      precioCompra: (json['precioCompra'] ?? 0).toDouble(),
      monedaId: json['monedaId'] ?? '',
      campos: json['campos'] != null
          ? (json['campos'] as List)
                .map((e) => CampoValor.fromJson(Map<String, dynamic>.from(e)))
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
      'proveedor': proveedor,
      'precioCompra': precioCompra,
      'monedaId': monedaId,
      'campos': campos.map((e) => e.toJson()).toList(),
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
