import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inv_telas/config/env.dart';
import 'package:inv_telas/models/moneda.dart';

class MonedaService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _monedaRef =>
      _db.collection(Env.col('monedas'));

  Future<List<Moneda>> obtenerMonedasPorEmpresa(String empresaId) async {
    final snapshot = await _monedaRef
        .where('empresaId', isEqualTo: empresaId)
        .where('eliminado', isEqualTo: false)
        .get();

    return snapshot.docs.map((doc) => Moneda.fromMap(doc.data())).toList();
  }

  Future<void> crearMoneda(Moneda moneda) async {
    final docRef = _monedaRef.doc();

    final monedaConId = moneda.copyWith(
      id: docRef.id,
      fechaCreacion: DateTime.now(),
    );

    await docRef.set(monedaConId.toMap());
  }

  Future<void> actualizarMoneda(Moneda moneda) async {
    final monedaActualizada = moneda.copyWith(
      fechaModificacion: DateTime.now(),
    );

    await _monedaRef.doc(moneda.id).update(monedaActualizada.toMap());
  }

  Future<void> modificarEstadoEliminado({
    required String id,
    required bool eliminado,
    required String usuarioId,
  }) async {
    await _monedaRef.doc(id).update({
      'eliminado': eliminado,
      'activo': !eliminado,

      'usuarioEliminacion': eliminado ? usuarioId : null,

      'fechaEliminacion': eliminado ? FieldValue.serverTimestamp() : null,

      'usuarioModificacion': usuarioId,
      'fechaModificacion': FieldValue.serverTimestamp(),
    });
  }
}
