class CampoValor {
  final String campoId;
  final String campoNombre; // 👈 agregar esto
  final dynamic valor;

  const CampoValor({
    required this.campoId,
    required this.campoNombre,
    required this.valor,
  });

  factory CampoValor.fromJson(Map<String, dynamic> json) {
    return CampoValor(
      campoId: json['campoId'] ?? '',
      campoNombre: json['campoNombre'] ?? '',
      valor: json['valor'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'campoId': campoId, 'campoNombre': campoNombre, 'valor': valor};
  }
}
