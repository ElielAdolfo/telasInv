class Rollo {
  final String id;
  final String? sucursalId;
  final String empresaId;
  final String colorId;
  final String codigoColor;
  final String tipoTelaId;
  final double metraje;
  final String? fecha;
  final String? notas;
  final DateTime fechaCreacion;
  final List<HistorialMovimiento> historial;

  final String? anchoId; // ID del catálogo de anchos
  final String? lote;
  final String? numeroRollo;
  
  final String? loteId;
  final double? precioUsd; // Precio en dólares (histórico)
  final double? tipoCambio; // Tipo de cambio (histórico)
  final double? precioCompra; // Precio final en Bolivianos (calculado)

  Rollo({
    required this.id,
    this.sucursalId,
    required this.empresaId,
    required this.colorId,
    required this.codigoColor,
    this.tipoTelaId = '',
    required this.metraje,
    this.fecha,
    this.notas,
    required this.fechaCreacion,
    this.historial = const [],
    this.anchoId,
    this.lote,
    this.numeroRollo,
    this.loteId,
    this.precioUsd,
    this.tipoCambio,
    this.precioCompra,
  });

  factory Rollo.fromJson(Map<String, dynamic> json) => Rollo(
    id: json['id'] ?? '',
    sucursalId: json['sucursalId'],
    empresaId: json['empresaId'] ?? '',
    colorId: json['colorId'] ?? '',
    codigoColor: json['codigoColor'] ?? '',
    tipoTelaId: json['tipoTelaId'] ?? '',
    metraje: (json['metraje'] ?? 0).toDouble(),
    fecha: json['fecha'],
    notas: json['notas'],
    fechaCreacion: json['fechaCreacion'] != null
        ? DateTime.parse(json['fechaCreacion'])
        : DateTime.now(),
    historial: json['historial'] != null
        ? (json['historial'] as List)
              .map((e) => HistorialMovimiento.fromJson(e))
              .toList()
        : [],
    anchoId: json['anchoId'],
    lote: json['lote'],
    numeroRollo: json['numeroRollo'],
    loteId: json['loteId'],
    precioUsd: (json['precioUsd'] as num?)?.toDouble(),
    tipoCambio: (json['tipoCambio'] as num?)?.toDouble(),
    precioCompra: (json['precioCompra'] as num?)?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'sucursalId': sucursalId,
    'empresaId': empresaId,
    'colorId': colorId,
    'codigoColor': codigoColor,
    'tipoTelaId': tipoTelaId,
    'metraje': metraje,
    'fecha': fecha,
    'notas': notas,
    'fechaCreacion': fechaCreacion.toIso8601String(),
    'historial': historial.map((e) => e.toJson()).toList(),
    'anchoId': anchoId,
    'lote': lote,
    'numeroRollo': numeroRollo,
    'loteId': loteId,
    'precioUsd': precioUsd,
    'tipoCambio': tipoCambio,
    'precioCompra': precioCompra,
  };
}

class HistorialMovimiento {
  final String tipo;
  final String sucursalOrigenId;
  final String sucursalDestinoId;
  final DateTime fecha;

  HistorialMovimiento({
    required this.tipo,
    required this.sucursalOrigenId,
    required this.sucursalDestinoId,
    required this.fecha,
  });

  factory HistorialMovimiento.fromJson(Map<String, dynamic> json) =>
      HistorialMovimiento(
        tipo: json['tipo'] ?? '',
        sucursalOrigenId: json['sucursalOrigenId'] ?? '',
        sucursalDestinoId: json['sucursalDestinoId'] ?? '',
        fecha: json['fecha'] != null
            ? DateTime.parse(json['fecha'])
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
    'tipo': tipo,
    'sucursalOrigenId': sucursalOrigenId,
    'sucursalDestinoId': sucursalDestinoId,
    'fecha': fecha.toIso8601String(),
  };
}
