import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/ventas/jornada_laboral.dart';
import '../services/ventas_service.dart';

final ventasServiceProvider = Provider<VentasService>((ref) {
  return VentasService();
});

final jornadaActivaProvider = StateNotifierProvider.autoDispose
    .family<JornadaNotifier, AsyncValue<JornadaLaboral?>, String>((
      ref,
      sucursalId,
    ) {
      final service = ref.read(ventasServiceProvider);

      return JornadaNotifier(service, sucursalId);
    });

class JornadaNotifier extends StateNotifier<AsyncValue<JornadaLaboral?>> {
  final VentasService _service;
  final String _sucursalId;

  JornadaNotifier(this._service, this._sucursalId)
    : super(const AsyncValue.loading()) {
    verificarJornada();
  }

  String _fechaHoy() {
    final ahora = DateTime.now();

    return "${ahora.year}-${ahora.month.toString().padLeft(2, '0')}-${ahora.day.toString().padLeft(2, '0')}";
  }

  Future<void> verificarJornada() async {
    try {
      print('======================================');
      print('🔍 VERIFICANDO JORNADA');
      print('Sucursal: $_sucursalId');
      print('======================================');

      state = const AsyncValue.loading();

      final abierta = await _service.obtenerJornadaActiva(_sucursalId);

      if (abierta != null) {
        print('✅ Jornada abierta encontrada');
        state = AsyncValue.data(abierta);
        return;
      }

      print('ℹ️ No hay jornada abierta');

      final ultima = await _service.obtenerUltimaJornadaDeHoy(
        _sucursalId,
        _fechaHoy(),
      );

      print('✅ Última jornada obtenida');

      state = AsyncValue.data(ultima);
    } catch (e, st) {
      print('');
      print('======================================');
      print('❌ ERROR VERIFICANDO JORNADA');
      print('Sucursal: $_sucursalId');
      print('Error: $e');
      print('StackTrace:');
      print(st);
      print('======================================');
      print('');

      state = AsyncValue.error(e, st);
    }
  }

  Future<void> inicializarApertura({
    required String empresaId,
    required String usuarioId,
    required double tc,
    required double cajaInicial,
  }) async {
    final abierta = await _service.obtenerJornadaActiva(_sucursalId);

    if (abierta != null) {
      throw Exception('Ya existe una jornada abierta.');
    }

    final nueva = JornadaLaboral(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      empresaId: empresaId,
      sucursalId: _sucursalId,
      usuarioId: usuarioId,
      tipoCambio: tc,
      cajaInicialBs: cajaInicial,
      fechaApertura: DateTime.now(),
      abierta: true,
      fechaDia: _fechaHoy(),
      reaperturas: 0,
    );

    await _service.registrarJornada(nueva);

    state = AsyncValue.data(nueva);
  }

  Future<void> reabrirJornadaExistente() async {
    final jornada = state.value;

    if (jornada == null) {
      throw Exception('No existe jornada para reabrir.');
    }

    if (jornada.abierta) {
      throw Exception('La jornada ya está abierta.');
    }

    if (jornada.reaperturas >= 2) {
      throw Exception('La jornada alcanzó el límite de 2 reaperturas.');
    }

    final reabierta = jornada.copyWith(
      abierta: true,
      fechaCierre: null,
      cajaFinalBs: null,
      reaperturas: jornada.reaperturas + 1,
    );

    await _service.actualizarJornada(reabierta);

    state = AsyncValue.data(reabierta);
  }

  Future<void> cerrarJornadaEnCaja(double cajaFinalBs) async {
    final jornada = state.value;

    if (jornada == null) return;

    final cerrada = jornada.copyWith(
      abierta: false,
      cajaFinalBs: cajaFinalBs,
      fechaCierre: DateTime.now(),
    );

    await _service.actualizarJornada(cerrada);

    state = AsyncValue.data(cerrada);
  }
}
