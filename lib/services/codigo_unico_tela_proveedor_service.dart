import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inv_telas/models/codigosTelaProveedor/codigo_unico_tela_proveedor.dart';
import '../config/env.dart';

class CodigoUnicoTelaProveedorService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _ref =>
      _db.collection(Env.col('codigoUnicoTelaProveedor'));

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

  Future<void> create(CodigoUnicoTelaProveedor data) async {
    await _ref.doc(data.id).set(data.toMap());
  }

  Future<void> update(CodigoUnicoTelaProveedor data) async {
    await _ref.doc(data.id).update(data.toMap());
  }

  Future<CodigoUnicoTelaProveedor?> getByProveedorTipo({
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

    if (snap.docs.isEmpty) return null;

    return CodigoUnicoTelaProveedor.fromMap(snap.docs.first.data());
  }

  Future<List<CodigoUnicoTelaProveedor>> getByEmpresa(String empresaId) async {
    final snap = await _ref
        .where('empresaId', isEqualTo: empresaId)
        .where('eliminado', isEqualTo: false)
        .get();

    return snap.docs
        .map((e) => CodigoUnicoTelaProveedor.fromMap(e.data()))
        .toList();
  }

  Future<CodigoUnicoTelaProveedor?> getById(String id) async {
    final doc = await _ref.doc(id).get();

    if (!doc.exists) return null;

    return CodigoUnicoTelaProveedor.fromMap(doc.data()!);
  }

  Future<void> delete(String id, String usuario) async {
    await _ref.doc(id).update({
      'eliminado': true,
      'usuarioEliminacion': usuario,
      'fechaEliminacion': Timestamp.now(),
    });
  }
}
