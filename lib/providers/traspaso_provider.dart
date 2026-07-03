import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/ventas/stock_actual.dart';
import '../services/traspaso_service.dart';

final traspasoServiceProvider = Provider<TraspasoService>(
  (ref) => TraspasoService(),
);

class TraspasoState {
  final List<StockActual> items;
  final Set<String> seleccionadosIds;
  final bool isLoading;
  final String? sucursalOrigenId;

  TraspasoState({
    this.items = const [],
    this.seleccionadosIds = const {},
    this.isLoading = false,
    this.sucursalOrigenId,
  });

  TraspasoState copyWith({
    List<StockActual>? items,
    Set<String>? seleccionadosIds,
    bool? isLoading,
    String? sucursalOrigenId,
  }) {
    return TraspasoState(
      items: items ?? this.items,
      seleccionadosIds: seleccionadosIds ?? this.seleccionadosIds,
      isLoading: isLoading ?? this.isLoading,
      sucursalOrigenId: sucursalOrigenId ?? this.sucursalOrigenId,
    );
  }
}

class TraspasoNotifier extends StateNotifier<TraspasoState> {
  final TraspasoService _service;

  TraspasoNotifier(this._service) : super(TraspasoState());

  Future<void> cargarStock(String? sucursalId) async {
    state = state.copyWith(
      isLoading: true,
      sucursalOrigenId: sucursalId,
      seleccionadosIds: {},
    );
    try {
      final items = await _service.obtenerStockPorSucursal(sucursalId);
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  void toggleSeleccion(String id) {
    final nuevos = Set<String>.from(state.seleccionadosIds);
    if (nuevos.contains(id)) {
      nuevos.remove(id);
    } else {
      nuevos.add(id);
    }
    state = state.copyWith(seleccionadosIds: nuevos);
  }

  void seleccionarTodoElLote(String loteId) {
    final nuevos = Set<String>.from(state.seleccionadosIds);
    final itemsDelLote = state.items.where((item) => item.loteId == loteId);

    // Si todos los del lote ya están seleccionados, los deseleccionamos. Si no, los añadimos.
    final todosSeleccionados = itemsDelLote.every(
      (item) => nuevos.contains(item.id),
    );

    for (var item in itemsDelLote) {
      if (todosSeleccionados) {
        nuevos.remove(item.id);
      } else {
        nuevos.add(item.id);
      }
    }
    state = state.copyWith(seleccionadosIds: nuevos);
  }

  void limpiarSeleccion() {
    state = state.copyWith(seleccionadosIds: {});
  }
}

final traspasoProvider = StateNotifierProvider<TraspasoNotifier, TraspasoState>(
  (ref) {
    return TraspasoNotifier(ref.watch(traspasoServiceProvider));
  },
);
