class PrecioConfig {
  final String monedaId;
  final double precioMetro; // Caso 1: Precio directo por metro lineal
  final double precioRollo; // Caso 2: Precio por rollo cerrado de metraje fijo
  final double metrajeFijo; // Por defecto 50.0 (útil para el Caso 2)

  const PrecioConfig({
    required this.monedaId,
    required this.precioMetro,
    required this.precioRollo,
    this.metrajeFijo = 50.0,
  });

  factory PrecioConfig.fromMap(Map<String, dynamic> map) {
    return PrecioConfig(
      monedaId: map['monedaId'] ?? '',
      precioMetro: (map['precioMetro'] ?? 0.0).toDouble(),
      precioRollo: (map['precioRollo'] ?? 0.0).toDouble(),
      metrajeFijo: (map['metrajeFijo'] ?? 50.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'monedaId': monedaId,
      'precioMetro': precioMetro,
      'precioRollo': precioRollo,
      'metrajeFijo': metrajeFijo,
    };
  }
}
