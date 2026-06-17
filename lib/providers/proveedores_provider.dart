// archivo: providers/proveedores_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:inv_telas/models/abmTiposTelas/proveedor.dart';
// TODO: Reemplaza con la ruta correcta a tu modelo Proveedor
// TODO: Reemplaza con la ruta correcta al servicio definido arriba
import '../services/proveedor_service.dart';
// TODO: Reemplaza con la ruta correcta a tu sessionProvider (core)
import '../../../core/providers/session_provider.dart';

/// ==========================================================
/// SERVICE PROVIDER
/// Expone la instancia única del servicio de base de datos.
/// ==========================================================
final proveedorServiceProvider = Provider<ProveedorService>(
  (ref) => ProveedorService(),
);

/// ==========================================================
/// LISTADO (FutureProvider - Family)
/// Obtiene la lista de proveedores por empresa de forma puntual.
/// Este es el que usarás para cargar los Dropdowns al abrir un formulario.
/// ==========================================================
final proveedoresFutureProvider = FutureProvider.autoDispose
    .family<List<Proveedor>, String>((ref, empresaId) async {
      final service = ref.read(proveedorServiceProvider);

      return service.getByEmpresa(empresaId);
    });

/// ==========================================================
/// STREAM LISTADO (StreamProvider - Family)
/// *Opcional* para visualización en tiempo real si la necesitas.
/// ==========================================================
final proveedoresStreamProvider =
    StreamProvider.family<List<Proveedor>, String>((ref, empresaId) {
      final service = ref.read(proveedorServiceProvider);
      return service.streamEmpresa(empresaId);
    });

/// ==========================================================
/// NOTIFIER (Gestiona Acciones de Escritura: Crear, Actualizar, Borrar)
/// Maneja el estado de carga y errores durante las operaciones asíncronas.
/// ==========================================================
class ProveedorNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  // Inicialmente en estado de datos 'nulo' (sin acción en curso)
  ProveedorNotifier(this.ref) : super(const AsyncData(null));

  // Helper para leer el servicio fácilmente
  ProveedorService get _service => ref.read(proveedorServiceProvider);

  /// ==========================================================
  /// CREAR (Insertar en BD)
  /// Asumimos que el modelo Proveedor ya viene poblado con ID, IDs de auditoría y fechas.
  /// ==========================================================
  Future<void> create(Proveedor proveedor) async {
    // Ponemos el estado en carga para que el UI muestre loading (ej: en ConfirmActionDialog)
    state = const AsyncLoading();

    try {
      await _service.create(proveedor);

      // Si todo sale bien, volvemos a AsyncData para indicar éxito
      state = const AsyncData(null);
    } catch (e, st) {
      // Si hay error, actualizamos el estado con la excepción y stacktrace
      state = AsyncError(e, st);

      // Re-lanzamos para que quien llame (el diálogo) pueda mostrar un SnackBar si quiere
      rethrow;
    }
  }

  /// ==========================================================
  /// ACTUALIZAR (Modificar en BD)
  /// ==========================================================
  Future<void> update(Proveedor proveedor) async {
    state = const AsyncLoading();

    try {
      await _service.update(proveedor);

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  /// ==========================================================
  /// BORRAR (Baja Lógica en BD)
  /// Usamos el ID del proveedor y el ID del usuario actual expuesto en core providers.
  /// ==========================================================
  Future<void> delete({required String proveedorId}) async {
    state = const AsyncLoading();

    try {
      // Leemos el ID del usuario logueado actualmente desde el sessionProvider
      final usuarioId = ref.read(sessionProvider).usuario!.id;

      // Llamamos al borrado lógico del servicio
      await _service.delete(proveedorId: proveedorId, usuarioId: usuarioId);

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  // ==========================================================
  // VALIDACIÓN ASÍNCRONA
  // ==========================================================
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
/// Expone la lógica del ProveedorNotifier al UI.
/// ==========================================================
final proveedorNotifierProvider =
    StateNotifierProvider<ProveedorNotifier, AsyncValue<void>>(
      (ref) => ProveedorNotifier(ref),
    );
