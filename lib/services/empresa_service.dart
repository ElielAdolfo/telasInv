import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inv_telas/config/env.dart';
import 'package:inv_telas/models/empresa.dart';

class EmpresaService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Empresa?> getEmpresaById(String id) async {
    try {
      final doc = await _db.collection(Env.col('empresas')).doc(id).get();
      if (doc.exists && doc.data() != null) {
        return Empresa.fromJson({'id': doc.id, ...doc.data()!});
      }
      return null;
    } catch (e) {
      print('Error obteniendo empresa: $e');
      return null;
    }
  }

  Future<List<Empresa>> getEmpresasByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    try {
      final snapshot = await _db
          .collection(Env.col('empresas'))
          .where(FieldPath.documentId, whereIn: ids)
          .get();
      return snapshot.docs
          .map((doc) => Empresa.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      print('Error obteniendo empresas: $e');
      return [];
    }
  }
}
