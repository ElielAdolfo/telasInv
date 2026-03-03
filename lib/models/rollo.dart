class Rollo {
  final String id;
  final String? sucursal;
  final String empresa;
  final String color;
  final String codigoColor;
  final String tipoTela;
  final double metraje;
  final String? fecha;
  final String? notas;
  final DateTime fechaCreacion;
  final List<HistorialMovimiento>? historial;

  Rollo({required this.id, this.sucursal, required this.empresa, required this.color, required this.codigoColor, this.tipoTela = '', required this.metraje, this.fecha, this.notas, required this.fechaCreacion, this.historial});

  factory Rollo.fromJson(Map<String, dynamic> json) => Rollo(
    id: json['id'] ?? '', sucursal: json['sucursal'], empresa: json['empresa'] ?? '', color: json['color'] ?? '',
    codigoColor: json['codigoColor'] ?? '', tipoTela: json['tipoTela'] ?? '', metraje: (json['metraje'] ?? 0).toDouble(),
    fecha: json['fecha'], notas: json['notas'], fechaCreacion: json['fechaCreacion'] != null ? DateTime.parse(json['fechaCreacion']) : DateTime.now(),
    historial: json['historial'] != null ? (json['historial'] as List).map((e) => HistorialMovimiento.fromJson(e)).toList() : null,
  );

  Map<String, dynamic> toJson() => {'id': id, 'sucursal': sucursal, 'empresa': empresa, 'color': color, 'codigoColor': codigoColor, 'tipoTela': tipoTela, 'metraje': metraje, 'fecha': fecha, 'notas': notas, 'fechaCreacion': fechaCreacion.toIso8601String(), 'historial': historial?.map((e) => e.toJson()).toList()};
}

class HistorialMovimiento {
  final String tipo; final String sucursalOrigen; final String sucursalDestino; final DateTime fecha;
  HistorialMovimiento({required this.tipo, required this.sucursalOrigen, required this.sucursalDestino, required this.fecha});
  factory HistorialMovimiento.fromJson(Map<String, dynamic> json) => HistorialMovimiento(tipo: json['tipo'] ?? '', sucursalOrigen: json['sucursalOrigen'] ?? '', sucursalDestino: json['sucursalDestino'] ?? '', fecha: json['fecha'] != null ? DateTime.parse(json['fecha']) : DateTime.now());
  Map<String, dynamic> toJson() => {'tipo': tipo, 'sucursalOrigen': sucursalOrigen, 'sucursalDestino': sucursalDestino, 'fecha': fecha.toIso8601String()};
}
