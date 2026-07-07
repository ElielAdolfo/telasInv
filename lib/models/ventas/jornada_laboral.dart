import 'package:cloud_firestore/cloud_firestore.dart';

class JornadaLaboral {
  final String id;
  final String empresaId;
  final String sucursalId;
  final String usuarioId;
  final double tipoCambio;
  final double cajaInicialBs;
  final double? cajaFinalBs;
  final DateTime fechaApertura;
  final DateTime? fechaCierre;
  final bool abierta;
  final String fechaDia;
  final int reaperturas;

  const JornadaLaboral({
    required this.id,
    required this.empresaId,
    required this.sucursalId,
    required this.usuarioId,
    required this.tipoCambio,
    required this.cajaInicialBs,
    this.cajaFinalBs,
    required this.fechaApertura,
    this.fechaCierre,
    required this.abierta,
    required this.fechaDia,
    this.reaperturas = 0,
  });

  JornadaLaboral copyWith({
    String? id,
    String? empresaId,
    String? sucursalId,
    String? usuarioId,
    double? tipoCambio,
    double? cajaInicialBs,
    double? cajaFinalBs,
    DateTime? fechaApertura,
    DateTime? fechaCierre,
    bool? abierta,
    String? fechaDia,
    int? reaperturas,
  }) {
    return JornadaLaboral(
      id: id ?? this.id,
      empresaId: empresaId ?? this.empresaId,
      sucursalId: sucursalId ?? this.sucursalId,
      usuarioId: usuarioId ?? this.usuarioId,
      tipoCambio: tipoCambio ?? this.tipoCambio,
      cajaInicialBs: cajaInicialBs ?? this.cajaInicialBs,
      cajaFinalBs: cajaFinalBs ?? this.cajaFinalBs,
      fechaApertura: fechaApertura ?? this.fechaApertura,
      fechaCierre: fechaCierre ?? this.fechaCierre,
      abierta: abierta ?? this.abierta,
      fechaDia: fechaDia ?? this.fechaDia,
      reaperturas: reaperturas ?? this.reaperturas,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'empresaId': empresaId,
      'sucursalId': sucursalId,
      'usuarioId': usuarioId,
      'tipoCambio': tipoCambio,
      'cajaInicialBs': cajaInicialBs,
      'cajaFinalBs': cajaFinalBs,
      'fechaApertura': fechaApertura.toIso8601String(),
      'fechaCierre': fechaCierre?.toIso8601String(),
      'abierta': abierta,
      'fechaDia': fechaDia,
      'reaperturas': reaperturas,
    };
  }

  factory JornadaLaboral.fromMap(Map<String, dynamic> map) {
    return JornadaLaboral(
      id: map['id'] ?? '',
      empresaId: map['empresaId'] ?? '',
      sucursalId: map['sucursalId'] ?? '',
      usuarioId: map['usuarioId'] ?? '',
      tipoCambio: (map['tipoCambio'] as num?)?.toDouble() ?? 0.0,
      cajaInicialBs: (map['cajaInicialBs'] as num?)?.toDouble() ?? 0.0,
      cajaFinalBs: (map['cajaFinalBs'] as num?)?.toDouble(),
      // 🟢 Modificado para parsear de forma segura usando la función auxiliar
      fechaApertura: _parseFecha(map['fechaApertura']) ?? DateTime.now(),
      fechaCierre: _parseFecha(map['fechaCierre']),
      abierta: map['abierta'] ?? false,
      fechaDia: map['fechaDia'] ?? '',
      reaperturas: map['reaperturas'] ?? 0,
    );
  }

  /// 🟢 Función de ayuda interna para procesar dinámicamente Timestamps de Firestore o Strings ISO
  static DateTime? _parseFecha(dynamic valor) {
    if (valor == null) return null;
    if (valor is Timestamp) {
      return valor.toDate();
    }
    if (valor is String) {
      return DateTime.parse(valor);
    }
    return null;
  }
}
