// lib/services/stock_actual_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inv_telas/models/ventas/stock_actual.dart';
import '../config/env.dart';

class StockActualService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _stockRef =>
      _db.collection(Env.col('stock_actual'));

  /// Guarda múltiples instancias de stock físico usando lotes de escritura atómicos.
  Future<void> insertarStockMasivo(
    List<StockActual> items,
    WriteBatch batch,
  ) async {
    for (var item in items) {
      final docRef = _stockRef.doc(item.id);
      batch.set(docRef, item.toMap());
    }
  }

  /// 🟢 AGREGA ESTE MÉTODO para obtener el stock (puedes filtrarlo por sucursal si lo requieres)
  Future<List<StockActual>> obtenerStock() async {
    final snapshot = await _stockRef.get();
    return snapshot.docs.map((doc) {
      // Ajusta 'fromJson' o 'fromMap' según cómo esté construido tu modelo StockActual
      return StockActual.fromJson(doc.data());
    }).toList();
  }

  Future<List<StockActual>> obtenerStockPorSucursalYTipoTela(
    String sucursalId,
    String tipoTelaId,
  ) async {
    final snapshot = await _stockRef
        .where('sucursalActualId', isEqualTo: sucursalId)
        .where('tipoTelaId', isEqualTo: tipoTelaId)
        .get();

    final resultado = snapshot.docs
        .map((doc) => StockActual.fromJson(doc.data()))
        .where(
          (stock) =>
              stock.estado == StockRolloEstado.abierto ||
              stock.estado == StockRolloEstado.cerrado,
        )
        .toList();

    resultado.sort((a, b) {
      return a.numeroFisico.compareTo(b.numeroFisico);
    });

    return resultado;
  }

  Future<List<String>> obtenerTiposTelaConStock(String sucursalId) async {
    final snapshot = await _stockRef
        .where('sucursalActualId', isEqualTo: sucursalId)
        .get();

    final tipos = <String>{};

    for (final doc in snapshot.docs) {
      final stock = StockActual.fromJson(doc.data());

      if (stock.estado == StockRolloEstado.abierto ||
          stock.estado == StockRolloEstado.cerrado) {
        tipos.add(stock.tipoTelaId);
      }
    }

    return tipos.toList();
  }
}
