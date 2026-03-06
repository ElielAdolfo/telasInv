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
  final List<HistorialMovimiento>
  historial; // <--- CORREGIDO: Quitar el "?" para que no sea nullable

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
    this.historial = const [], // <--- CORREGIDO: Valor por defecto lista vacía
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
        : [], // <--- CORREGIDO: Si es null en Firebase, retorna lista vacía
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
    'historial': historial
        .map((e) => e.toJson())
        .toList(), // <--- CORREGIDO: Ya no necesita "?"
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
