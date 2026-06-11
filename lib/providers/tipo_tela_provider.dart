import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:inv_telas/models/abmTiposTelas/tipo_tela.dart';

import '../services/tipo_tela_service.dart';

/// ==========================================================
/// SERVICE
/// ==========================================================
final tipoTelaServiceProvider = Provider<TipoTelaService>(
  (ref) => TipoTelaService(),
);

/// ==========================================================
/// LISTADO
/// ==========================================================
final tiposTelaProvider = FutureProvider.family<List<TipoTela>, String>((
  ref,
  empresaId,
) async {
  final service = ref.read(tipoTelaServiceProvider);

  return service.getByEmpresa(empresaId);
});

/// ==========================================================
/// STREAM
/// ==========================================================
final tiposTelaStreamProvider = StreamProvider.family<List<TipoTela>, String>((
  ref,
  empresaId,
) {
  final service = ref.read(tipoTelaServiceProvider);

  return service.streamEmpresa(empresaId);
});

/// ==========================================================
/// DETALLE
/// ==========================================================
final tipoTelaProvider = FutureProvider.family<TipoTela?, String>((
  ref,
  id,
) async {
  final service = ref.read(tipoTelaServiceProvider);

  return service.getById(id);
});

/// ==========================================================
/// NOTIFIER
/// ==========================================================
class TipoTelaNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  TipoTelaNotifier(this.ref) : super(const AsyncData(null));

  TipoTelaService get _service => ref.read(tipoTelaServiceProvider);

  /// ==========================================================
  /// CREAR
  /// ==========================================================
  Future<void> create(TipoTela tipoTela) async {
    state = const AsyncLoading();

    try {
      await _service.create(tipoTela);

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);

      rethrow;
    }
  }

  /// ==========================================================
  /// UPDATE
  /// ==========================================================
  Future<void> update(TipoTela tipoTela) async {
    state = const AsyncLoading();

    try {
      await _service.update(tipoTela);

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);

      rethrow;
    }
  }

  /// ==========================================================
  /// ELIMINAR
  /// ==========================================================
  Future<void> delete({
    required String tipoTelaId,
    required String usuarioId,
  }) async {
    state = const AsyncLoading();

    try {
      await _service.delete(tipoTelaId: tipoTelaId, usuarioId: usuarioId);

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);

      rethrow;
    }
  }

  /// ==========================================================
  /// VALIDAR NOMBRE
  /// ==========================================================
  Future<bool> existeNombre({
    required String empresaId,
    required String nombre,
    String? excluirId,
  }) async {
    return _service.existeNombre(
      empresaId: empresaId,
      nombre: nombre,
      excluirId: excluirId,
    );
  }
}

/// ==========================================================
/// NOTIFIER PROVIDER
/// ==========================================================
final tipoTelaNotifierProvider =
    StateNotifierProvider<TipoTelaNotifier, AsyncValue<void>>(
      (ref) => TipoTelaNotifier(ref),
    );
