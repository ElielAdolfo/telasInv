// lib/providers/ventas_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../services/ventas_service.dart';
import '../models/ventas/jornada_laboral.dart';

final ventasServiceProvider = Provider<VentasService>((ref) => VentasService());

// Mantiene en memoria el estado de la jornada actual (o null si está cerrada)
final jornadaActivaProvider = FutureProvider.family<JornadaLaboral?, String>((
  ref,
  sucursalId,
) async {
  final service = ref.read(ventasServiceProvider);
  return service.obtenerJornadaActiva(sucursalId);
});

class JornadaNotifier extends StateNotifier<AsyncValue<JornadaLaboral?>> {
  final VentasService _service;
  JornadaNotifier(this._service) : super(const AsyncValue.loading());

  Future<void> verificarJornada(String sucursalId) async {
    try {
      state = const AsyncValue.loading();
      final jornada = await _service.obtenerJornadaActiva(sucursalId);
      state = AsyncValue.data(jornada);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> inicializarApertura({
    required String empresaId,
    required String sucursalId,
    required String usuarioId,
    required double tc,
    required double cajaInicial,
  }) async {
    final nueva = JornadaLaboral(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      empresaId: empresaId,
      sucursalId: sucursalId,
      usuarioId: usuarioId,
      tipoCambio: tc,
      cajaInicialBs: cajaInicial,
      fechaApertura: DateTime.now(),
      abierta: true,
    );
    await _service.abrirJornada(nueva);
    state = AsyncValue.data(nueva);
  }

  Future<void> forzarCierre(double cajaFinal) async {
    if (state.value == null) return;
    await _service.cerrarJornada(state.value!.id, cajaFinal);
    state = const AsyncValue.data(null);
  }
}
