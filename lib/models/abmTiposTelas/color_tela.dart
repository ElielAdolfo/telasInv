import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ColorTela {
  final String id;
  final String empresaId;
  final String nombre;
  final String hexadecimal; // Almacenado como "ED3550", "5829CD", etc.
  final bool activo;
  final bool eliminado;

  // Campos de auditoría (Usuarios)
  final String? usuarioCreadorId;
  final String? usuarioModificadorId;
  final String? usuarioEliminadorId;

  // Campos de auditoría (Fechas)
  final DateTime? fechaCreacion;
  final DateTime? fechaActualizacion;
  final DateTime? fechaEliminacion;

  ColorTela({
    required this.id,
    required this.empresaId,
    required this.nombre,
    required this.hexadecimal,
    this.activo = true,
    this.eliminado = false,
    this.usuarioCreadorId,
    this.usuarioModificadorId,
    this.usuarioEliminadorId,
    this.fechaCreacion,
    this.fechaActualizacion,
    this.fechaEliminacion,
  });

  /// Convierte la cadena hexadecimal de la Base de Datos en un objeto [Color] de Flutter
  Color get toFlutterColor {
    final hex = hexadecimal.replaceAll('#', '').trim();
    if (hex.length == 6) {
      return Color(
        int.parse('FF$hex', radix: 16),
      ); // Añade opacidad completa por defecto
    } else if (hex.length == 8) {
      return Color(int.parse(hex, radix: 16));
    }
    return Colors.transparent; // Fallback seguro
  }

  /// Crea una copia del objeto modificando atributos específicos
  ColorTela copyWith({
    String? id,
    String? empresaId,
    String? nombre,
    String? hexadecimal,
    bool? activo,
    bool? eliminado,
    String? usuarioCreadorId,
    String? usuarioModificadorId,
    String? usuarioEliminadorId,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
    DateTime? fechaEliminacion,
  }) {
    return ColorTela(
      id: id ?? this.id,
      empresaId: empresaId ?? this.empresaId,
      nombre: nombre ?? this.nombre,
      hexadecimal: hexadecimal ?? this.hexadecimal,
      activo: activo ?? this.activo,
      eliminado: eliminado ?? this.eliminado,
      usuarioCreadorId: usuarioCreadorId ?? this.usuarioCreadorId,
      usuarioModificadorId: usuarioModificadorId ?? this.usuarioModificadorId,
      usuarioEliminadorId: usuarioEliminadorId ?? this.usuarioEliminadorId,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
      fechaEliminacion: fechaEliminacion ?? this.fechaEliminacion,
    );
  }

  /// Deserializa desde Firestore manejando correctamente los [Timestamp]
  factory ColorTela.fromJson(Map<String, dynamic> json, String documentId) {
    return ColorTela(
      id: documentId,
      empresaId: json['empresaId'] ?? '',
      nombre: json['nombre'] ?? '',
      hexadecimal: json['hexadecimal'] ?? '',
      activo: json['activo'] ?? true,
      eliminado: json['eliminado'] ?? false,
      usuarioCreadorId: json['usuarioCreadorId'],
      usuarioModificadorId: json['usuarioModificadorId'],
      usuarioEliminadorId: json['usuarioEliminadorId'],
      fechaCreacion: json['fechaCreacion'] != null
          ? (json['fechaCreacion'] as Timestamp).toDate()
          : null,
      fechaActualizacion: json['fechaActualizacion'] != null
          ? (json['fechaActualizacion'] as Timestamp).toDate()
          : null,
      fechaEliminacion: json['fechaEliminacion'] != null
          ? (json['fechaEliminacion'] as Timestamp).toDate()
          : null,
    );
  }

  /// Serializa el objeto para ser guardado en Firestore
  Map<String, dynamic> toJson() {
    return {
      'empresaId': empresaId,
      'nombre': nombre,
      'hexadecimal': hexadecimal.toUpperCase().replaceAll('#', '').trim(),
      'activo': activo,
      'eliminado': eliminado,
      'usuarioCreadorId': usuarioCreadorId,
      'usuarioModificadorId': usuarioModificadorId,
      'usuarioEliminadorId': usuarioEliminadorId,
      'fechaCreacion': fechaCreacion != null
          ? Timestamp.fromDate(fechaCreacion!)
          : null,
      'fechaActualizacion': fechaActualizacion != null
          ? Timestamp.fromDate(fechaActualizacion!)
          : null,
      'fechaEliminacion': fechaEliminacion != null
          ? Timestamp.fromDate(fechaEliminacion!)
          : null,
    };
  }
}
