import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inv_telas/models/lotes/lote_detalle.dart';
import 'package:inv_telas/models/abmTiposTelas/proveedor.dart';
import 'package:inv_telas/models/abmTiposTelas/tipo_tela.dart';
import 'package:inv_telas/models/lotes/codigo_tela_proveedor.dart';
import 'package:inv_telas/models/lotes/rollo_info.dart';
import '../config/env.dart';

class LoteGastosService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _ref =>
      _db.collection(Env.col('loteDetalle'));

  Future<List<LoteDetalle>> getByLote(String loteId) async {
    final snapshot = await _ref
        .where('loteId', isEqualTo: loteId)
        .where('eliminado', isEqualTo: false)
        .get();

    return snapshot.docs.map((doc) => LoteDetalle.fromMap(doc.data())).toList();
  }

  Future<List<RolloInfo>> getRollosPorDetalleIds(
    List<String> detalleIds,
  ) async {
    if (detalleIds.isEmpty) return [];

    // Consultamos las subcolecciones en paralelo por cada detalle ID
    final listadosDeRollos = await Future.wait(
      detalleIds.map((id) async {
        final snapshot = await _ref.doc(id).collection('rollos').get();
        return snapshot.docs.map((doc) {
          final data = doc.data();
          if (!data.containsKey('id')) data['id'] = doc.id;
          return RolloInfo.fromMap(data);
        }).toList();
      }),
    );

    // Aplanamos la lista de listas en una sola lista lineal de RolloInfo
    return listadosDeRollos.expand((element) => element).toList();
  }

  Future<List<CodigoTelaProveedor>> getCodigosByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    final snapshot = await _db
        .collection(Env.col('codigoTelaProveedor'))
        .where(FieldPath.documentId, whereIn: ids)
        .get();

    return snapshot.docs
        .map((doc) => CodigoTelaProveedor.fromMap(doc.data()))
        .toList();
  }

  Future<List<Proveedor>> getProveedoresByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    final snapshot = await _db
        .collection(Env.col('proveedores'))
        .where(FieldPath.documentId, whereIn: ids)
        .get();

    return snapshot.docs.map((doc) => Proveedor.fromJson(doc.data())).toList();
  }

  Future<List<TipoTela>> getTiposTelaByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    final snapshot = await _db
        .collection(Env.col('tiposTela'))
        .where(FieldPath.documentId, whereIn: ids)
        .get();

    return snapshot.docs.map((doc) => TipoTela.fromJson(doc.data())).toList();
  }
}
