import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/abmTiposTelas/color_tela.dart';
import '../services/color_service.dart';

/// Provider base para acceder a la instancia del servicio de colores
final colorServiceProvider = Provider<ColorService>((ref) => ColorService());

/// Notificador que maneja la suscripción al flujo de datos y mutaciones CRUD
class ColorNotifier extends StateNotifier<AsyncValue<List<ColorTela>>> {
  final ColorService _service;
  final String _empresaId;
  StreamSubscription<List<ColorTela>>? _subscription;

  ColorNotifier({required ColorService service, required String empresaId})
    : _service = service,
      _empresaId = empresaId,
      super(const AsyncValue.loading()) {
    _iniciarEscucha();
  }

  void _iniciarEscucha() {
    _subscription?.cancel();
    _subscription = _service
        .streamColoresPorEmpresa(_empresaId)
        .listen(
          (colores) {
            state = AsyncValue.data(colores);
          },
          onError: (error, stackTrace) {
            state = AsyncValue.error(error, stackTrace);
          },
        );
  }

  /// Procesa tanto la inserción como la edición de un color
  Future<void> guardarColor({
    String? id,
    required String nombre,
    required String hexadecimal,
    required String usuarioId,
  }) async {
    if (id == null || id.trim().isEmpty) {
      // Flujo de Creación
      final nuevoColor = ColorTela(
        id: '',
        empresaId: _empresaId,
        nombre: nombre,
        hexadecimal: hexadecimal,
        usuarioCreadorId: usuarioId,
      );
      await _service.crearColor(nuevoColor);
    } else {
      // Flujo de Edición (recuperamos el estado previo de la lista para conservar datos base)
      final listaActual = state.value ?? [];
      final colorPrevio = listaActual.firstWhere((c) => c.id == id);

      final colorEditado = colorPrevio.copyWith(
        nombre: nombre,
        hexadecimal: hexadecimal,
        usuarioModificadorId: usuarioId,
      );
      await _service.actualizarColor(colorEditado);
    }
  }

  /// Ejecuta la baja lógica del color
  Future<void> eliminarColor(String id, String usuarioId) async {
    await _service.modificarEstadoEliminado(
      id: id,
      eliminado: true,
      usuarioId: usuarioId,
    );
  }

  /// Restaura un color eliminado lógicamente (Si se requiere en auditorías futuras)
  Future<void> restaurarColor(String id, String usuarioId) async {
    await _service.modificarEstadoEliminado(
      id: id,
      eliminado: false,
      usuarioId: usuarioId,
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// Provider familiar reactivo que expone la lista de colores basados en la Empresa activa.
/// Uso en UI: ref.watch(coloresProvider(empresaIdActual));
final coloresProvider =
    StateNotifierProvider.family<
      ColorNotifier,
      AsyncValue<List<ColorTela>>,
      String
    >((ref, empresaId) {
      final service = ref.watch(colorServiceProvider);
      return ColorNotifier(service: service, empresaId: empresaId);
    });
