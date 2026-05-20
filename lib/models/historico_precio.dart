import 'package:cloud_firestore/cloud_firestore.dart';

class HistoricoPrecio {
  final String id;
  final String precioId;
  final String accion; // CREATE, UPDATE, DELETE
  final Map<String, dynamic>? datosAnteriores;
  final Map<String, dynamic>? datosNuevos;
  final String usuarioId;
  final String usuarioNombre;
  final DateTime fecha;
  final String sucursalId;
  final String telaId;
  final String? empresaId;

  HistoricoPrecio({
    required this.id,
    required this.precioId,
    required this.accion,
    this.datosAnteriores,
    this.datosNuevos,
    required this.usuarioId,
    required this.usuarioNombre,
    DateTime? fecha,
    required this.sucursalId,
    required this.telaId,
    this.empresaId,
  }) : fecha = fecha ?? DateTime.now();

  factory HistoricoPrecio.fromJson(Map<String, dynamic> json) =>
      HistoricoPrecio(
        id: json['id'] ?? '',
        precioId: json['precioId'] ?? '',
        accion: json['accion'] ?? '',
        datosAnteriores: json['datosAnteriores'],
        datosNuevos: json['datosNuevos'],
        usuarioId: json['usuarioId'] ?? '',
        usuarioNombre: json['usuarioNombre'] ?? '',
        fecha: json['fecha'] != null
            ? (json['fecha'] as Timestamp).toDate()
            : DateTime.now(),
        sucursalId: json['sucursalId'] ?? '',
        telaId: json['telaId'] ?? '',
        empresaId: json['empresaId'],
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'precioId': precioId,
    'accion': accion,
    'datosAnteriores': datosAnteriores,
    'datosNuevos': datosNuevos,
    'usuarioId': usuarioId,
    'usuarioNombre': usuarioNombre,
    'fecha': Timestamp.fromDate(fecha),
    'sucursalId': sucursalId,
    'telaId': telaId,
    'empresaId': empresaId,
  };
}
