import 'package:uuid/uuid.dart';

class GrupoRollo {
  final String uid;
  double metraje;
  String color;
  double cantidad;
  bool confirmado;
  Map<String, dynamic> atributosEspeciales;

  // Propiedades mutables locales para control de costos individuales
  double costoMetroOrigen;
  double costoRolloOrigen;

  GrupoRollo({
    String? uid,
    required this.metraje,
    required this.color,
    required this.cantidad,
    this.confirmado = false,
    Map<String, dynamic>? atributosEspeciales,
    required this.costoMetroOrigen,
    required this.costoRolloOrigen,
  }) : uid = uid ?? const Uuid().v4(),
       atributosEspeciales = atributosEspeciales != null
           ? Map<String, dynamic>.from(atributosEspeciales)
           : {};
}
