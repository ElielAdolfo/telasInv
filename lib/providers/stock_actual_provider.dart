import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/stock_actual_service.dart';
import '../models/ventas/stock_actual.dart'; // Asegúrate de importar el modelo

// Mantiene la instancia del servicio
final stockActualServiceProvider = Provider<StockActualService>((ref) {
  return StockActualService();
});

// 🟢 NUEVO: Este proveedor sí devolverá un AsyncValue<List<StockActual>>
final stockActualListProvider = FutureProvider<List<StockActual>>((ref) async {
  final service = ref.watch(stockActualServiceProvider);
  return service.obtenerStock();
});
