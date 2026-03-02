class GrupoRollosModel {
  final String color;
  final String empresa;
  final String codigoColor;
  final String tipoTela;
  final List<dynamic> rollos;
  final double metrajeTotal;
  final Set<String> sucursales;

  GrupoRollosModel({
    required this.color,
    required this.empresa,
    required this.codigoColor,
    required this.tipoTela,
    required this.rollos,
    required this.metrajeTotal,
    required this.sucursales,
  });

  String get key => '$color|$empresa|$codigoColor|$tipoTela';
  int get cantidad => rollos.length;
  int get cantidadSucursales => sucursales.length;

  String get estadoStock {
    if (metrajeTotal >= 50) return 'alto';
    if (metrajeTotal >= 20) return 'medio';
    return 'bajo';
  }

  GrupoRollosModel copyWith({
    String? color,
    String? empresa,
    String? codigoColor,
    String? tipoTela,
    List<dynamic>? rollos,
    double? metrajeTotal,
    Set<String>? sucursales,
  }) {
    return GrupoRollosModel(
      color: color ?? this.color,
      empresa: empresa ?? this.empresa,
      codigoColor: codigoColor ?? this.codigoColor,
      tipoTela: tipoTela ?? this.tipoTela,
      rollos: rollos ?? this.rollos,
      metrajeTotal: metrajeTotal ?? this.metrajeTotal,
      sucursales: sucursales ?? this.sucursales,
    );
  }

  @override
  String toString() => 'GrupoRollosModel(color: $color, codigo: $codigoColor, cantidad: $cantidad)';
}
