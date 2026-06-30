import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:inv_telas/models/lotes/lote.dart';

import '../services/lote_service.dart';

final loteServiceProvider = Provider<LoteService>((ref) => LoteService());

class LoteNotifier extends StateNotifier<AsyncValue<List<Lote>>> {
  final LoteService _service;
  final String empresaId;

  LoteNotifier({required LoteService service, required this.empresaId})
    : _service = service,
      super(const AsyncValue.loading());

  Future<void> cargarLotes() async {
    try {
      state = const AsyncValue.loading();

      final lotes = await _service.obtenerLotesPorEmpresa(empresaId);

      state = AsyncValue.data(lotes);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> guardarLote(Lote lote, {required bool isEdit}) async {
    try {
      if (!isEdit) {
        await _service.crearLote(lote);
      } else {
        await _service.actualizarLote(lote);
      }
      await cargarLotes();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      // Volvemos a lanzar el error para que el diálogo UI también pueda enterarse
      rethrow;
    }
  }

  Future<void> eliminarLote({
    required String loteId,
    required String usuarioId,
  }) async {
    await _service.eliminarLote(loteId: loteId, usuarioId: usuarioId);

    await cargarLotes();
  }

  Future<void> restaurarLote({
    required String loteId,
    required String usuarioId,
  }) async {
    await _service.restaurarLote(loteId: loteId, usuarioId: usuarioId);

    await cargarLotes();
  }

  Future<void> recargar() async {
    await cargarLotes();
  }
  
}

final lotesProvider =
    StateNotifierProvider.family<LoteNotifier, AsyncValue<List<Lote>>, String>((
      ref,
      empresaId,
    ) {
      final service = ref.watch(loteServiceProvider);

      final notifier = LoteNotifier(service: service, empresaId: empresaId);

      notifier.cargarLotes();

      return notifier;
    });
