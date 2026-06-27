import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:inv_telas/models/lotes/gastos.dart';
import '../services/gasto_service.dart';

final gastoServiceProvider = Provider<GastoService>((ref) {
  return GastoService();
});

typedef GastoArgs = ({String empresaId, String loteId});

class GastoNotifier extends StateNotifier<AsyncValue<List<Gasto>>> {
  final GastoService _service;
  final GastoArgs _args;

  GastoNotifier({required GastoService service, required GastoArgs args})
    : _service = service,
      _args = args,
      super(const AsyncValue.loading()) {
    cargarGastos();
  }

  Future<void> cargarGastos() async {
    state = const AsyncValue.loading();
    try {
      final lista = await _service.obtenerGastosPorLote(
        _args.empresaId,
        _args.loteId,
      );
      state = AsyncValue.data(lista);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> guardarGasto({
    required Gasto gasto,
    required String usuarioId,
  }) async {
    try {
      if (gasto.id.isEmpty) {
        // Al crear, delegamos al servicio y agregamos localmente al estado
        await _service.crearGasto(gasto);
        state.whenData((listaActual) {
          state = AsyncValue.data([...listaActual, gasto]);
        });
      } else {
        final editado = gasto.copyWith(
          usuarioModificacion: usuarioId,
          fechaModificacion: DateTime.now(),
        );
        await _service.actualizarGasto(editado);

        // Al editar, reemplazamos el objeto correspondiente en el estado local
        state.whenData((listaActual) {
          state = AsyncValue.data([
            for (final g in listaActual) g.id == editado.id ? editado : g,
          ]);
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> eliminarGasto(String id, String usuarioId) async {
    try {
      await _service.modificarEstadoEliminado(
        id: id,
        eliminado: true,
        usuarioId: usuarioId,
      );

      // Al eliminar, removemos el item directamente del estado local
      state.whenData((listaActual) {
        state = AsyncValue.data(listaActual.where((g) => g.id != id).toList());
      });
    } catch (e) {
      rethrow;
    }
  }
}

final gastosLoteProvider =
    StateNotifierProvider.family<
      GastoNotifier,
      AsyncValue<List<Gasto>>,
      GastoArgs
    >((ref, args) {
      final service = ref.watch(gastoServiceProvider);
      return GastoNotifier(service: service, args: args);
    });
