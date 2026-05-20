import 'package:cloud_firestore/cloud_firestore.dart';

class PrecioVenta {
  final String id;
  final String sucursalId;

  // Si es null, aplica para todas las empresas (General)
  // Si tiene valor, aplica solo para esa empresa
  final String? empresaId;

  final String telaId;
  final String telaNombre;

  // PRECIO BASE
  final double precioMetro;

  // MAYOR
  final bool tienePrecioMayor;
  final double? cantidadMinimaMayor;
  final double? precioMayor;

  // ROLLO
  final bool tienePrecioRollo;

  // 'fijo' | 'dinamico'
  final String tipoPrecioRollo;

  // Caso fijo
  final double? precioRolloFijo;

  // Caso dinamico
  final double? precioMetroRollo;
  final double? rangoMinRollo;
  final double? rangoMaxRollo;

  // AUDITORIA
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String updatedBy;
  final bool activo;

  PrecioVenta({
    required this.id,
    required this.sucursalId,
    this.empresaId,
    required this.telaId,
    required this.telaNombre,
    required this.precioMetro,
    this.tienePrecioMayor = false,
    this.cantidadMinimaMayor,
    this.precioMayor,
    this.tienePrecioRollo = false,
    this.tipoPrecioRollo = 'fijo',
    this.precioRolloFijo,
    this.precioMetroRollo,
    this.rangoMinRollo,
    this.rangoMaxRollo,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.createdBy = '',
    this.updatedBy = '',
    this.activo = true,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory PrecioVenta.fromJson(Map<String, dynamic> json) => PrecioVenta(
    id: json['id'] ?? '',
    sucursalId: json['sucursalId'] ?? '',
    empresaId: json['empresaId'], // Puede ser null
    telaId: json['telaId'] ?? '',
    telaNombre: json['telaNombre'] ?? '',
    precioMetro: (json['precioMetro'] ?? 0).toDouble(),
    tienePrecioMayor: json['tienePrecioMayor'] ?? false,
    cantidadMinimaMayor: (json['cantidadMinimaMayor'] as num?)?.toDouble(),
    precioMayor: (json['precioMayor'] as num?)?.toDouble(),
    tienePrecioRollo: json['tienePrecioRollo'] ?? false,
    tipoPrecioRollo: json['tipoPrecioRollo'] ?? 'fijo',
    precioRolloFijo: (json['precioRolloFijo'] as num?)?.toDouble(),
    precioMetroRollo: (json['precioMetroRollo'] as num?)?.toDouble(),
    rangoMinRollo: (json['rangoMinRollo'] as num?)?.toDouble(),
    rangoMaxRollo: (json['rangoMaxRollo'] as num?)?.toDouble(),
    createdAt: json['createdAt'] != null
        ? (json['createdAt'] as Timestamp).toDate()
        : DateTime.now(),
    updatedAt: json['updatedAt'] != null
        ? (json['updatedAt'] as Timestamp).toDate()
        : DateTime.now(),
    createdBy: json['createdBy'] ?? '',
    updatedBy: json['updatedBy'] ?? '',
    activo: json['activo'] ?? true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'sucursalId': sucursalId,
    'empresaId': empresaId, // Firestore guarda null si es null
    'telaId': telaId,
    'telaNombre': telaNombre,
    'precioMetro': precioMetro,
    'tienePrecioMayor': tienePrecioMayor,
    'cantidadMinimaMayor': cantidadMinimaMayor,
    'precioMayor': precioMayor,
    'tienePrecioRollo': tienePrecioRollo,
    'tipoPrecioRollo': tipoPrecioRollo,
    'precioRolloFijo': precioRolloFijo,
    'precioMetroRollo': precioMetroRollo,
    'rangoMinRollo': rangoMinRollo,
    'rangoMaxRollo': rangoMaxRollo,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
    'createdBy': createdBy,
    'updatedBy': updatedBy,
    'activo': activo,
  };

  PrecioVenta copyWith({
    String? id,
    String? sucursalId,
    String? empresaId,
    String? telaId,
    String? telaNombre,
    double? precioMetro,
    bool? tienePrecioMayor,
    double? cantidadMinimaMayor,
    double? precioMayor,
    bool? tienePrecioRollo,
    String? tipoPrecioRollo,
    double? precioRolloFijo,
    double? precioMetroRollo,
    double? rangoMinRollo,
    double? rangoMaxRollo,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
    bool? activo,
    bool? clearEmpresaId= false, // Helper para setear empresaId a null
  }) {
    return PrecioVenta(
      id: id ?? this.id,
      sucursalId: sucursalId ?? this.sucursalId,
      empresaId: clearEmpresaId == true ? null : (empresaId ?? this.empresaId),
      telaId: telaId ?? this.telaId,
      telaNombre: telaNombre ?? this.telaNombre,
      precioMetro: precioMetro ?? this.precioMetro,
      tienePrecioMayor: tienePrecioMayor ?? this.tienePrecioMayor,
      cantidadMinimaMayor: cantidadMinimaMayor ?? this.cantidadMinimaMayor,
      precioMayor: precioMayor ?? this.precioMayor,
      tienePrecioRollo: tienePrecioRollo ?? this.tienePrecioRollo,
      tipoPrecioRollo: tipoPrecioRollo ?? this.tipoPrecioRollo,
      precioRolloFijo: precioRolloFijo ?? this.precioRolloFijo,
      precioMetroRollo: precioMetroRollo ?? this.precioMetroRollo,
      rangoMinRollo: rangoMinRollo ?? this.rangoMinRollo,
      rangoMaxRollo: rangoMaxRollo ?? this.rangoMaxRollo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      activo: activo ?? this.activo,
    );
  }
}
