import 'package:cloud_firestore/cloud_firestore.dart';

class Sucursal {
  final String id;
  final String empresaId;

  final String nombre;
  final String direccion;

  final String? whatsapp;
  final String? nit;

  /// Mensual | Bimestral | Trimestral | etc
  final String? tipoPagoNit;

  /// Próxima fecha de pago
  final DateTime? fechaPagoNit;

  /// Usuarios encargados
  final List<String> encargadosIds;

  /// Estado
  final bool activo;
  final bool eliminado;

  /// Auditoría
  final DateTime? fechaCreacion;
  final String? usuarioCreadorId;

  final DateTime? fechaActualizacion;
  final String? usuarioModificadorId;

  final DateTime? fechaEliminacion;
  final String? usuarioEliminadorId;

  const Sucursal({
    required this.id,
    required this.empresaId,
    required this.nombre,
    required this.direccion,
    this.whatsapp,
    this.nit,
    this.tipoPagoNit,
    this.fechaPagoNit,
    this.encargadosIds = const [],
    this.activo = true,
    this.eliminado = false,
    this.fechaCreacion,
    this.usuarioCreadorId,
    this.fechaActualizacion,
    this.usuarioModificadorId,
    this.fechaEliminacion,
    this.usuarioEliminadorId,
  });

  factory Sucursal.fromJson(Map<String, dynamic> json) {
    return Sucursal(
      id: json['id'] ?? '',
      empresaId: json['empresaId'] ?? '',

      nombre: json['nombre'] ?? '',
      direccion: json['direccion'] ?? '',

      whatsapp: json['whatsapp'],
      nit: json['nit'],

      tipoPagoNit: json['tipoPagoNit'],

      fechaPagoNit: json['fechaPagoNit'] != null
          ? (json['fechaPagoNit'] as Timestamp).toDate()
          : null,

      encargadosIds:
          (json['encargadosIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],

      activo: json['activo'] ?? true,
      eliminado: json['eliminado'] ?? false,

      fechaCreacion: json['fechaCreacion'] != null
          ? (json['fechaCreacion'] as Timestamp).toDate()
          : null,

      usuarioCreadorId: json['usuarioCreadorId'],

      fechaActualizacion: json['fechaActualizacion'] != null
          ? (json['fechaActualizacion'] as Timestamp).toDate()
          : null,

      usuarioModificadorId: json['usuarioModificadorId'],

      fechaEliminacion: json['fechaEliminacion'] != null
          ? (json['fechaEliminacion'] as Timestamp).toDate()
          : null,

      usuarioEliminadorId: json['usuarioEliminadorId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'empresaId': empresaId,

      'nombre': nombre,
      'direccion': direccion,

      'whatsapp': whatsapp,
      'nit': nit,

      'tipoPagoNit': tipoPagoNit,

      'fechaPagoNit': fechaPagoNit != null
          ? Timestamp.fromDate(fechaPagoNit!)
          : null,

      'encargadosIds': encargadosIds,

      'activo': activo,
      'eliminado': eliminado,

      'fechaCreacion': fechaCreacion != null
          ? Timestamp.fromDate(fechaCreacion!)
          : null,

      'usuarioCreadorId': usuarioCreadorId,

      'fechaActualizacion': fechaActualizacion != null
          ? Timestamp.fromDate(fechaActualizacion!)
          : null,

      'usuarioModificadorId': usuarioModificadorId,

      'fechaEliminacion': fechaEliminacion != null
          ? Timestamp.fromDate(fechaEliminacion!)
          : null,

      'usuarioEliminadorId': usuarioEliminadorId,
    };
  }

  Sucursal copyWith({
    String? id,
    String? empresaId,
    String? nombre,
    String? direccion,
    String? whatsapp,
    String? nit,
    String? tipoPagoNit,
    DateTime? fechaPagoNit,
    List<String>? encargadosIds,
    bool? activo,
    bool? eliminado,
    DateTime? fechaCreacion,
    String? usuarioCreadorId,
    DateTime? fechaActualizacion,
    String? usuarioModificadorId,
    DateTime? fechaEliminacion,
    String? usuarioEliminadorId,
  }) {
    return Sucursal(
      id: id ?? this.id,
      empresaId: empresaId ?? this.empresaId,
      nombre: nombre ?? this.nombre,
      direccion: direccion ?? this.direccion,
      whatsapp: whatsapp ?? this.whatsapp,
      nit: nit ?? this.nit,
      tipoPagoNit: tipoPagoNit ?? this.tipoPagoNit,
      fechaPagoNit: fechaPagoNit ?? this.fechaPagoNit,
      encargadosIds: encargadosIds ?? this.encargadosIds,
      activo: activo ?? this.activo,
      eliminado: eliminado ?? this.eliminado,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      usuarioCreadorId: usuarioCreadorId ?? this.usuarioCreadorId,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
      usuarioModificadorId: usuarioModificadorId ?? this.usuarioModificadorId,
      fechaEliminacion: fechaEliminacion ?? this.fechaEliminacion,
      usuarioEliminadorId: usuarioEliminadorId ?? this.usuarioEliminadorId,
    );
  }
}
