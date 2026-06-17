import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inv_telas/models/base/base_entity.dart';

class Moneda extends BaseEntity {
  final String empresaId;

  /// USD
  /// BOB
  /// EUR
  /// CNY
  final String codigo;

  /// Dólar Estadounidense
  /// Boliviano
  /// Euro
  /// Yuan Chino
  final String nombre;

  /// $
  /// Bs
  /// €
  /// ¥
  final String simbolo;

  final String? descripcion;

  /// Normalmente 2
  final int decimales;

  /// Solo una moneda debería ser base por empresa
  final bool esMonedaBase;

  /// Indica si requiere manejo de tipo de cambio
  ///
  /// Ejemplo:
  /// BOB = false
  /// USD = true
  /// EUR = true
  /// CNY = true
  final bool permiteTipoCambio;

  const Moneda({
    required super.id,
    required super.activo,
    required super.eliminado,
    required super.usuarioCreacion,
    super.usuarioModificacion,
    super.usuarioEliminacion,
    required super.fechaCreacion,
    super.fechaModificacion,
    super.fechaEliminacion,
    required this.empresaId,
    required this.codigo,
    required this.nombre,
    required this.simbolo,
    this.descripcion,
    this.decimales = 2,
    this.esMonedaBase = false,
    this.permiteTipoCambio = true,
  });

  Moneda copyWith({
    String? id,
    bool? activo,
    bool? eliminado,
    String? usuarioCreacion,
    String? usuarioModificacion,
    String? usuarioEliminacion,
    DateTime? fechaCreacion,
    DateTime? fechaModificacion,
    DateTime? fechaEliminacion,
    String? empresaId,
    String? codigo,
    String? nombre,
    String? simbolo,
    String? descripcion,
    int? decimales,
    bool? esMonedaBase,
    bool? permiteTipoCambio,
  }) {
    return Moneda(
      id: id ?? this.id,
      activo: activo ?? this.activo,
      eliminado: eliminado ?? this.eliminado,
      usuarioCreacion: usuarioCreacion ?? this.usuarioCreacion,
      usuarioModificacion: usuarioModificacion ?? this.usuarioModificacion,
      usuarioEliminacion: usuarioEliminacion ?? this.usuarioEliminacion,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaModificacion: fechaModificacion ?? this.fechaModificacion,
      fechaEliminacion: fechaEliminacion ?? this.fechaEliminacion,
      empresaId: empresaId ?? this.empresaId,
      codigo: codigo ?? this.codigo,
      nombre: nombre ?? this.nombre,
      simbolo: simbolo ?? this.simbolo,
      descripcion: descripcion ?? this.descripcion,
      decimales: decimales ?? this.decimales,
      esMonedaBase: esMonedaBase ?? this.esMonedaBase,
      permiteTipoCambio: permiteTipoCambio ?? this.permiteTipoCambio,
    );
  }

  factory Moneda.fromMap(Map<String, dynamic> map) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;

      if (value is Timestamp) {
        return value.toDate();
      }

      if (value is String) {
        return DateTime.tryParse(value);
      }

      return null;
    }

    return Moneda(
      id: map['id'] ?? '',
      activo: map['activo'] ?? true,
      eliminado: map['eliminado'] ?? false,
      usuarioCreacion: map['usuarioCreacion'] ?? '',
      usuarioModificacion: map['usuarioModificacion'],
      usuarioEliminacion: map['usuarioEliminacion'],
      fechaCreacion: parseDate(map['fechaCreacion']) ?? DateTime.now(),
      fechaModificacion: parseDate(map['fechaModificacion']),
      fechaEliminacion: parseDate(map['fechaEliminacion']),
      empresaId: map['empresaId'] ?? '',
      codigo: map['codigo'] ?? '',
      nombre: map['nombre'] ?? '',
      simbolo: map['simbolo'] ?? '',
      descripcion: map['descripcion'],
      decimales: map['decimales'] ?? 2,
      esMonedaBase: map['esMonedaBase'] ?? false,
      permiteTipoCambio: map['permiteTipoCambio'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'activo': activo,
      'eliminado': eliminado,
      'usuarioCreacion': usuarioCreacion,
      'usuarioModificacion': usuarioModificacion,
      'usuarioEliminacion': usuarioEliminacion,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'fechaModificacion': fechaModificacion != null
          ? Timestamp.fromDate(fechaModificacion!)
          : null,
      'fechaEliminacion': fechaEliminacion != null
          ? Timestamp.fromDate(fechaEliminacion!)
          : null,
      'empresaId': empresaId,
      'codigo': codigo.trim().toUpperCase(),
      'nombre': nombre.trim(),
      'simbolo': simbolo.trim(),
      'descripcion': descripcion?.trim(),
      'decimales': decimales,
      'esMonedaBase': esMonedaBase,
      'permiteTipoCambio': permiteTipoCambio,
    };
  }

  String toJson() => json.encode(toMap());

  factory Moneda.fromJson(String source) => Moneda.fromMap(json.decode(source));

  @override
  String toString() {
    return '''
Moneda(
  id: $id,
  empresaId: $empresaId,
  codigo: $codigo,
  nombre: $nombre,
  simbolo: $simbolo,
  decimales: $decimales,
  esMonedaBase: $esMonedaBase,
  permiteTipoCambio: $permiteTipoCambio
)
''';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Moneda && other.id == id && other.empresaId == empresaId;
  }

  @override
  int get hashCode {
    return Object.hash(id, empresaId);
  }
}
