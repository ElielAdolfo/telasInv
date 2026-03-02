import 'dart:convert';

class RolloModel {
  final String id;
  String sucursal;
  final String empresa;
  final String color;
  final String codigoColor;
  final String tipoTela;
  double metraje;
  final String? fecha;
  final String? notas;
  final DateTime fechaCreacion;
  List<HistorialMovimiento> historial;

  RolloModel({
    required this.id,
    this.sucursal = '',
    required this.empresa,
    required this.color,
    required this.codigoColor,
    this.tipoTela = '',
    required this.metraje,
    this.fecha,
    this.notas,
    required this.fechaCreacion,
    List<HistorialMovimiento>? historial,
  }) : historial = historial ?? [];

  RolloModel copyWith({
    String? id,
    String? sucursal,
    String? empresa,
    String? color,
    String? codigoColor,
    String? tipoTela,
    double? metraje,
    String? fecha,
    String? notas,
    DateTime? fechaCreacion,
    List<HistorialMovimiento>? historial,
  }) {
    return RolloModel(
      id: id ?? this.id,
      sucursal: sucursal ?? this.sucursal,
      empresa: empresa ?? this.empresa,
      color: color ?? this.color,
      codigoColor: codigoColor ?? this.codigoColor,
      tipoTela: tipoTela ?? this.tipoTela,
      metraje: metraje ?? this.metraje,
      fecha: fecha ?? this.fecha,
      notas: notas ?? this.notas,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      historial: historial ?? List.from(this.historial),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sucursal': sucursal,
      'empresa': empresa,
      'color': color,
      'codigoColor': codigoColor,
      'tipoTela': tipoTela,
      'metraje': metraje,
      'fecha': fecha,
      'notas': notas,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'historial': historial.map((h) => h.toMap()).toList(),
    };
  }

  factory RolloModel.fromMap(Map<String, dynamic> map) {
    return RolloModel(
      id: map['id'] ?? '',
      sucursal: map['sucursal'] ?? '',
      empresa: map['empresa'] ?? '',
      color: map['color'] ?? '',
      codigoColor: map['codigoColor'] ?? '',
      tipoTela: map['tipoTela'] ?? '',
      metraje: (map['metraje'] ?? 0).toDouble(),
      fecha: map['fecha'],
      notas: map['notas'],
      fechaCreacion: DateTime.parse(map['fechaCreacion']),
      historial: map['historial'] != null
          ? List<HistorialMovimiento>.from(
              map['historial'].map((h) => HistorialMovimiento.fromMap(h)))
          : [],
    );
  }

  String toJson() => json.encode(toMap());
  factory RolloModel.fromJson(String source) => RolloModel.fromMap(json.decode(source));

  static String generarId() {
    return DateTime.now().millisecondsSinceEpoch.toRadixString(36) +
        DateTime.now().microsecond.toRadixString(36);
  }

  String get grupoKey => '$color|$empresa|$codigoColor|$tipoTela';

  String get estadoStock {
    if (metraje >= 50) return 'alto';
    if (metraje >= 20) return 'medio';
    return 'bajo';
  }

  String get fechaFormateada {
    if (fecha == null || fecha!.isEmpty) return '-';
    try {
      final date = DateTime.parse(fecha!);
      return '${date.day.toString().padLeft(2, "0")}/${date.month.toString().padLeft(2, "0")}/${date.year}';
    } catch (e) {
      return '-';
    }
  }

  @override
  String toString() => 'RolloModel(id: $id, color: $color, codigo: $codigoColor, metraje: $metraje)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RolloModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class HistorialMovimiento {
  final String tipo;
  final String sucursalOrigen;
  final String sucursalDestino;
  final DateTime fecha;

  HistorialMovimiento({
    required this.tipo,
    required this.sucursalOrigen,
    required this.sucursalDestino,
    required this.fecha,
  });

  Map<String, dynamic> toMap() {
    return {
      'tipo': tipo,
      'sucursalOrigen': sucursalOrigen,
      'sucursalDestino': sucursalDestino,
      'fecha': fecha.toIso8601String(),
    };
  }

  factory HistorialMovimiento.fromMap(Map<String, dynamic> map) {
    return HistorialMovimiento(
      tipo: map['tipo'] ?? '',
      sucursalOrigen: map['sucursalOrigen'] ?? '',
      sucursalDestino: map['sucursalDestino'] ?? '',
      fecha: DateTime.parse(map['fecha']),
    );
  }
}
