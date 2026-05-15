class LoteItem {
  final String empresaId;
  final String tipoTelaId;
  final double precioUnitario; // Precio en la moneda seleccionada

  LoteItem({
    required this.empresaId,
    required this.tipoTelaId,
    required this.precioUnitario,
  });

  factory LoteItem.fromJson(Map<String, dynamic> json) => LoteItem(
    empresaId: json['empresaId'] ?? '',
    tipoTelaId: json['tipoTelaId'] ?? '',
    precioUnitario: (json['precioUnitario'] ?? 0).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'empresaId': empresaId,
    'tipoTelaId': tipoTelaId,
    'precioUnitario': precioUnitario,
  };
}

class Lote {
  final String id;
  final String nombre;
  final DateTime fechaCreacion;
  final DateTime fechaIngreso;
  final int vigenciaDias;
  final bool activo;

  // Responsable
  final String usuarioResponsableId;

  // Configuración Monetaria
  final bool esBoliviano;
  final String? monedaExtranjeraId;
  final double tipoCambio;

  // ✅ CAMBIO: Lista unificada de Items (Empresa + Tela + Precio)
  final List<LoteItem> items;

  // Eliminación Lógica
  final bool eliminado;
  final String? usuarioEliminadorId;
  final DateTime? fechaEliminacion;

  Lote({
    required this.id,
    required this.nombre,
    required this.fechaCreacion,
    required this.fechaIngreso,
    this.vigenciaDias = 5,
    this.activo = false,
    required this.usuarioResponsableId,
    this.esBoliviano = true,
    this.monedaExtranjeraId,
    this.tipoCambio = 1.0,
    this.items = const [],
    this.eliminado = false,
    this.usuarioEliminadorId,
    this.fechaEliminacion,
  });

  bool get estaVigente {
    final fechaLimite = fechaIngreso.add(Duration(days: vigenciaDias));
    return DateTime.now().isBefore(fechaLimite);
  }

  factory Lote.fromJson(Map<String, dynamic> json) {
    return Lote(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      fechaCreacion: json['fechaCreacion'] != null
          ? DateTime.parse(json['fechaCreacion'])
          : DateTime.now(),
      fechaIngreso: json['fechaIngreso'] != null
          ? DateTime.parse(json['fechaIngreso'])
          : DateTime.now(),
      vigenciaDias: json['vigenciaDias'] ?? 5,
      activo: json['activo'] ?? false,
      usuarioResponsableId: json['usuarioResponsableId'] ?? '',
      esBoliviano: json['esBoliviano'] ?? true,
      monedaExtranjeraId: json['monedaExtranjeraId'],
      tipoCambio: (json['tipoCambio'] ?? 1.0).toDouble(),
      items: json['items'] != null
          ? (json['items'] as List).map((e) => LoteItem.fromJson(e)).toList()
          : [],
      eliminado: json['eliminado'] ?? false,
      usuarioEliminadorId: json['usuarioEliminadorId'],
      fechaEliminacion: json['fechaEliminacion'] != null
          ? DateTime.parse(json['fechaEliminacion'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'fechaCreacion': fechaCreacion.toIso8601String(),
    'fechaIngreso': fechaIngreso.toIso8601String(),
    'vigenciaDias': vigenciaDias,
    'activo': activo,
    'usuarioResponsableId': usuarioResponsableId,
    'esBoliviano': esBoliviano,
    'monedaExtranjeraId': monedaExtranjeraId,
    'tipoCambio': tipoCambio,
    'items': items.map((e) => e.toJson()).toList(),
    'eliminado': eliminado,
    'usuarioEliminadorId': usuarioEliminadorId,
    'fechaEliminacion': fechaEliminacion?.toIso8601String(),
  };

  Lote copyWith({
    String? id,
    String? nombre,
    DateTime? fechaCreacion,
    DateTime? fechaIngreso,
    int? vigenciaDias,
    bool? activo,
    String? usuarioResponsableId,
    bool? esBoliviano,
    String? monedaExtranjeraId,
    double? tipoCambio,
    List<LoteItem>? items,
    bool? eliminado,
    String? usuarioEliminadorId,
    DateTime? fechaEliminacion,
  }) {
    return Lote(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaIngreso: fechaIngreso ?? this.fechaIngreso,
      vigenciaDias: vigenciaDias ?? this.vigenciaDias,
      activo: activo ?? this.activo,
      usuarioResponsableId: usuarioResponsableId ?? this.usuarioResponsableId,
      esBoliviano: esBoliviano ?? this.esBoliviano,
      monedaExtranjeraId: monedaExtranjeraId ?? this.monedaExtranjeraId,
      tipoCambio: tipoCambio ?? this.tipoCambio,
      items: items ?? this.items,
      eliminado: eliminado ?? this.eliminado,
      usuarioEliminadorId: usuarioEliminadorId ?? this.usuarioEliminadorId,
      fechaEliminacion: fechaEliminacion ?? this.fechaEliminacion,
    );
  }
}
