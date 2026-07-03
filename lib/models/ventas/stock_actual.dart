// lib/models/ventas/stock_actual.dart

enum StockRolloEstado { cerrado, abierto, vendido }

extension StockRolloEstadoExtension on StockRolloEstado {
  String get nombre {
    switch (this) {
      case StockRolloEstado.cerrado:
        return 'CERRADO';
      case StockRolloEstado.abierto:
        return 'ABIERTO';
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
  });

  /// METODO EXTRA PARA OBTENER EL DATO DINÁMICO (Número de rollo / Largo)
  /// Extrae el primer valor registrado en los atributos especiales, o retorna 'S/N' si está vacío.
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
    );
  }
}
