import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inv_telas/config/env.dart';
import 'package:inv_telas/models/rol.dart';

class RolService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Rol?> getRolById(String id) async {
    try {
      final doc = await _db.collection(Env.col('roles')).doc(id).get();
      if (doc.exists && doc.data() != null) {
        return Rol.fromJson({'id': doc.id, ...doc.data()!});
      }
      return null;
    } catch (e) {
      print('Error getRolById: $e');
      return null;
    }
  }

  // NUEVO: Obtener lista de roles por IDs
  Future<List<Rol>> getRolesByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    try {
      // Firestore permite máximo 10 elementos en consulta 'whereIn'
      // Si esperas más de 10, hay que hacer batches, pero para roles está bien.
      final snapshot = await _db
          .collection(Env.col('roles'))
          .where(FieldPath.documentId, whereIn: ids)
          .get();

      return snapshot.docs
          .map((doc) => Rol.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      print('Error getRolesByIds: $e');
      return [];
    }
  }
}
