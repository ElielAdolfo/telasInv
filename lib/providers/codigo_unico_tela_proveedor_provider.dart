import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:inv_telas/models/codigosTelaProveedor/codigo_unico_tela_proveedor.dart';

import '../services/codigo_unico_tela_proveedor_service.dart';

/// ==========================================================
/// SERVICE PROVIDER
/// ==========================================================
final codigoUnicoTelaProveedorServiceProvider =
    Provider<CodigoUnicoTelaProveedorService>(
      (ref) => CodigoUnicoTelaProveedorService(),
    );

/// ==========================================================
/// FUTURE PROVIDERS
/// ==========================================================

final codigosUnicoTelaProveedorProvider =
    FutureProvider.family<List<CodigoUnicoTelaProveedor>, String>((
      ref,
      empresaId,
    ) async {
      return ref
          .read(codigoUnicoTelaProveedorServiceProvider)
          .getByEmpresa(empresaId);
    });

final codigoUnicoTelaProveedorByIdProvider =
    FutureProvider.family<CodigoUnicoTelaProveedor?, String>((ref, id) async {
      return ref.read(codigoUnicoTelaProveedorServiceProvider).getById(id);
    });

final codigoUnicoTelaProveedorByProveedorTipoProvider =
    FutureProvider.family<
      CodigoUnicoTelaProveedor?,
      ({String empresaId, String proveedorId, String tipoTelaId})
    >((ref, params) async {
      return ref
          .read(codigoUnicoTelaProveedorServiceProvider)
          .getByProveedorTipo(
            empresaId: params.empresaId,
            proveedorId: params.proveedorId,
            tipoTelaId: params.tipoTelaId,
          );
    });

/// ==========================================================
/// NOTIFIER
/// ==========================================================
final codigoUnicoTelaProveedorNotifierProvider =
    StateNotifierProvider<CodigoUnicoTelaProveedorNotifier, AsyncValue<void>>(
      (ref) => CodigoUnicoTelaProveedorNotifier(ref),
    );

class CodigoUnicoTelaProveedorNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  CodigoUnicoTelaProveedorNotifier(this.ref) : super(const AsyncData(null));

  Future<bool> existe({
    required String empresaId,
    required String proveedorId,
    required String tipoTelaId,
  }) {
    return ref
        .read(codigoUnicoTelaProveedorServiceProvider)
        .existe(
          empresaId: empresaId,
          proveedorId: proveedorId,
          tipoTelaId: tipoTelaId,
        );
  }

  Future<void> create(CodigoUnicoTelaProveedor data) async {
    state = const AsyncLoading();

    try {
      await ref.read(codigoUnicoTelaProveedorServiceProvider).create(data);

      ref.invalidate(codigosUnicoTelaProveedorProvider(data.empresaId));

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> update(CodigoUnicoTelaProveedor data) async {
    state = const AsyncLoading();

    try {
      await ref.read(codigoUnicoTelaProveedorServiceProvider).update(data);

      ref.invalidate(codigosUnicoTelaProveedorProvider(data.empresaId));

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> delete({
    required String id,
    required String usuario,
    required String empresaId,
  }) async {
    state = const AsyncLoading();

    try {
      await ref
          .read(codigoUnicoTelaProveedorServiceProvider)
          .delete(id, usuario);

      ref.invalidate(codigosUnicoTelaProveedorProvider(empresaId));

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}
