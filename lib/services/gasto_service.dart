import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inv_telas/config/env.dart';
import 'package:inv_telas/models/lotes/gastos.dart';

class GastoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _gastoRef =>
      _db.collection(Env.col('gastos'));

  Future<List<Gasto>> obtenerGastosPorLote(
    String empresaId,
    String loteId,
  ) async {
    final snapshot = await _gastoRef
        .where('empresaId', isEqualTo: empresaId)
        .where('loteId', isEqualTo: loteId)
        .where('eliminado', isEqualTo: false)
        .get(const GetOptions(source: Source.server));

    return snapshot.docs.map((doc) => Gasto.fromJson(doc.data())).toList();
  }

  Future<void> crearGasto(Gasto gasto) async {
    final docRef = gasto.id.isEmpty ? _gastoRef.doc() : _gastoRef.doc(gasto.id);

    final gastoFinal = gasto.copyWith(id: docRef.id);

    await docRef.set(gastoFinal.toJson());
  }

  Future<void> actualizarGasto(Gasto gasto) async {
    await _gastoRef.doc(gasto.id).set(gasto.toJson(), SetOptions(merge: true));
  }

  Future<void> modificarEstadoEliminado({
    required String id,
    required bool eliminado,
    required String usuarioId,
  }) async {
    final ahoraIso = DateTime.now().toIso8601String();

    await _gastoRef.doc(id).update({
      'eliminado': eliminado,
      'activo': !eliminado,
      'usuarioEliminacion': eliminado ? usuarioId : null,
      'fechaEliminacion': eliminado ? ahoraIso : null,
      'usuarioModificacion': usuarioId,
      'fechaModificacion': ahoraIso,
    });
  }
}
