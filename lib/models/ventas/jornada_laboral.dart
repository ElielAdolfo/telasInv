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
      'fechaApertura': Timestamp.fromDate(fechaApertura),
      'fechaCierre': fechaCierre != null
          ? Timestamp.fromDate(fechaCierre!)
          : null,
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
      tipoCambio: (map['tipoCambio'] as num?)?.toDouble() ?? 6.96,
      cajaInicialBs: (map['cajaInicialBs'] as num?)?.toDouble() ?? 0,
      cajaFinalBs: (map['cajaFinalBs'] as num?)?.toDouble(),
      fechaApertura:
          (map['fechaApertura'] as Timestamp?)?.toDate() ?? DateTime.now(),
      fechaCierre: map['fechaCierre'] != null
          ? (map['fechaCierre'] as Timestamp).toDate()
          : null,
      abierta: map['abierta'] ?? false,
      fechaDia: map['fechaDia'] ?? '',
      reaperturas: map['reaperturas'] ?? 0,
    );
  }
}
