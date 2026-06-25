import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
// Nota: quité la importación de legacy.dart si no se usa, pero puedes mantenerla si la requieres
import '../models/abmTiposTelas/color_tela.dart';
import '../services/color_service.dart';

/// Provider base para acceder a la instancia del servicio de colores
final colorServiceProvider = Provider<ColorService>((ref) => ColorService());

/// Notificador que maneja la suscripción al flujo de datos y mutaciones CRUD (Globales)
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

// =============================================================================
// 🚀 NUEVA LÓGICA: FILTRADO CRUZADO (Empresa + Proveedor + TipoTela)
// =============================================================================

/// Modelo intermedio para mapear el Color maestro junto con su código específico de proveedor
class ColorFiltrado {
  final ColorTela color;
  final String codigoColorProveedor;

  ColorFiltrado({required this.color, required this.codigoColorProveedor});
}

/// Notificador que maneja el flujo de los colores asociados a una combinación específica
class ColoresFiltradosNotifier
    extends StateNotifier<AsyncValue<List<ColorFiltrado>>> {
  final ColorService _service;
  final String _empresaId;
  final String _proveedorId;
  final String _tipoTelaId;
  StreamSubscription? _combinacionSubscription;

  ColoresFiltradosNotifier({
    required ColorService service,
    required String empresaId,
    required String proveedorId,
    required String tipoTelaId,
  }) : _service = service,
       _empresaId = empresaId,
       _proveedorId = proveedorId,
       _tipoTelaId = tipoTelaId,
       super(const AsyncValue.loading()) {
    _cargarColoresRelacionados();
  }

  void _cargarColoresRelacionados() {
    _combinacionSubscription?.cancel();

    _combinacionSubscription = _service
        .streamColoresPorTelaProveedor(
          empresaId: _empresaId,
          proveedorId: _proveedorId,
          tipoTelaId: _tipoTelaId,
        )
        .listen(
          (coloresRelacionados) async {
            try {
              if (coloresRelacionados.isEmpty) {
                state = const AsyncValue.data([]);
                return;
              }

              // Recuperamos los colores maestros para cruzar los datos (Join)
              final coloresMaestros = await _service.getByEmpresa(_empresaId);
              final List<ColorFiltrado> resultado = [];

              for (var rel in coloresRelacionados) {
                final idBuscado = rel['colorId'];
                final codigoProv = rel['codigoColor'] ?? '';

                final colorMaestro = coloresMaestros.firstWhere(
                  (c) => c.id == idBuscado,
                  orElse: () => ColorTela(
                    id: '',
                    nombre: 'Desconocido',
                    hexadecimal: 'FFFFFF',
                    empresaId: _empresaId,
                    usuarioCreadorId: '',
                  ),
                );

                if (colorMaestro.id.isNotEmpty) {
                  resultado.add(
                    ColorFiltrado(
                      color: colorMaestro,
                      codigoColorProveedor: codigoProv,
                    ),
                  );
                }
              }

              state = AsyncValue.data(resultado);
            } catch (e, stack) {
              state = AsyncValue.error(e, stack);
            }
          },
          onError: (error, stackTrace) {
            state = AsyncValue.error(error, stackTrace);
          },
        );
  }

  @override
  void dispose() {
    _combinacionSubscription?.cancel();
    super.dispose();
  }
}

/// Provider que expone los colores filtrados por los tres parámetros usando un Record de Dart 3
final coloresFiltradosProvider =
    StateNotifierProvider.family<
      ColoresFiltradosNotifier,
      AsyncValue<List<ColorFiltrado>>,
      ({String empresaId, String proveedorId, String tipoTelaId})
    >((ref, arg) {
      final service = ref.watch(colorServiceProvider);
      return ColoresFiltradosNotifier(
        service: service,
        empresaId: arg.empresaId,
        proveedorId: arg.proveedorId,
        tipoTelaId: arg.tipoTelaId,
      );
    });
