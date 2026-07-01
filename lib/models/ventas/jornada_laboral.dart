// lib/models/ventas/jornada_laboral.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class JornadaLaboral {
  final String id;
  final String empresaId;
  final String sucursalId;
  final String usuarioId;
  final double tipoCambio; // T.C. del mercado ingresado en la mañana
  final double cajaInicialBs;
  final double? cajaFinalBs;
  final DateTime fechaApertura;
  final DateTime? fechaCierre;
  final bool abierta;

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
  });

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
    };
  }

  factory JornadaLaboral.fromMap(Map<String, dynamic> map) {
    return JornadaLaboral(
      id: map['id'] ?? '',
      empresaId: map['empresaId'] ?? '',
      sucursalId: map['sucursalId'] ?? '',
      usuarioId: map['usuarioId'] ?? '',
      tipoCambio: (map['tipoCambio'] as num?)?.toDouble() ?? 1.0,
      cajaInicialBs: (map['cajaInicialBs'] as num?)?.toDouble() ?? 0.0,
      cajaFinalBs: (map['cajaFinalBs'] as num?)?.toDouble(),
      fechaApertura: (map['fechaApertura'] as Timestamp).toDate(),
      fechaCierre: map['fechaCierre'] != null
          ? (map['fechaCierre'] as Timestamp).toDate()
          : null,
      abierta: map['abierta'] ?? false,
    );
  }
}
