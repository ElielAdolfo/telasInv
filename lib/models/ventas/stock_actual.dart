enum StockRolloEstado { cerrado, abierto, sobra, vendido }

extension StockRolloEstadoExtension on StockRolloEstado {
  String get nombre {
    switch (this) {
      case StockRolloEstado.cerrado:
        return 'CERRADO';
      case StockRolloEstado.abierto:
        return 'ABIERTO';
      case StockRolloEstado.sobra:
        return 'SOBRA';
      case StockRolloEstado.vendido:
        return 'VENDIDO';
    }
  }

  static StockRolloEstado fromString(String value) {
    return StockRolloEstado.values.firstWhere(
      (e) => e.nombre == value.toUpperCase(),
      orElse: () => StockRolloEstado.cerrado,
    );
  }
}

class StockActual {
  final String id;
  final String loteId;
  final String loteDetalleId;
  final String tipoTelaId;
  final String idRollo;
  final int numeroFisico;
  final String sucursalActualId;
  final String? colorId;
  final Map<String, dynamic> atributosEspeciales;
  final double metrajeOriginal;
  final double metrajeActual;
  final StockRolloEstado estado;
  final DateTime fechaIngresoStock;

  final double gastosComunes;
  final double gastosEnlazado;
  final double precioCompraRollo;
  final double precioTotal;

  // NUEVAS VARIABLES INTEGRADAS
  final String codigoTelaProveedorId;
  final String proveedorId;

  const StockActual({
    required this.id,
    required this.loteId,
    required this.loteDetalleId,
    required this.tipoTelaId,
    required this.idRollo,
    required this.numeroFisico,
    required this.sucursalActualId,
    this.colorId,
    required this.atributosEspeciales,
    required this.metrajeOriginal,
    required this.metrajeActual,
    required this.estado,
    required this.fechaIngresoStock,
    required this.gastosComunes,
    required this.gastosEnlazado,
    required this.precioCompraRollo,
    required this.precioTotal,
    // Argumentos requeridos en constructor
    required this.proveedorId,
    required this.codigoTelaProveedorId,
  });

  String obtenerDiferenciador() {
    if (atributosEspeciales.isEmpty) return 'S/N';
    return atributosEspeciales.values.first.toString();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'loteId': loteId,
      'loteDetalleId': loteDetalleId,
      'tipoTelaId': tipoTelaId,
      'idRollo': idRollo,
      'numeroFisico': numeroFisico,
      'sucursalActualId': sucursalActualId,
      'colorId': colorId,
      'atributosEspeciales': atributosEspeciales,
      'metrajeOriginal': metrajeOriginal,
      'metrajeActual': metrajeActual,
      'estado': estado.nombre,
      'fechaIngresoStock': fechaIngresoStock.toIso8601String(),
      'gastosComunes': gastosComunes,
      'gastosEnlazado': gastosEnlazado,
      'precioCompraRollo': precioCompraRollo,
      'precioTotal': precioTotal,
      // Serialización nueva
      'proveedorId': proveedorId,
      'codigoTelaProveedorId': codigoTelaProveedorId,
    };
  }

  factory StockActual.fromJson(Map<String, dynamic> json) {
    return StockActual(
      id: json['id'] ?? '',
      loteId: json['loteId'] ?? '',
      loteDetalleId: json['loteDetalleId'] ?? '',
      tipoTelaId: json['tipoTelaId'] ?? '',
      idRollo: json['idRollo'] ?? '',
      numeroFisico: json['numeroFisico'] is int
          ? json['numeroFisico']
          : int.tryParse(json['numeroFisico']?.toString() ?? '0') ?? 0,
      sucursalActualId: json['sucursalActualId'] ?? '',
      colorId: json['colorId'],
      atributosEspeciales: json['atributosEspeciales'] is Map
          ? Map<String, dynamic>.from(json['atributosEspeciales'])
          : {},
      metrajeOriginal: json['metrajeOriginal'] is num
          ? (json['metrajeOriginal'] as num).toDouble()
          : double.tryParse(json['metrajeOriginal']?.toString() ?? '0.0') ??
                0.0,
      metrajeActual: json['metrajeActual'] is num
          ? (json['metrajeActual'] as num).toDouble()
          : double.tryParse(json['metrajeActual']?.toString() ?? '0.0') ?? 0.0,
      estado: StockRolloEstadoExtension.fromString(json['estado'] ?? 'CERRADO'),
      fechaIngresoStock:
          DateTime.tryParse(json['fechaIngresoStock']?.toString() ?? '') ??
          DateTime.now(),
      gastosComunes: ((json['gastosComunes'] ?? 0.0) as num).toDouble(),
      gastosEnlazado: ((json['gastosEnlazado'] ?? 0.0) as num).toDouble(),
      precioCompraRollo: ((json['precioCompraRollo'] ?? 0.0) as num).toDouble(),
      precioTotal: ((json['precioTotal'] ?? 0.0) as num).toDouble(),
      // Deserialización de los nuevos campos
      proveedorId: json['proveedorId'] ?? '',
      codigoTelaProveedorId: json['codigoTelaProveedorId'],
    );
  }

  StockActual copyWith({
    String? id,
    String? loteId,
    String? loteDetalleId,
    String? tipoTelaId,
    String? idRollo,
    int? numeroFisico,
    String? sucursalActualId,
    String? colorId,
    Map<String, dynamic>? atributosEspeciales,
    double? metrajeOriginal,
    double? metrajeActual,
    StockRolloEstado? estado,
    DateTime? fechaIngresoStock,
    double? gastosComunes,
    double? gastosEnlazado,
    double? precioCompraRollo,
    double? precioTotal,
    String? proveedorId,
    String? codigoTelaProveedorId,
  }) {
    return StockActual(
      id: id ?? this.id,
      loteId: loteId ?? this.loteId,
      loteDetalleId: loteDetalleId ?? this.loteDetalleId,
      tipoTelaId: tipoTelaId ?? this.tipoTelaId,
      idRollo: idRollo ?? this.idRollo,
      numeroFisico: numeroFisico ?? this.numeroFisico,
      sucursalActualId: sucursalActualId ?? this.sucursalActualId,
      colorId: colorId ?? this.colorId,
      atributosEspeciales: atributosEspeciales ?? this.atributosEspeciales,
      metrajeOriginal: metrajeOriginal ?? this.metrajeOriginal,
      metrajeActual: metrajeActual ?? this.metrajeActual,
      estado: estado ?? this.estado,
      fechaIngresoStock: fechaIngresoStock ?? this.fechaIngresoStock,
      gastosComunes: gastosComunes ?? this.gastosComunes,
      gastosEnlazado: gastosEnlazado ?? this.gastosEnlazado,
      precioCompraRollo: precioCompraRollo ?? this.precioCompraRollo,
      precioTotal: precioTotal ?? this.precioTotal,
      proveedorId: proveedorId ?? this.proveedorId,
      codigoTelaProveedorId:
          codigoTelaProveedorId ?? this.codigoTelaProveedorId,
    );
  }
}
