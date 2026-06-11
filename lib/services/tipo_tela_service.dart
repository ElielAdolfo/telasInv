import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inv_telas/config/env.dart';
import 'package:inv_telas/models/abmTiposTelas/tipo_tela.dart';

class TipoTelaService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _tiposTelaRef =>
      _db.collection(Env.col('tiposTela'));

  // ==========================================================
  // GET POR EMPRESA
  // ==========================================================
  Future<List<TipoTela>> getByEmpresa(String empresaId) async {
    try {
      final snapshot = await _tiposTelaRef
          .where('empresaId', isEqualTo: empresaId)
          .where('eliminado', isEqualTo: false)
          .orderBy('nombre')
          .get();

      return snapshot.docs
          .map((e) => TipoTela.fromJson({...e.data(), 'id': e.id}))
          .toList();
    } catch (e) {
      print('❌ getByEmpresa: $e');
      rethrow;
    }
  }

  // ==========================================================
  // GET POR ID
  // ==========================================================
  Future<TipoTela?> getById(String id) async {
    try {
      final doc = await _tiposTelaRef.doc(id).get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return TipoTela.fromJson({...doc.data()!, 'id': doc.id});
    } catch (e) {
      print('❌ getById: $e');
      rethrow;
    }
  }

  // ==========================================================
  // INSERT
  // ==========================================================
  Future<void> create(TipoTela tipoTela) async {
    try {
      await _tiposTelaRef.doc(tipoTela.id).set(tipoTela.toJson());
    } catch (e) {
      print('❌ create: $e');
      rethrow;
    }
  }

  // ==========================================================
  // UPDATE
  // ==========================================================
  Future<void> update(TipoTela tipoTela) async {
    try {
      await _tiposTelaRef.doc(tipoTela.id).update(tipoTela.toJson());
    } catch (e) {
      print('❌ update: $e');
      rethrow;
    }
  }

  // ==========================================================
  // ELIMINADO LOGICO
  // ==========================================================
  Future<void> delete({
    required String tipoTelaId,
    required String usuarioId,
  }) async {
    try {
      await _tiposTelaRef.doc(tipoTelaId).update({
        'eliminado': true,
        'activo': false,
        'fechaEliminacion': DateTime.now().toIso8601String(),
        'usuarioEliminadorId': usuarioId,
      });
    } catch (e) {
      print('❌ delete: $e');
      rethrow;
    }
  }

  // ==========================================================
  // VALIDAR DUPLICADO
  // ==========================================================
  Future<bool> existeNombre({
    required String empresaId,
    required String nombre,
    String? excluirId,
  }) async {
    try {
      final snapshot = await _tiposTelaRef
          .where('empresaId', isEqualTo: empresaId)
          .where('nombreNormalizado', isEqualTo: nombre.trim().toLowerCase())
          .where('eliminado', isEqualTo: false)
          .get();

      if (snapshot.docs.isEmpty) {
        return false;
      }

      if (excluirId == null) {
        return true;
      }

      return snapshot.docs.any((e) => e.id != excluirId);
    } catch (e) {
      print('❌ existeNombre: $e');
      rethrow;
    }
  }

  // ==========================================================
  // STREAM
  // ==========================================================
  Stream<List<TipoTela>> streamEmpresa(String empresaId) {
    try {
      return _tiposTelaRef
          .where('empresaId', isEqualTo: empresaId)
          .where('eliminado', isEqualTo: false)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((e) => TipoTela.fromJson({...e.data(), 'id': e.id}))
                .toList(),
          );
    } catch (e) {
      print('❌ streamEmpresa: $e');
      rethrow;
    }
  }
}
