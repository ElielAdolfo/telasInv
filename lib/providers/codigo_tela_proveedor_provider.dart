import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:inv_telas/models/lotes/codigo_tela_proveedor.dart';
import '../services/codigo_tela_proveedor_service.dart';

final codigoTelaProveedorServiceProvider = Provider(
  (ref) => CodigoTelaProveedorService(),
);

final codigoTelaProveedorNotifierProvider =
    StateNotifierProvider<CodigoTelaProveedorNotifier, AsyncValue<void>>(
      (ref) => CodigoTelaProveedorNotifier(ref),
    );

class CodigoTelaProveedorNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  CodigoTelaProveedorNotifier(this.ref) : super(const AsyncData(null));

  Future<bool> existe({
    required String empresaId,
    required String proveedorId,
    required String tipoTelaId,
  }) {
    return ref
        .read(codigoTelaProveedorServiceProvider)
        .existe(
          empresaId: empresaId,
          proveedorId: proveedorId,
          tipoTelaId: tipoTelaId,
        );
  }

  Future<void> create(CodigoTelaProveedor data) async {
    state = const AsyncLoading();
    try {
      await ref.read(codigoTelaProveedorServiceProvider).create(data);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> update(CodigoTelaProveedor data) async {
    state = const AsyncLoading();

    try {
      await ref.read(codigoTelaProveedorServiceProvider).update(data);

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
