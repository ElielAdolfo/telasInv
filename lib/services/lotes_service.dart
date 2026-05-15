import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inv_telas/config/env.dart';
import 'package:inv_telas/models/lote.dart';

class LotesService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Colección
  CollectionReference get _ref => _db.collection(Env.col('lotes'));

  // Obtener todos (ordenados por fecha desc, excluyendo eliminados)
  Stream<List<Lote>> streamLotes() {
    return _ref.where('eliminado', isEqualTo: false).snapshots().map((snap) {
      final lotes = snap.docs
          .map((doc) => Lote.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      lotes.sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));

      return lotes;
    });
  }

  // Crear
  Future<void> crearLote(Lote lote) async {
    await _ref.doc(lote.id).set(lote.toJson());
  }

  // Actualizar
  Future<void> actualizarLote(Lote lote) async {
    await _ref.doc(lote.id).update(lote.toJson());
  }

  // Eliminación Lógica
  Future<void> eliminarLote(String loteId, String userId) async {
    await _ref.doc(loteId).update({
      'eliminado': true,
      'usuarioEliminadorId': userId,
      'fechaEliminacion': DateTime.now().toIso8601String(),
      'activo': false, // Si se elimina, se desactiva
    });
  }

  // Cambiar estado activo
  Future<void> toggleActivo(String loteId, bool valor) async {
    await _ref.doc(loteId).update({'activo': valor});
  }
}
