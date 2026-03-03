import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:inv_telas/models/models.dart';
import 'package:inv_telas/services/services.dart';

// --- SERVICES ---
final rolloServiceProvider = Provider<RolloService>((ref) => RolloService());
final catalogServiceProvider = Provider<CatalogService>(
  (ref) => CatalogService(),
);

// --- CATALOGS STATE ---
final empresasProvider =
    StateNotifierProvider<CatalogNotifier<Empresa>, List<Empresa>>((ref) {
      return CatalogNotifier<Empresa>(
        ref.watch(catalogServiceProvider),
        (s) => s.getEmpresas(),
      );
    });

final sucursalesProvider =
    StateNotifierProvider<CatalogNotifier<Sucursal>, List<Sucursal>>((ref) {
      return CatalogNotifier<Sucursal>(
        ref.watch(catalogServiceProvider),
        (s) => s.getSucursales(),
      );
    });

final coloresProvider =
    StateNotifierProvider<CatalogNotifier<ColorTela>, List<ColorTela>>((ref) {
      return CatalogNotifier<ColorTela>(
        ref.watch(catalogServiceProvider),
        (s) => s.getColores(),
      );
    });

final tiposTelaProvider =
    StateNotifierProvider<CatalogNotifier<TipoTela>, List<TipoTela>>((ref) {
      return CatalogNotifier<TipoTela>(
        ref.watch(catalogServiceProvider),
        (s) => s.getTiposTela(),
      );
    });

// Generic Catalog Notifier
class CatalogNotifier<T> extends StateNotifier<List<T>> {
  final CatalogService _service;
  final Future<List<T>> Function(CatalogService) _fetcher;

  CatalogNotifier(this._service, this._fetcher) : super([]) {
    load();
  }

  Future<void> load() async {
    state = await _fetcher(_service);
  }

  // Método genérico para agregar (se asume que el modelo tiene id y toJson)
  Future<void> add(dynamic item, Future<void> Function() serviceAdd) async {
    await serviceAdd();
    await load();
  }
}

// --- ROLLOS STATE ---
final rollosProvider =
    StateNotifierProvider<RollosNotifier, AsyncValue<List<Rollo>>>((ref) {
      return RollosNotifier(ref.watch(rolloServiceProvider));
    });

class RollosNotifier extends StateNotifier<AsyncValue<List<Rollo>>> {
  final RolloService _service;
  RollosNotifier(this._service) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      print("🔄 Intentando conectar a Firebase...");

      final data = await _service.getAllRollos();

      print("✅ Conectado correctamente a Firebase");
      print("📦 Documentos obtenidos: ${data.length}");

      state = AsyncValue.data(data);
    } catch (e, st) {
      print("❌ ERROR al conectar con Firebase");
      print("🧨 Detalle: $e");
      print("📌 StackTrace: $st");

      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async => await _load();

  Future<bool> crearRollos(List<Rollo> rollos) async {
    try {
      await _service.createRollos(rollos);
      await refresh();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> actualizarSucursal(
    String id,
    String? sucursal, {
    String? tipo,
  }) async {
    try {
      await _service.updateSucursal(id, sucursal, tipoMovimiento: tipo);
      await refresh();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> eliminarRollo(String id) async {
    try {
      await _service.deleteRollo(id);
      await refresh();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> actualizarMetraje(String id, double metraje) async {
    try {
      await _service.updateMetraje(id, metraje);
      await refresh();
      return true;
    } catch (_) {
      return false;
    }
  }
}

// --- ESTADÍSTICAS ---
final estadisticasProvider = Provider<Map<String, dynamic>>((ref) {
  final rollosState = ref.watch(rollosProvider);
  return rollosState.when(
    data: (rollos) {
      final setEmpresas = rollos.map((r) => r.empresa).toSet();
      final setSucursales = rollos
          .where((r) => r.sucursal != null)
          .map((r) => r.sucursal!)
          .toSet();

      return {
        'totalRollos': rollos.length,
        'metrajeTotal': rollos.fold<double>(0, (s, r) => s + r.metraje),
        'empresas': setEmpresas.length,
        'sucursales': setSucursales.length,
        'colores': rollos.map((r) => r.color).toSet().length,
      };
    },
    loading: () => {
      'totalRollos': 0,
      'metrajeTotal': 0.0,
      'empresas': 0,
      'sucursales': 0,
      'colores': 0,
    },
    error: (_, __) => {
      'totalRollos': 0,
      'metrajeTotal': 0.0,
      'empresas': 0,
      'sucursales': 0,
      'colores': 0,
    },
  );
});
