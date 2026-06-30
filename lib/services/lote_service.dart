import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inv_telas/config/env.dart';
import 'package:inv_telas/models/lotes/lote.dart';
import 'package:inv_telas/models/lotes/lote_detalle.dart';
import 'package:inv_telas/models/lotes/lote_gasto.dart';
import 'package:inv_telas/models/lotes/lote_historial_estado.dart';

class LoteService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _loteRef =>
      _db.collection(Env.col('lotes'));

  Future<List<Lote>> obtenerLotesPorEmpresa(String empresaId) async {
    final snapshot = await _loteRef
        .where('empresaId', isEqualTo: empresaId)
        .where('eliminado', isEqualTo: false)
        .get();

    return snapshot.docs.map((e) => Lote.fromMap(e.data())).toList();
  }

  Future<void> crearLote(Lote lote) async {
    final doc = _loteRef.doc();

    final nuevoLote = lote.copyWith(id: doc.id, fechaCreacion: DateTime.now());

    await doc.set(nuevoLote.toMap());
  }

  Future<void> actualizarLote(Lote lote) async {
    await _loteRef
        .doc(lote.id)
        .update(lote.copyWith(fechaModificacion: DateTime.now()).toMap());
  }

  Future<void> eliminarLote({
    required String loteId,
    required String usuarioId,
  }) async {
    await _loteRef.doc(loteId).update({
      'eliminado': true,
      'activo': false,
      'usuarioEliminacion': usuarioId,
      'usuarioModificacion': usuarioId,
      'fechaEliminacion': FieldValue.serverTimestamp(),
      'fechaModificacion': FieldValue.serverTimestamp(),
    });
  }

  Future<void> restaurarLote({
    required String loteId,
    required String usuarioId,
  }) async {
    await _loteRef.doc(loteId).update({
      'eliminado': false,
      'activo': true,
      'usuarioEliminacion': null,
      'usuarioModificacion': usuarioId,
      'fechaEliminacion': null,
      'fechaModificacion': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // DETALLES
  // ============================================================

  Future<void> guardarDetalle(LoteDetalle detalle) async {
    await _loteRef
        .doc(detalle.loteId)
        .collection('detalles')
        .doc(detalle.id)
        .set(detalle.toMap());
  }

  Future<List<LoteDetalle>> obtenerDetalles(String loteId) async {
    final snapshot = await _loteRef.doc(loteId).collection('detalles').get();

    return snapshot.docs.map((e) => LoteDetalle.fromMap(e.data())).toList();
  }

  // ============================================================
  // GASTOS
  // ============================================================

  Future<void> guardarGasto(LoteGasto gasto) async {
    await _loteRef
        .doc(gasto.loteId)
        .collection('gastos')
        .doc(gasto.id)
        .set(gasto.toMap());
  }

  Future<List<LoteGasto>> obtenerGastos(String loteId) async {
    final snapshot = await _loteRef.doc(loteId).collection('gastos').get();

    return snapshot.docs.map((e) => LoteGasto.fromMap(e.data())).toList();
  }

  // ============================================================
  // HISTORIAL
  // ============================================================

  Future<void> guardarHistorialEstado(LoteHistorialEstado historial) async {
    await _loteRef
        .doc(historial.loteId)
        .collection('historial')
        .doc(historial.id)
        .set(historial.toMap());
  }

  Future<List<LoteHistorialEstado>> obtenerHistorial(String loteId) async {
    final snapshot = await _loteRef
        .doc(loteId)
        .collection('historial')
        .orderBy('fechaCambio')
        .get();

    return snapshot.docs
        .map((e) => LoteHistorialEstado.fromMap(e.data()))
        .toList();
  }
}
