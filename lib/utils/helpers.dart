import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class Helpers {
  /// Genera un ID único basado en timestamp
  static String generarId() =>
      DateTime.now().millisecondsSinceEpoch.toRadixString(36) +
      DateTime.now().microsecondsSinceEpoch.toRadixString(36);

  /// Formatea una fecha a 'dd MMM yyyy' en español
  static String formatearFecha(DateTime? fecha) =>
      fecha == null ? '-' : DateFormat('dd MMM yyyy', 'es').format(fecha);

  /// Convierte un código HEX a entero para Color
  static int hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex'; // añade alpha si falta
    return int.parse(hex, radix: 16);
  }

  /// Convierte HEX a Color de Flutter
  static Color hexToColorFlutter(String hex) => Color(hexToColor(hex));
}
