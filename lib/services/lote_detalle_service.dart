import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inv_telas/models/lotes/lote_detalle.dart';
import '../config/env.dart';

class LoteDetalleService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _ref =>
      _db.collection(Env.col('loteDetalle'));

  //==================================================
  // LISTAR POR LOTE (ONE SHOT)
  //==================================================
  Future<List<LoteDetalle>> getByLote(String loteId) async {
    final snapshot = await _ref
        .where('loteId', isEqualTo: loteId)
        .where('eliminado', isEqualTo: false)
        .get();

    return snapshot.docs.map((doc) => LoteDetalle.fromMap(doc.data())).toList();
  }

  //==================================================
  // GUARDAR (CREATE / UPDATE)
  //==================================================
  Future<void> save(LoteDetalle detalle) async {
    await _ref.doc(detalle.id).set(detalle.toMap());
  }

  //==================================================
  // ELIMINAR (SOFT DELETE)
  //==================================================
  Future<void> delete(String id, String usuarioId) async {
    await _ref.doc(id).update({
      'eliminado': true,
      'usuarioEliminacion': usuarioId,
      'fechaEliminacion': FieldValue.serverTimestamp(),
    });
  }
}
