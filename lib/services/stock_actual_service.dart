// lib/services/stock_actual_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inv_telas/models/stock_actual.dart';
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
}
