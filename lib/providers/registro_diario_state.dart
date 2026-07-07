// lib/providers/registro_diario_state.dart
class RegistroDiarioState {
  final bool procesando;
  final String? error;
  final bool exito;

  const RegistroDiarioState({
    this.procesando = false,
    this.error,
    this.exito = false,
  });

  RegistroDiarioState copyWith({bool? procesando, String? error, bool? exito}) {
    return RegistroDiarioState(
      procesando: procesando ?? this.procesando,
      error: error, // Si es nulo se limpia
      exito: exito ?? this.exito,
    );
  }
}
