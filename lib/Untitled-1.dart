class Rollo {
  // ... campos existentes
  final bool activo; // ✅ NUEVO
  final String? usuarioCreadorId; // ✅ NUEVO
  final String? usuarioEliminadorId; // ✅ NUEVO
  final DateTime? fechaEliminacion; // ✅ NUEVO

  Rollo({
    // ... constructores existentes
    this.activo = true, 
    this.usuarioCreadorId,
    this.usuarioEliminadorId,
    this.fechaEliminacion,
  });

  factory Rollo.fromJson(Map<String, dynamic> json) => Rollo(
    // ... mapeos existentes
    activo: json['activo'] ?? true,
    usuarioCreadorId: json['usuarioCreadorId'],
    usuarioEliminadorId: json['usuarioEliminadorId'],
    fechaEliminacion: json['fechaEliminacion'] != null 
        ? DateTime.parse(json['fechaEliminacion']) 
        : null,
  );

  Map<String, dynamic> toJson() => {
    // ... mapeos existentes
    'activo': activo,
    'usuarioCreadorId': usuarioCreadorId,
    'usuarioEliminadorId': usuarioEliminadorId,
    'fechaEliminacion': fechaEliminacion?.toIso8601String(),
  };
}