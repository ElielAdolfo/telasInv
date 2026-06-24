import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/models/lotes/lote_detalle.dart';
import '../services/lote_detalle_service.dart';
import 'package:flutter_riverpod/legacy.dart';

final loteDetalleServiceProvider = Provider<LoteDetalleService>((ref) {
  return LoteDetalleService();
});

final loteDetallesProvider =
    StateNotifierProvider.family<
      LoteDetalleNotifier,
      AsyncValue<List<LoteDetalle>>,
      String
    >((ref, loteId) {
      final service = ref.watch(loteDetalleServiceProvider);
      return LoteDetalleNotifier(service, loteId);
    });

class LoteDetalleNotifier extends StateNotifier<AsyncValue<List<LoteDetalle>>> {
  final LoteDetalleService _service;
  final String loteId;

  LoteDetalleNotifier(this._service, this.loteId)
    : super(const AsyncValue.loading()) {
    load();
  }

  //==================================================
  // CARGA INICIAL
  //==================================================
  Future<void> load() async {
    try {
      state = const AsyncValue.loading();

      final data = await _service.getByLote(loteId);

      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  //==================================================
  // RECARGAR MANUAL (cuando vuelves o guardas)
  //==================================================
  Future<void> refresh() async {
    await load();
  }

  //==================================================
  // GUARDAR
  //==================================================
  Future<void> guardar(LoteDetalle detalle) async {
    await _service.save(detalle);
    await load(); // recarga completa
  }

  //==================================================
  // ELIMINAR
  //==================================================
  Future<void> eliminar(String id) async {
    await _service.delete(id, "");
    await load(); // recarga completa
  }
}
