import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:inv_telas/models/catalogos.dart';
import 'package:inv_telas/models/precio_venta.dart';
import 'package:inv_telas/models/usuario.dart';
import '../services/precio_service.dart';

// SERVICE
final precioServiceProvider = Provider<PrecioService>((ref) {
  return PrecioService();
});

// PRECIOS POR SUCURSAL
final preciosPorSucursalProvider =
    StateNotifierProvider.family<
      PreciosNotifier,
      AsyncValue<List<PrecioVenta>>,
      String
    >((ref, sucursalId) {
      return PreciosNotifier(ref.read(precioServiceProvider), sucursalId);
    });

class PreciosNotifier extends StateNotifier<AsyncValue<List<PrecioVenta>>> {
  final PrecioService _service;
  final String _sucursalId;

  PreciosNotifier(this._service, this._sucursalId)
    : super(const AsyncLoading()) {
    cargar();
  }

  Future<void> cargar() async {
    try {
      state = const AsyncLoading();

      final lista = await _service.obtenerPreciosPorSucursal(_sucursalId);

      state = AsyncData(lista);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // GUARDAR
  Future<void> guardar({
    required List<String> sucursalIds,
    required PrecioVenta precio,
    required Usuario usuario,
    String? telaNombre,
  }) async {
    try {
      await _service.guardarPrecio(
        sucursalIds: sucursalIds,
        precioBase: precio,
        usuarioId: usuario.id,
        usuarioNombre: usuario.nombre,
        telaNombre: telaNombre,
      );

      await cargar();
    } catch (e) {
      rethrow;
    }
  }

  // ELIMINAR
  Future<void> eliminar(String precioId, Usuario usuario) async {
    try {
      // AUN NO EXISTE EN TU SERVICE
      // Debes crear eliminarPrecio() en PrecioService

      // await _service.eliminarPrecio(precioId, usuario);

      await cargar();
    } catch (e) {
      rethrow;
    }
  }
}

// TELAS EN STOCK
final telasEnStockProvider = FutureProvider.family<List<TipoTela>, String>((
  ref,
  sucursalId,
) async {
  return ref
      .read(precioServiceProvider)
      .obtenerTelasEnStockSucursal(sucursalId);
});

final todosLosPreciosProvider = FutureProvider<List<PrecioVenta>>((ref) async {
  return ref.read(precioServiceProvider).obtenerTodosLosPrecios();
});
