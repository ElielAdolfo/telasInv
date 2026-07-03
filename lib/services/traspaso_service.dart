import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/env.dart';
import '../models/ventas/stock_actual.dart';

class TraspasoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _stockRef =>
      _db.collection(Env.col('stock_actual'));

  /// Obtiene los rollos en stock filtrando estrictamente desde el servidor (sin caché)
  Future<List<StockActual>> obtenerStockPorSucursal(String? sucursalId) async {
    Query<Map<String, dynamic>> query = _stockRef.where(
      'estado',
      isEqualTo: 'CERRADO',
    );

    if (sucursalId == null ||
        sucursalId.isEmpty ||
        sucursalId == 'SIN_SUCURSAL') {
      // Filtrar los que no tienen sucursal asignada o están vacíos
      query = query.where('sucursalActualId', whereIn: ['', 'SIN_SUCURSAL']);
    } else {
      query = query.where('sucursalActualId', isEqualTo: sucursalId);
    }

    final snapshot = await query.get(const GetOptions(source: Source.server));

    return snapshot.docs.map((doc) {
      return StockActual.fromJson({...doc.data(), 'id': doc.id});
    }).toList();
  }

  /// Ejecuta el traspaso atómico en lote para una lista de IDs de rollos de stock
  Future<void> ejecutarTraspasoMasivo({
    required List<String> stockIds,
    required String nuevaSucursalId,
    required String usuarioId,
  }) async {
    if (stockIds.isEmpty) return;

    final WriteBatch batch = _db.batch();
    final now = DateTime.now().toIso8601String();

    for (String id in stockIds) {
      final docRef = _stockRef.doc(id);
      batch.update(docRef, {
        'sucursalActualId': nuevaSucursalId,
        'fechaActualizacion': now,
        'usuarioModificadorId': usuarioId,
      });
    }

    await batch.commit();
  }
}
