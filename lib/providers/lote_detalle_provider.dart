import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:inv_telas/models/lotes/lote_detalle.dart';
import 'package:inv_telas/models/lotes/rollo_info.dart';
import '../services/lote_detalle_service.dart';

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

  // Un flag local para saber si está en proceso de guardado de rollos
  bool _isSavingRollos = false;
  bool get isSavingRollos => _isSavingRollos;

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
  // GUARDAR DETALLE
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

  //==================================================
  // ACCIONES PARA DISTRIBUCIÓN DE ROLLOS
  //==================================================

  /// Guarda los rollos independientes en lote (Batch) y retorna true si fue exitoso
  Future<bool> guardarRollos({
    required String
    loteDetalleId, // CORRECCIÓN: Quitamos el parámetro codigoUnicoId
    required List<RolloInfo> rollos,
  }) async {
    _isSavingRollos = true;
    // Notificamos un cambio de estado sin alterar los detalles ya cargados
    state = state;

    try {
      // CORRECCIÓN: Llamamos al servicio pasando únicamente lo requerido ahora
      await _service.guardarRollosIndependientes(
        loteDetalleId: loteDetalleId,
        rollos: rollos,
      );
      _isSavingRollos = false;
      state = state;
      return true;
    } catch (e) {
      _isSavingRollos = false;
      state = state;
      print("Error al guardar rollos en Notifier: $e");
      return false;
    }
  }

  /// Recupera los rollos directamente desde el servicio para rellenar tu pantalla de modificación
  Future<List<RolloInfo>> obtenerRollosPorDetalle({
    required String
    loteDetalleId, // CORRECCIÓN: Quitamos el parámetro codigoUnicoId
  }) async {
    try {
      // CORRECCIÓN: Ajustamos la llamada al servicio limpio
      return await _service.getRollosByDetalle(loteDetalleId: loteDetalleId);
    } catch (e) {
      print("Error al recuperar rollos en Notifier: $e");
      return [];
    }
  }
}
