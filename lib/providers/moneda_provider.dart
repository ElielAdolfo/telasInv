import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:inv_telas/models/moneda.dart';
import 'package:inv_telas/services/moneda_service.dart';

final monedaServiceProvider = Provider<MonedaService>((ref) => MonedaService());

class MonedaNotifier extends StateNotifier<AsyncValue<List<Moneda>>> {
  final MonedaService _service;
  final String empresaId;

  MonedaNotifier({required MonedaService service, required this.empresaId})
    : _service = service,
      super(const AsyncValue.loading());

  Future<void> cargarMonedas() async {
    try {
      state = const AsyncValue.loading();

      final monedas = await _service.obtenerMonedasPorEmpresa(empresaId);

      state = AsyncValue.data(monedas);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> guardarMoneda(Moneda moneda) async {
    try {
      if (moneda.id.isEmpty) {
        await _service.crearMoneda(moneda);
      } else {
        await _service.actualizarMoneda(moneda);
      }

      await cargarMonedas();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> eliminarMoneda({
    required String id,
    required String usuarioId,
  }) async {
    await _service.modificarEstadoEliminado(
      id: id,
      eliminado: true,
      usuarioId: usuarioId,
    );

    await cargarMonedas();
  }

  Future<void> restaurarMoneda({
    required String id,
    required String usuarioId,
  }) async {
    await _service.modificarEstadoEliminado(
      id: id,
      eliminado: false,
      usuarioId: usuarioId,
    );

    await cargarMonedas();
  }
}

final monedasProvider = StateNotifierProvider.autoDispose
    .family<MonedaNotifier, AsyncValue<List<Moneda>>, String>((ref, empresaId) {
      final service = ref.watch(monedaServiceProvider);

      final notifier = MonedaNotifier(service: service, empresaId: empresaId);

      notifier.cargarMonedas();

      ref.onDispose(() {
        print('🗑️ MONEDAS PROVIDER ELIMINADO');
      });

      return notifier;
    });
