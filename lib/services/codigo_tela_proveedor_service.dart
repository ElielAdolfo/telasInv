import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inv_telas/models/lotes/codigo_tela_proveedor.dart';
import '../config/env.dart';

class CodigoTelaProveedorService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _ref =>
      _db.collection(Env.col('codigoTelaProveedor'));

  Future<bool> existe({
    required String empresaId,
    required String proveedorId,
    required String tipoTelaId,
  }) async {
    final snap = await _ref
        .where('empresaId', isEqualTo: empresaId)
        .where('proveedorId', isEqualTo: proveedorId)
        .where('tipoTelaId', isEqualTo: tipoTelaId)
        .where('eliminado', isEqualTo: false)
        .get();

    return snap.docs.isNotEmpty;
  }

  Future<void> create(CodigoTelaProveedor data) async {
    await _ref.doc(data.id).set(data.toMap());
  }

  Future<void> update(CodigoTelaProveedor data) async {
    await _ref.doc(data.id).update(data.toMap());
  }

  Future<CodigoTelaProveedor?> getById(String id) async {
    final doc = await _ref.doc(id).get();

    if (!doc.exists) return null;

    return CodigoTelaProveedor.fromMap(doc.data()!);
  }

  Future<CodigoTelaProveedor?> getByProveedorTipo({
    required String empresaId,
    required String proveedorId,
    required String tipoTelaId,
  }) async {
    final snap = await _ref
        .where('empresaId', isEqualTo: empresaId)
        .where('proveedorId', isEqualTo: proveedorId)
        .where('tipoTelaId', isEqualTo: tipoTelaId)
        .where('eliminado', isEqualTo: false)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) {
      return null;
    }

    return CodigoTelaProveedor.fromMap(snap.docs.first.data());
  }

  Future<List<CodigoTelaProveedor>> getByEmpresaId(String empresaId) async {
    final snap = await _ref
        .where('empresaId', isEqualTo: empresaId)
        .where('eliminado', isEqualTo: false)
        .get();

    return snap.docs.map((e) => CodigoTelaProveedor.fromMap(e.data())).toList();
  }
}
