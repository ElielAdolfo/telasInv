// lib/providers/registro_diario_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:inv_telas/models/ventas/registro_diario.dart';
import 'package:inv_telas/providers/carrito_provider.dart';
import 'package:inv_telas/providers/registro_diario_state.dart';
import 'package:inv_telas/services/registro_diario_service.dart';

class RegistroDiarioNotifier extends StateNotifier<RegistroDiarioState> {
  final RegistroDiarioService _service = RegistroDiarioService();
  final Ref _ref;

  RegistroDiarioNotifier(this._ref) : super(const RegistroDiarioState());

  Future<bool> ejecutarVentaDirecta({
    required String usuarioId,
    required String usuarioNombre,
    required String sucursalId,
  }) async {
    // Evitar doble submit si ya está procesando
    if (state.procesando) return false;

    final carrito = _ref.read(carritoVentasProvider);
    if (carrito.items.isEmpty) {
      state = state.copyWith(error: "El carrito está vacío");
      return false;
    }

    state = state.copyWith(procesando: true, error: null, exito: false);

    try {
      final nuevaVenta = RegistroDiario(
        usuarioId: usuarioId,
        usuarioNombre: usuarioNombre,
        sucursalId: sucursalId,
        totalVenta: carrito.total,
        totalRollos: carrito.totalRollos,
        totalMetros: carrito.totalMetros,
        fechaVenta: DateTime.now(),
        itemsVendidos: carrito.items,
      );

      // Llama a la transacción asíncrona de Firestore
      await _service.procesarVentaTransaccional(venta: nuevaVenta);

      // Si todo sale bien, limpiamos el carrito local y remoto de inmediato
      _ref.read(carritoVentasProvider.notifier).limpiar();

      state = state.copyWith(procesando: false, exito: true);
      return true;
    } catch (e) {
      state = state.copyWith(
        procesando: false,
        error: e.toString(),
        exito: false,
      );
      return false;
    }
  }

  void resetearEstado() {
    state = const RegistroDiarioState();
  }
}

final registroDiarioProvider =
    StateNotifierProvider<RegistroDiarioNotifier, RegistroDiarioState>((ref) {
      return RegistroDiarioNotifier(ref);
    });
