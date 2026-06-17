class RolloInfo {
  final String? numeroRollo; // Para el caso de Milenium ('32', '33', etc.)
  final double metros; // El metraje real de ese rollo específico (50, 43, 103)

  const RolloInfo({this.numeroRollo, required this.metros});

  factory RolloInfo.fromMap(Map<String, dynamic> map) {
    return RolloInfo(
      numeroRollo: map['numeroRollo'],
      metros: (map['metros'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'numeroRollo': numeroRollo, 'metros': metros};
  }
}
