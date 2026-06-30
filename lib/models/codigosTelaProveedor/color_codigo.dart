
class ColorCodigo {
  final String colorId;
  final String codigoColor;

  const ColorCodigo({required this.colorId, required this.codigoColor});

  factory ColorCodigo.fromMap(Map<String, dynamic> map) {
    return ColorCodigo(
      colorId: map['colorId'] ?? '',
      codigoColor: map['codigoColor'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'colorId': colorId, 'codigoColor': codigoColor};
  }

  ColorCodigo copyWith({String? colorId, String? codigoColor}) {
    return ColorCodigo(
      colorId: colorId ?? this.colorId,
      codigoColor: codigoColor ?? this.codigoColor,
    );
  }
}
