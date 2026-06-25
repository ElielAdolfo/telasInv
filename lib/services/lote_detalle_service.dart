import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inv_telas/models/lotes/lote_detalle.dart';
import 'package:inv_telas/models/lotes/rollo_info.dart';
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

  //==================================================
  // DISTRIBUCIÓN DE ROLLOS: GUARDAR OPTIMIZADO (BATCH)
  //==================================================
  Future<void> guardarRollosIndependientes({
    required String loteDetalleId,
    required List<RolloInfo> rollos,
  }) async {
    final WriteBatch batch = _db.batch();
    final CollectionReference rollosSubColeccion = _ref
        .doc(loteDetalleId)
        .collection('rollos');

    // OPTIMIZACIÓN: Borramos los documentos de la distribución anterior en este detalle
    // para sobreescribir limpiamente con la nueva agrupación.
    final antiguosDocs = await rollosSubColeccion.get();
    for (var doc in antiguosDocs.docs) {
      batch.delete(doc.reference);
    }

    // Insertamos la nueva distribución optimizada
    for (var rollo in rollos) {
      final docId = rollo.id.isEmpty ? rollosSubColeccion.doc().id : rollo.id;
      final docRef = rollosSubColeccion.doc(docId);

      final nuevoRollo = RolloInfo(
        id: docId,
        loteDetalleId: loteDetalleId,
        metraje: rollo.metraje,
        colorId: rollo.colorId,
        cantidad: rollo.cantidad, // Guardamos la cantidad agrupada
        sucursalActualId: rollo.sucursalActualId,
        estado: rollo.estado,
        atributosEspeciales: rollo.atributosEspeciales,
      );

      batch.set(docRef, nuevoRollo.toMap(), SetOptions(merge: true));
    }

    await batch.commit();
  }

  //==================================================
  // DISTRIBUCIÓN DE ROLLOS: RECUPERAR POR DETALLE
  //==================================================
  Future<List<RolloInfo>> getRollosByDetalle({
    required String loteDetalleId,
  }) async {
    // CORRECCIÓN: Buscamos directamente dentro de la subcolección del detalle
    final snapshot = await _ref.doc(loteDetalleId).collection('rollos').get();

    return snapshot.docs.map((doc) => RolloInfo.fromMap(doc.data())).toList();
  }
}
