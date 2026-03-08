import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:inv_telas/models/models.dart';
import 'package:inv_telas/services/services.dart';
import 'package:inv_telas/services/local_storage_service.dart';

final anchosProvider =
    StateNotifierProvider<CatalogNotifier<Ancho>, List<Ancho>>((ref) {
      return CatalogNotifier<Ancho>(
        ref.watch(catalogServiceProvider),
        (s) => s.getAnchos(), // Método que agregamos en CatalogService
      );
    });

// --- SERVICES ---
final rolloServiceProvider = Provider<RolloService>((ref) => RolloService());
final catalogServiceProvider = Provider<CatalogService>(
  (ref) => CatalogService(),
);

// ✅ LOCAL STORAGE SERVICE
final localStorageProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

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

// --- GENERIC CATALOG NOTIFIER ---
class CatalogNotifier<T> extends StateNotifier<List<T>> {
  final CatalogService _service;
  final Future<List<T>> Function(CatalogService) _fetcher;

  CatalogNotifier(this._service, this._fetcher) : super([]) {
    load();
  }

  Future<void> load() async {
    try {
      final data = await _fetcher(_service);

      if (mounted) {
        state = data;
      }
    } catch (e) {
      print('Error cargando catálogo: $e');
    }
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
    String? sucursalId, {
    String? tipo,
  }) async {
    try {
      await _service.updateSucursal(id, sucursalId, tipoMovimiento: tipo);
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

// --- BORRADORES (SHARED PREFERENCES) ---
final draftsProvider = StateNotifierProvider<DraftsNotifier, List<Rollo>>((
  ref,
) {
  return DraftsNotifier(ref.watch(localStorageProvider));
});

class DraftsNotifier extends StateNotifier<List<Rollo>> {
  final LocalStorageService _localService;

  DraftsNotifier(this._localService) : super([]) {
    _load();
  }

  Future<void> _load() async {
    state = await _localService.getDrafts();
  }

  Future<void> add(Rollo rollo) async {
    await _localService.addDraft(rollo);
    await _load();
  }

  Future<void> remove(String id) async {
    await _localService.removeDraft(id);
    await _load();
  }

  Future<void> clearAll() async {
    await _localService.clearDrafts();
    state = [];
  }
}

// --- ESTADÍSTICAS ---
final estadisticasProvider = Provider<Map<String, dynamic>>((ref) {
  final rollosState = ref.watch(rollosProvider);

  return rollosState.when(
    data: (rollos) {
      final setEmpresas = rollos.map((r) => r.empresaId).toSet();

      final setSucursales = rollos
          .where((r) => r.sucursalId != null)
          .map((r) => r.sucursalId!)
          .toSet();

      final setColores = rollos.map((r) => r.colorId).toSet();

      return {
        'totalRollos': rollos.length,
        'metrajeTotal': rollos.fold<double>(0, (s, r) => s + r.metraje),
        'empresas': setEmpresas.length,
        'sucursales': setSucursales.length,
        'colores': setColores.length,
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
