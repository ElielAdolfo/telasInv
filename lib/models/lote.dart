class LoteItem {
  final String id;
  final String tipoTelaId;
  final String empresaId;
  final String? anchoId; // Opcional
  final double precioUSD;

  LoteItem({
    required this.id,
    required this.tipoTelaId,
    required this.empresaId,
    this.anchoId,
    required this.precioUSD,
  });

  factory LoteItem.fromJson(Map<String, dynamic> json) => LoteItem(
    id: json['id'] ?? '',
    tipoTelaId: json['tipoTelaId'] ?? '',
    empresaId: json['empresaId'] ?? '',
    anchoId: json['anchoId'],
    precioUSD: (json['precioUSD'] ?? 0).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'tipoTelaId': tipoTelaId,
    'empresaId': empresaId,
    'anchoId': anchoId,
    'precioUSD': precioUSD,
  };

  // Helper para generar un ID único de combinación para validaciones
  String get comboKey => '${tipoTelaId}_${empresaId}_${anchoId ?? 'sin_ancho'}';
}

class Lote {
  final String id;
  final String nombre;
  final DateTime fecha;
  final double tipoCambio;
  final String encargado; // Nombre de la persona
  final List<LoteItem> items;
  final bool activo;
  final DateTime? fechaActivacion;

  Lote({
    required this.id,
    required this.nombre,
    required this.fecha,
    required this.tipoCambio,
    required this.encargado,
    this.items = const [],
    this.activo = false, // Por defecto inactivo
    this.fechaActivacion,
  });

  factory Lote.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] != null
        ? (json['items'] as List).map((e) => LoteItem.fromJson(e)).toList()
        : <LoteItem>[];

    return Lote(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      fecha: json['fecha'] != null
          ? DateTime.parse(json['fecha'])
          : DateTime.now(),
      tipoCambio: (json['tipoCambio'] ?? 0).toDouble(),
      encargado: json['encargado'] ?? '',
      items: itemsList,
      activo: json['activo'] ?? false,
      fechaActivacion: json['fechaActivacion'] != null 
          ? DateTime.parse(json['fechaActivacion']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'fecha': fecha.toIso8601String(),
    'tipoCambio': tipoCambio,
    'encargado': encargado,
    'items': items.map((e) => e.toJson()).toList(),
    'activo': activo,
    'fechaActivacion': fechaActivacion?.toIso8601String(),
  };
}
